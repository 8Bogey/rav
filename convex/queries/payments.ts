/**
 * Payments Queries for Convex
 */

import { query } from "../_generated/server";
import { v } from "convex/values";

// Get all active payments for the current tenant
export const getActivePayments = query({
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
      .query("payments")
      .withIndex("by_ownerId", (q) => q.eq("ownerId", args.ownerId))
      .filter((q) => q.eq(q.field("isDeleted"), false))
      .collect();
  },
});

// Get payments with pagination
export const getPaymentsPaginated = query({
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
      return { payments: [], nextCursor: null };
    }

    const limit = args.limit ?? 50;
    const cursor = args.cursor;

    let query = ctx.db
      .query("payments")
      .withIndex("by_ownerId", (q) => q.eq("ownerId", args.ownerId))
      .filter((q) => q.eq(q.field("isDeleted"), false));

    if (cursor) {
      const doc = await ctx.db.get(cursor as any);
      if (doc) {
        query = query.filter((q) => q.gt(q.field("updatedAt"), doc.updatedAt));
      }
    }

    const payments = await query.take(limit + 1);
    const hasMore = payments.length > limit;
    const nextCursor = hasMore ? payments[limit - 1]._id : null;

    return {
      payments: hasMore ? payments.slice(0, limit) : payments,
      nextCursor,
    };
  },
});

// Get a single payment by ID
export const getPaymentById = query({
  args: {
    ownerId: v.string(),
    id: v.id("payments"),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated");
    }

    if (args.ownerId !== identity.subject) {
      return null;
    }

    const payment = await ctx.db.get(args.id);
    if (!payment || payment.isDeleted || payment.ownerId !== args.ownerId) {
      return null;
    }

    return payment;
  },
});

// Get payments for a specific subscriber
export const getPaymentsBySubscriber = query({
  args: {
    ownerId: v.string(),
    subscriberId: v.string(),
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
      .query("payments")
      .withIndex("by_subscriberId", (q) => q.eq("subscriberId", args.subscriberId))
      .filter((q) => 
        q.and(
          q.eq(q.field("ownerId"), args.ownerId),
          q.eq(q.field("isDeleted"), false)
        )
      )
      .collect();
  },
});

// Get payments by worker
export const getPaymentsByWorker = query({
  args: {
    ownerId: v.string(),
    worker: v.string(),
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
      .query("payments")
      .withIndex("by_worker", (q) => q.eq("worker", args.worker))
      .filter((q) => 
        q.and(
          q.eq(q.field("ownerId"), args.ownerId),
          q.eq(q.field("isDeleted"), false)
        )
      )
      .collect();
  },
});

// Get payments by cabinet
export const getPaymentsByCabinet = query({
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
      .query("payments")
      .withIndex("by_cabinet", (q) => q.eq("cabinet", args.cabinet))
      .filter((q) => 
        q.and(
          q.eq(q.field("ownerId"), args.ownerId),
          q.eq(q.field("isDeleted"), false)
        )
      )
      .collect();
  },
});

// Get payments within a date range
export const getPaymentsByDateRange = query({
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
      .query("payments")
      .withIndex("by_date", (q) => q.gte("date", args.startDate))
      .filter((q) => 
        q.and(
          q.eq(q.field("ownerId"), args.ownerId),
          q.lte(q.field("date"), args.endDate),
          q.eq(q.field("isDeleted"), false)
        )
      )
      .collect();
  },
});