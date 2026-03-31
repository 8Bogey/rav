/**
 * Generator Settings Queries for Convex
 */

import { query } from "../_generated/server";
import { v } from "convex/values";

// Get generator settings for the current tenant
export const getGeneratorSettings = query({
  args: {
    ownerId: v.string(),
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
      .query("generatorSettings")
      .withIndex("by_ownerId", (q) => q.eq("ownerId", args.ownerId))
      .filter((q) => q.eq(q.field("isDeleted"), false))
      .take(1);

    return results.length > 0 ? results[0] : null;
  },
});

// Get generator settings by ID
export const getGeneratorSettingsById = query({
  args: {
    ownerId: v.string(),
    id: v.id("generatorSettings"),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated");
    }

    if (args.ownerId !== identity.subject) {
      return null;
    }

    const settings = await ctx.db.get(args.id);
    if (!settings || settings.isDeleted || settings.ownerId !== args.ownerId) {
      return null;
    }

    return settings;
  },
});