/**
 * WhatsApp Templates Queries for Convex
 */

import { query } from "../_generated/server";
import { v } from "convex/values";

// Get all active WhatsApp templates for the current tenant
export const getActiveWhatsappTemplates = query({
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
      .query("whatsappTemplates")
      .withIndex("by_ownerId", (q) => q.eq("ownerId", args.ownerId))
      .filter((q) => q.eq(q.field("isDeleted"), false))
      .collect();
  },
});

// Get WhatsApp templates with pagination
export const getWhatsappTemplatesPaginated = query({
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
      return { templates: [], nextCursor: null };
    }

    const limit = args.limit ?? 50;
    const cursor = args.cursor;

    let query = ctx.db
      .query("whatsappTemplates")
      .withIndex("by_ownerId", (q) => q.eq("ownerId", args.ownerId))
      .filter((q) => q.eq(q.field("isDeleted"), false));

    if (cursor) {
      const doc = await ctx.db.get(cursor as any);
      if (doc) {
        query = query.filter((q) => q.gt(q.field("updatedAt"), doc.updatedAt));
      }
    }

    const templates = await query.take(limit + 1);
    const hasMore = templates.length > limit;
    const nextCursor = hasMore ? templates[limit - 1]._id : null;

    return {
      templates: hasMore ? templates.slice(0, limit) : templates,
      nextCursor,
    };
  },
});

// Get a single WhatsApp template by ID
export const getWhatsappTemplateById = query({
  args: {
    ownerId: v.string(),
    id: v.id("whatsappTemplates"),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated");
    }

    if (args.ownerId !== identity.subject) {
      return null;
    }

    const template = await ctx.db.get(args.id);
    if (!template || template.isDeleted || template.ownerId !== args.ownerId) {
      return null;
    }

    return template;
  },
});

// Get active (isActive = 1) WhatsApp templates
export const getActiveWhatsappTemplatesOnly = query({
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
      .query("whatsappTemplates")
      .withIndex("by_isActive", (q) => q.eq("isActive", 1))
      .filter((q) => 
        q.and(
          q.eq(q.field("ownerId"), args.ownerId),
          q.eq(q.field("isDeleted"), false)
        )
      )
      .collect();
  },
});