/**
 * Workers Queries for Convex
 */

import { query } from "../_generated/server";
import { v } from "convex/values";

// Get all active workers for the current tenant
export const getActiveWorkers = query({
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
      .query("workers")
      .withIndex("by_ownerId", (q) => q.eq("ownerId", args.ownerId))
      .filter((q) => q.eq(q.field("isDeleted"), false))
      .collect();
  },
});

// Get workers with pagination
export const getWorkersPaginated = query({
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
      return { workers: [], nextCursor: null };
    }

    const limit = args.limit ?? 50;
    const cursor = args.cursor;

    let query = ctx.db
      .query("workers")
      .withIndex("by_ownerId", (q) => q.eq("ownerId", args.ownerId))
      .filter((q) => q.eq(q.field("isDeleted"), false));

    if (cursor) {
      const doc = await ctx.db.get(cursor as any);
      if (doc) {
        query = query.filter((q) => q.gt(q.field("updatedAt"), doc.updatedAt));
      }
    }

    const workers = await query.take(limit + 1);
    const hasMore = workers.length > limit;
    const nextCursor = hasMore ? workers[limit - 1]._id : null;

    return {
      workers: hasMore ? workers.slice(0, limit) : workers,
      nextCursor,
    };
  },
});

// Get a single worker by ID
export const getWorkerById = query({
  args: {
    ownerId: v.string(),
    id: v.id("workers"),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated");
    }

    if (args.ownerId !== identity.subject) {
      return null;
    }

    const worker = await ctx.db.get(args.id);
    if (!worker || worker.isDeleted || worker.ownerId !== args.ownerId) {
      return null;
    }

    return worker;
  },
});

// Get worker by name
export const getWorkerByName = query({
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
      .query("workers")
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

// Get worker by phone
export const getWorkerByPhone = query({
  args: {
    ownerId: v.string(),
    phone: v.string(),
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
      .query("workers")
      .withIndex("by_phone", (q) => q.eq("phone", args.phone))
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

// Get workers modified since timestamp (for down-sync)
export const getWorkersModifiedSince = query({
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

    const workers = await ctx.db
      .query("workers")
      .withIndex("by_ownerId", (q) => q.eq("ownerId", args.ownerId))
      .filter((q) => 
        q.and(
          q.gt(q.field("updatedAt"), args.since),
          q.eq(q.field("isDeleted"), false)
        )
      )
      .collect();

    return workers;
  },
});