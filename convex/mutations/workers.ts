/**
 * Workers Mutations for Convex
 * 
 * Handles create, update, and soft-delete operations for workers/collectors.
 */

import { mutation } from "../_generated/server";
import { v } from "convex/values";

export const saveWorker = mutation({
  args: {
    id: v.optional(v.id("workers")),
    version: v.number(),
    ownerId: v.string(),
    name: v.string(),
    phone: v.string(),
    permissions: v.string(),
    todayCollected: v.number(),
    monthTotal: v.number(),
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
    // DEV MODE: Skip auth check - remove for production!
    const identitySubject = "demo-user-001";

    if (args.ownerId != identitySubject) {
      throw new Error("Unauthorized: Cannot modify another tenant's data");
    }

    const now = Date.now();

    if (args.id) {
      const existing = await ctx.db.get(args.id);
      if (!existing) {
        throw new Error("Not found: Document does not exist");
      }

      if (existing.ownerId !== identity.subject) {
        throw new Error("Unauthorized: Cannot modify another tenant's document");
      }

      // LWW Conflict Resolution
      if (args.version <= existing.version) {
        return { 
          success: false, 
          reason: "stale_version",
          currentVersion: existing.version 
        };
      }

      const { id, ...updateData } = args;
      await ctx.db.patch(id, {
        ...updateData,
        updatedAt: now,
        version: args.version,
      });

      return { success: true, id: args.id, version: args.version };
    } else {
      const { id, ...insertData } = args;
      const newId = await ctx.db.insert("workers", {
        ...insertData,
        createdAt: now,
        updatedAt: now,
        version: 0,
      });

      return { success: true, id: newId, version: 0 };
    }
  },
});

export const deleteWorker = mutation({
  args: {
    id: v.id("workers"),
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

    const existing = await ctx.db.get(args.id);
    if (!existing) {
      throw new Error("Not found: Document does not exist");
    }

    if (existing.ownerId !== identity.subject) {
      throw new Error("Unauthorized: Cannot delete another tenant's document");
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
    await ctx.db.patch(args.id, {
      isDeleted: true,
      version: args.version,
      updatedAt: Date.now(),
    });

    return { success: true, id: args.id };
  },
});