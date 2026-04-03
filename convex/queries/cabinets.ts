/**
 * Cabinets Queries for Convex
 */

import { query } from "../_generated/server";
import { v } from "convex/values";

// Get all active cabinets for the current tenant
export const getActiveCabinets = query({
  args: {
    ownerId: v.string(),
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
      .query("cabinets")
      .withIndex("by_ownerId", (q) => q.eq("ownerId", args.ownerId))
      .filter((q) => q.eq(q.field("isDeleted"), false))
      .collect();
  },
});

// Get cabinets with pagination
export const getCabinetsPaginated = query({
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
      return { cabinets: [], nextCursor: null };
    }

    const limit = args.limit ?? 50;
    const cursor = args.cursor;

    let query = ctx.db
      .query("cabinets")
      .withIndex("by_ownerId", (q) => q.eq("ownerId", args.ownerId))
      .filter((q) => q.eq(q.field("isDeleted"), false));

    if (cursor) {
      const doc = await ctx.db.get(cursor as any);
      if (doc) {
        query = query.filter((q) => q.gt(q.field("updatedAt"), doc.updatedAt));
      }
    }

    const cabinets = await query.take(limit + 1);
    const hasMore = cabinets.length > limit;
    const nextCursor = hasMore ? cabinets[limit - 1]._id : null;

    return {
      cabinets: hasMore ? cabinets.slice(0, limit) : cabinets,
      nextCursor,
    };
  },
});

// Get a single cabinet by ID
// Accepts either Convex document ID (v.id) or client-side UUID (via cloudId)
export const getCabinetById = query({
  args: {
    ownerId: v.string(),
    id: v.optional(v.string()), // Accept string for cloudId lookup
    convexId: v.optional(v.string()), // Alternative: explicit cloudId
  },
  handler: async (ctx, args) => {
    // Allow unauthenticated access in dev mode - trust ownerId from client
    // const identity = await ctx.auth.getUserIdentity();
    // if (!identity) {
    //   throw new Error("Unauthenticated");
    // }

    // if (args.ownerId !== identity.subject) {
    //   return null;
    // }

    // Try to resolve the document ID
    let documentId = args.id ?? args.convexId;
    
    if (documentId == null) {
      return null;
    }

    // Check if it's a Convex document ID format (starts with table name)
    if (documentId.startsWith('cabinets/')) {
      // It's a Convex document ID
      const cabinet = await ctx.db.get(documentId as any);
      if (!cabinet || cabinet.isDeleted || cabinet.ownerId !== args.ownerId) {
        return null;
      }
      return cabinet;
    } else {
      // It's a client UUID - look up by cloudId index
      const cabinet = await ctx.db
        .query("cabinets")
        .withIndex("by_cloudId", (q) => q.eq("cloudId", documentId!))
        .first();
      
      if (!cabinet || cabinet.isDeleted || cabinet.ownerId !== args.ownerId) {
        return null;
      }
      return cabinet;
    }
  },
});

// Get cabinet by letter
export const getCabinetByLetter = query({
  args: {
    ownerId: v.string(),
    letter: v.string(),
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
      .query("cabinets")
      .withIndex("by_letter", (q) => q.eq("letter", args.letter))
      .filter((q) => 
        q.and(
          q.eq(q.field("ownerId"), args.ownerId),
          q.eq(q.field("isDeleted"), false)
        )
      )
      .take(1);

    return results.length > 0 ? results[0] : null;
  },
});

// Get cabinet by name
export const getCabinetByName = query({
  args: {
    ownerId: v.string(),
    name: v.string(),
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
      .query("cabinets")
      .withIndex("by_name", (q) => q.eq("name", args.name))
      .filter((q) => 
        q.and(
          q.eq(q.field("ownerId"), args.ownerId),
          q.eq(q.field("isDeleted"), false)
        )
      )
      .take(1);

    return results.length > 0 ? results[0] : null;
  },
});

// Get cabinets modified since timestamp (for down-sync)
export const getCabinetsModifiedSince = query({
  args: {
    ownerId: v.string(),
    since: v.number(),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated");
    }

    if (args.ownerId !== identity.subject) {
      return [];
    }

    const cabinets = await ctx.db
      .query("cabinets")
      .withIndex("by_ownerId", (q) => q.eq("ownerId", args.ownerId))
      .filter((q) => 
        q.and(
          q.gt(q.field("updatedAt"), args.since),
          q.eq(q.field("isDeleted"), false)
        )
      )
      .collect();

    return cabinets;
  },
});