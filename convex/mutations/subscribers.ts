/**
 * Subscribers Mutations for Convex
 * 
 * Handles create, update, and soft-delete operations for subscribers.
 * All operations enforce:
 * - Authentication
 * - Tenant isolation (ownerId)
 * - LWW conflict resolution (version check)
 * - Soft deletes only
 */

import { mutation } from "../_generated/server";
import { v } from "convex/values";

export const saveSubscriber = mutation({
  args: {
    syncId: v.string(),
    version: v.number(),
    ownerId: v.string(),
    name: v.string(),
    code: v.string(),
    cabinet: v.string(),
    phone: v.string(),
    status: v.number(),
    startDate: v.number(),
    accumulatedDebt: v.number(),
    tags: v.optional(v.string()),
    notes: v.optional(v.string()),
    lastModified: v.optional(v.number()),
    lastSyncedAt: v.optional(v.number()),
    syncStatus: v.optional(v.string()),
    dirtyFlag: v.optional(v.boolean()),
    cloudId: v.optional(v.string()),
    deletedLocally: v.optional(v.boolean()),
    permissionsMask: v.optional(v.string()),
    isDeleted: v.boolean(),
    updatedAt: v.number(),
    createdAt: v.number(),
  },
  handler: async (ctx, args) => {
    // 1. Authenticate Request
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated: Please log in to continue");
    }

    // 2. Tenant Isolation: Only owner can modify their data
    if (args.ownerId !== identity.subject) {
      throw new Error("Unauthorized: Cannot modify another tenant's data");
    }

    const now = Date.now();

    // 3. UPSERT PATTERN: Find existing by syncId instead of using Convex ID
    const existing = await ctx.db
      .query("subscribers")
      .withIndex("by_syncId", (q) => q.eq("syncId", args.syncId))
      .first();

    if (existing) {
      // UPDATE: Check version is newer (LWW conflict resolution)
      if (args.version <= existing.version) {
        return { 
          success: false, 
          reason: "stale_version",
          currentVersion: existing.version 
        };
      }

      // Update existing document
      await ctx.db.patch(existing._id, {
        ...args,
        updatedAt: now,
        version: args.version,
      });
      
      return { success: true, id: existing._id, version: args.version };
    } else {
      // CREATE: Insert new document
      const newId = await ctx.db.insert("subscribers", {
        ...args,
        createdAt: now,
        updatedAt: now,
        version: 0, // Initial version for new documents
      });
      
      return { success: true, id: newId, version: 0 };
    }
  },
});

export const deleteSubscriber = mutation({
  args: {
    syncId: v.string(),
    version: v.number(),
    ownerId: v.string(),
  },
  handler: async (ctx, args) => {
    // 1. Authenticate
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated: Please log in to continue");
    }

    // 2. Tenant Isolation
    if (args.ownerId !== identity.subject) {
      throw new Error("Unauthorized: Cannot delete another tenant's data");
    }

    // 3. Find existing by syncId
    const existing = await ctx.db
      .query("subscribers")
      .withIndex("by_syncId", (q) => q.eq("syncId", args.syncId))
      .first();
      
    if (!existing) {
      return { success: false, reason: "not_found" };
    }

    // LWW Conflict Resolution
    if (args.version <= existing.version) {
      return { 
        success: false, 
        reason: "stale_version",
        currentVersion: existing.version 
      };
    }

    // Soft Delete: Set isDeleted = true instead of actual DELETE
    await ctx.db.patch(existing._id, {
      isDeleted: true,
      version: args.version,
      updatedAt: Date.now(),
    });

    return { success: true, id: existing._id };
  },
});

// Bulk operations for sync
export const bulkSaveSubscribers = mutation({
  args: {
    subscribers: v.array(v.object({
      syncId: v.string(),
      version: v.number(),
      ownerId: v.string(),
      name: v.string(),
      code: v.string(),
      cabinet: v.string(),
      phone: v.string(),
      status: v.number(),
      startDate: v.number(),
      accumulatedDebt: v.number(),
      tags: v.optional(v.string()),
      notes: v.optional(v.string()),
      lastModified: v.optional(v.number()),
      lastSyncedAt: v.optional(v.number()),
      syncStatus: v.optional(v.string()),
      dirtyFlag: v.optional(v.boolean()),
      cloudId: v.optional(v.string()),
      deletedLocally: v.optional(v.boolean()),
      permissionsMask: v.optional(v.string()),
      isDeleted: v.boolean(),
      updatedAt: v.number(),
      createdAt: v.number(),
    })),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated");
    }

    const results: { success: boolean; id?: string; error?: string }[] = [];
    const now = Date.now();

    for (const subscriber of args.subscribers) {
      if (subscriber.ownerId !== identity.subject) {
        results.push({ success: false, error: "Unauthorized" });
        continue;
      }

      // UPSERT PATTERN: Find by syncId
      const existing = await ctx.db
        .query("subscribers")
        .withIndex("by_syncId", (q) => q.eq("syncId", subscriber.syncId))
        .first();

      if (existing) {
        if (subscriber.version > existing.version) {
          await ctx.db.patch(existing._id, { ...subscriber, updatedAt: now });
          results.push({ success: true, id: existing._id });
        } else {
          results.push({ success: false, error: "stale_version" });
        }
      } else {
        const newId = await ctx.db.insert("subscribers", { ...subscriber, createdAt: now, updatedAt: now, version: 0 });
        results.push({ success: true, id: newId });
      }
    }

    return results;
  },
});