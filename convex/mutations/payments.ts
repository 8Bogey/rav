/**
 * Payments Mutations for Convex
 * 
 * Handles create, update, and soft-delete operations for payment records.
 */

import { mutation } from "../_generated/server";
import { v } from "convex/values";

export const savePayment = mutation({
  args: {
    id: v.optional(v.id("payments")),
    convexId: v.optional(v.string()), // Client's local ID or Convex mapping
    version: v.number(),
    ownerId: v.string(),
    subscriberId: v.string(),
    amount: v.number(),
    worker: v.string(),
    date: v.number(),
    cabinet: v.string(),
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
    
    // Determine Convex document ID
    let documentId = args.id;
    if (!documentId && args.cloudId && /^[a-z0-9]{12,}$/.test(args.cloudId)) {
      documentId = args.cloudId as any;
    }

    if (documentId) {
      const existing = await ctx.db.get(documentId);
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

      const { id, convexId, ...updateData } = args;
      await ctx.db.patch(documentId, {
        ...updateData,
        updatedAt: now,
        version: args.version,
      });

      return { success: true, id: documentId, version: args.version };
    } else {
      const { id, convexId, ...insertData } = args;
      const newId = await ctx.db.insert("payments", {
        ...insertData,
        createdAt: now,
        updatedAt: now,
        version: 0,
      });

      return { success: true, id: newId, version: 0 };
    }
  },
});

export const deletePayment = mutation({
  args: {
    id: v.id("payments"),
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