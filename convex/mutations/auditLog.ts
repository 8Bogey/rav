/**
 * Audit Log Mutations for Convex
 * 
 * Handles create, update, and soft-delete operations for audit trail entries.
 */

import { mutation } from "../_generated/server";
import { v } from "convex/values";

export const saveAuditLog = mutation({
  args: {
    syncId: v.string(),
    version: v.number(),
    ownerId: v.string(),
    user: v.string(),
    action: v.string(),
    target: v.string(),
    details: v.string(),
    type: v.string(),
    timestamp: v.number(),
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
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated: Please log in to continue");
    }

    if (args.ownerId !== identity.subject) {
      throw new Error("Unauthorized: Cannot modify another tenant's data");
    }

    const now = Date.now();

    // UPSERT PATTERN: Find by syncId
    const existing = await ctx.db
      .query("auditLog")
      .withIndex("by_syncId", (q) => q.eq("syncId", args.syncId))
      .first();

    if (existing) {
      // LWW Conflict Resolution
      if (args.version <= existing.version) {
        return { 
          success: false, 
          reason: "stale_version",
          currentVersion: existing.version 
        };
      }

      await ctx.db.patch(existing._id, {
        ...args,
        updatedAt: now,
        version: args.version,
      });

      return { success: true, id: existing._id, version: args.version };
    } else {
      const newId = await ctx.db.insert("auditLog", {
        ...args,
        createdAt: now,
        updatedAt: now,
        version: 0,
      });

      return { success: true, id: newId, version: 0 };
    }
  },
});

export const deleteAuditLog = mutation({
  args: {
    syncId: v.string(),
    version: v.number(),
    ownerId: v.string(),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated: Please log in to continue");
    }

    if (args.ownerId !== identity.subject) {
      throw new Error("Unauthorized: Cannot delete another tenant's data");
    }

    // Find by syncId
    const existing = await ctx.db
      .query("auditLog")
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

    // Soft Delete
    await ctx.db.patch(existing._id, {
      isDeleted: true,
      version: args.version,
      updatedAt: Date.now(),
    });

    return { success: true, id: existing._id };
  },
});