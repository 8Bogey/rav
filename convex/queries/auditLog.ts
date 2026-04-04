/**
 * Audit Log Queries for Convex
 */

import { query } from "../_generated/server";
import { v } from "convex/values";

// Get all active audit logs for the current tenant
export const getActiveAuditLogs = query({
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
      .query("auditLog")
      .withIndex("by_ownerId", (q) => q.eq("ownerId", args.ownerId))
      .filter((q) => q.neq(q.field("inTrash"), true))
      .collect();
  },
});

// Get audit logs with pagination
export const getAuditLogsPaginated = query({
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
      return { auditLogs: [], nextCursor: null };
    }

    const limit = args.limit ?? 50;
    const cursor = args.cursor;

    let query = ctx.db
      .query("auditLog")
      .withIndex("by_ownerId", (q) => q.eq("ownerId", args.ownerId))
      .filter((q) => q.neq(q.field("inTrash"), true));

    if (cursor) {
      const doc = await ctx.db.get(cursor as any);
      if (doc) {
        query = query.filter((q) => q.gt(q.field("timestamp"), doc.timestamp));
      }
    }

    const auditLogs = await query.take(limit + 1);
    const hasMore = auditLogs.length > limit;
    const nextCursor = hasMore ? auditLogs[limit - 1]._id : null;

    return {
      auditLogs: hasMore ? auditLogs.slice(0, limit) : auditLogs,
      nextCursor,
    };
  },
});

// Get audit logs by user
export const getAuditLogsByUser = query({
  args: {
    ownerId: v.string(),
    user: v.string(),
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
      .query("auditLog")
      .withIndex("by_user", (q) => q.eq("user", args.user))
      .filter((q) => 
        q.and(
          q.eq(q.field("ownerId"), args.ownerId),
          q.neq(q.field("inTrash"), true)
        )
      )
      .collect();
  },
});

// Get audit logs by action type
export const getAuditLogsByAction = query({
  args: {
    ownerId: v.string(),
    action: v.string(),
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
      .query("auditLog")
      .withIndex("by_action", (q) => q.eq("action", args.action))
      .filter((q) => 
        q.and(
          q.eq(q.field("ownerId"), args.ownerId),
          q.neq(q.field("inTrash"), true)
        )
      )
      .collect();
  },
});

// Get audit logs by target
export const getAuditLogsByTarget = query({
  args: {
    ownerId: v.string(),
    target: v.string(),
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
      .query("auditLog")
      .withIndex("by_target", (q) => q.eq("target", args.target))
      .filter((q) => 
        q.and(
          q.eq(q.field("ownerId"), args.ownerId),
          q.neq(q.field("inTrash"), true)
        )
      )
      .collect();
  },
});

// Get audit logs within a date range
export const getAuditLogsByDateRange = query({
  args: {
    ownerId: v.string(),
    startDate: v.number(),
    endDate: v.number(),
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
      .query("auditLog")
      .withIndex("by_timestamp", (q) => q.gte("timestamp", args.startDate))
      .filter((q) => 
        q.and(
          q.eq(q.field("ownerId"), args.ownerId),
          q.lte(q.field("timestamp"), args.endDate),
          q.neq(q.field("inTrash"), true)
        )
      )
      .collect();
  },
});