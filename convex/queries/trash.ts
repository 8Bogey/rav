/**
 * Trash Queries for Convex
 */

import { query } from "../_generated/server";
import { v } from "convex/values";

/**
 * Get all trash items for an owner.
 */
export const getTrashItems = query({
  args: {
    ownerId: v.string(),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) { throw new Error("Unauthenticated"); }
    if (args.ownerId !== identity.subject) { return []; }

    return await ctx.db
      .query("trash")
      .withIndex("by_ownerId", (q) => q.eq("ownerId", args.ownerId))
      .order("desc")
      .collect();
  },
});

/**
 * Get trash items with pagination.
 */
export const getTrashItemsPaginated = query({
  args: {
    ownerId: v.string(),
    cursor: v.optional(v.string()),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) { throw new Error("Unauthenticated"); }
    if (args.ownerId !== identity.subject) { return { trashItems: [], nextCursor: null }; }

    const limit = args.limit ?? 50;
    let trashItems = await ctx.db
      .query("trash")
      .withIndex("by_ownerId", (q) => q.eq("ownerId", args.ownerId))
      .order("desc")
      .take(limit + 1);

    const hasMore = trashItems.length > limit;
    const nextCursor = hasMore ? trashItems[limit - 1]._id : null;

    return {
      trashItems: hasMore ? trashItems.slice(0, limit) : trashItems,
      nextCursor,
    };
  },
});

/**
 * Get trash count for an owner.
 */
export const getTrashCount = query({
  args: {
    ownerId: v.string(),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) { throw new Error("Unauthenticated"); }
    if (args.ownerId !== identity.subject) { return { count: 0 }; }

    const items = await ctx.db
      .query("trash")
      .withIndex("by_ownerId", (q) => q.eq("ownerId", args.ownerId))
      .collect();
    return { count: items.length };
  },
});
