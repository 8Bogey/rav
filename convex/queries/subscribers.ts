/**
 * Subscribers Queries for Convex
 * 
 * All queries enforce:
 * - Tenant isolation (ownerId)
 * - Exclude soft-deleted records (isDeleted == false)
 * - Cursor-based pagination
 */

import { query } from "../_generated/server";
import { v } from "convex/values";

// Get all active (non-deleted) subscribers for the current tenant
// NOTE: Allows unauthenticated access for demo mode
export const getActiveSubscribers = query({
  args: {
    ownerId: v.string(),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) { throw new Error("Unauthenticated"); }
    if (args.ownerId !== identity.subject) { return []; }

    return await ctx.db
      .query("subscribers")
      .withIndex("by_ownerId", (q) => q.eq("ownerId", args.ownerId))
      .filter((q) => q.neq(q.field("inTrash"), true))
      .collect();
  },
});

// Get subscribers with pagination (cursor-based)
export const getSubscribersPaginated = query({
  args: {
    ownerId: v.string(),
    cursor: v.optional(v.string()),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated");
    }

    if (args.ownerId !== identity.subject) {
      return { subscribers: [], nextCursor: null };
    }

    const limit = args.limit ?? 50;
    const cursor = args.cursor;

    let query = ctx.db
      .query("subscribers")
      .withIndex("by_ownerId", (q) => q.eq("ownerId", args.ownerId))
      .filter((q) => q.neq(q.field("inTrash"), true));

    if (cursor) {
      const doc = await ctx.db.get(cursor as any);
      if (doc) {
        query = query.filter((q) => q.gt(q.field("updatedAt"), doc.updatedAt));
      }
    }

    const subscribers = await query.take(limit + 1);
    const hasMore = subscribers.length > limit;
    const nextCursor = hasMore ? subscribers[limit - 1]._id : null;

    return {
      subscribers: hasMore ? subscribers.slice(0, limit) : subscribers,
      nextCursor,
    };
  },
});

// Get a single subscriber by ID
// Accepts either Convex document ID (v.id) or client-side UUID (via cloudId)
export const getSubscriberById = query({
  args: {
    ownerId: v.string(),
    id: v.optional(v.string()), // Accept string for cloudId lookup
    convexId: v.optional(v.string()), // Alternative: explicit cloudId
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated");
    }

    if (args.ownerId !== identity.subject) {
      return null;
    }

    // Try to resolve the document ID
    let documentId = args.id ?? args.convexId;
    
    if (documentId == null) {
      return null;
    }

    // Check if it's a Convex document ID format (starts with table name)
    if (documentId.startsWith('subscribers/')) {
      // It's a Convex document ID
      const subscriber = await ctx.db.get(documentId as any);
      if (!subscriber || subscriber.inTrash || subscriber.ownerId !== args.ownerId) {
        return null;
      }
      return subscriber;
    } else {
      // It's a client UUID - look up by cloudId index
      const subscriber = await ctx.db
        .query("subscribers")
        .withIndex("by_cloudId", (q) => q.eq("cloudId", documentId!))
        .first();
      
      if (!subscriber || subscriber.inTrash || subscriber.ownerId !== args.ownerId) {
        return null;
      }
      return subscriber;
    }
  },
});

// Get subscribers by cabinet
export const getSubscribersByCabinet = query({
  args: {
    ownerId: v.string(),
    cabinet: v.string(),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated");
    }

    if (args.ownerId !== identity.subject) {
      return [];
    }

    return await ctx.db
      .query("subscribers")
      .withIndex("by_cabinet", (q) => q.eq("cabinet", args.cabinet))
      .filter((q) => 
        q.and(
          q.eq(q.field("ownerId"), args.ownerId),
          q.neq(q.field("inTrash"), true)
        )
      )
      .collect();
  },
});

// Get subscribers by status
export const getSubscribersByStatus = query({
  args: {
    ownerId: v.string(),
    status: v.union(v.literal("inactive"), v.literal("active"), v.literal("suspended"), v.literal("disconnected")),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated");
    }

    if (args.ownerId !== identity.subject) {
      return [];
    }

    return await ctx.db
      .query("subscribers")
      .withIndex("by_status", (q) => q.eq("status", args.status))
      .filter((q) => 
        q.and(
          q.eq(q.field("ownerId"), args.ownerId),
          q.neq(q.field("inTrash"), true)
        )
      )
      .collect();
  },
});

// Get subscriber by code
export const getSubscriberByCode = query({
  args: {
    ownerId: v.string(),
    code: v.string(),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated");
    }

    if (args.ownerId !== identity.subject) {
      return null;
    }

    const results = await ctx.db
      .query("subscribers")
      .withIndex("by_code", (q) => q.eq("code", args.code))
      .filter((q) => 
        q.and(
          q.eq(q.field("ownerId"), args.ownerId),
          q.neq(q.field("inTrash"), true)
        )
      )
      .take(1);

    return results.length > 0 ? results[0] : null;
  },
});

// Search subscribers by name
export const searchSubscribers = query({
  args: {
    ownerId: v.string(),
    searchTerm: v.string(),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated");
    }

    if (args.ownerId !== identity.subject) {
      return [];
    }

    // Get all non-deleted subscribers and filter by name (case-insensitive)
    const allSubscribers = await ctx.db
      .query("subscribers")
      .withIndex("by_ownerId", (q) => q.eq("ownerId", args.ownerId))
      .filter((q) => q.neq(q.field("inTrash"), true))
      .collect();

    const searchLower = args.searchTerm.toLowerCase();
    return allSubscribers.filter((s) => 
      s.name.toLowerCase().includes(searchLower)
    );
  },
});

// Get subscribers modified since timestamp (for down-sync)
// IMPORTANT: Must include deleted items so app can sync deletions
// NOTE: Allows unauthenticated access for demo mode
export const getSubscribersModifiedSince = query({
  args: {
    ownerId: v.string(),
    since: v.number(), // Unix timestamp
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) { throw new Error("Unauthenticated"); }
    if (args.ownerId !== identity.subject) { return []; }

    // Include ALL subscribers (including deleted) so app can sync deletions
    const subscribers = await ctx.db
      .query("subscribers")
      .withIndex("by_ownerId", (q) => q.eq("ownerId", args.ownerId))
      .filter((q) => q.gt(q.field("updatedAt"), args.since))
      .collect();

    return subscribers;
  },
});