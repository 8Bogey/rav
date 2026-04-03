/**
 * Cabinets Mutations for Convex
 * 
 * Handles create, update, and soft-delete operations for generator cabinets.
 */

import { mutation } from "../_generated/server";
import { v } from "convex/values";

export const saveCabinet = mutation({
  args: {
    id: v.optional(v.id("cabinets")),
    convexId: v.optional(v.string()), // Client's local ID or Convex mapping
    version: v.number(),
    ownerId: v.string(),
    name: v.string(),
    letter: v.optional(v.string()),
    totalSubscribers: v.number(),
    currentSubscribers: v.number(),
    collectedAmount: v.number(),
    delayedSubscribers: v.number(),
    completionDate: v.optional(v.number()),
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
    // Accept any authenticated user or demo mode
    // In dev mode, we allow any ownerId that matches the pattern
    const identitySubject = args.ownerId; // Trust the ownerId from the client for now

    const now = Date.now();
    
    // Determine Convex document ID
    // Priority: explicit id > cloudId lookup via index > create new
    let documentId = args.id;
    if (!documentId && args.cloudId) {
      // Use the by_cloudId index for efficient lookup
      const existingByCloudId = await ctx.db
        .query("cabinets")
        .withIndex("by_cloudId", (q) => q.eq("cloudId", args.cloudId!))
        .first();
      
      if (existingByCloudId) {
        documentId = existingByCloudId._id;
      }
    }

    if (documentId) {
      const existing = await ctx.db.get(documentId);
      if (!existing) {
        throw new Error("Not found: Document does not exist");
      }

      if (existing.ownerId !== identitySubject) {
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
      const newId = await ctx.db.insert("cabinets", {
        ...insertData,
        createdAt: now,
        updatedAt: now,
        version: 0,
      });

      return { success: true, id: newId, version: 0 };
    }
  },
});

export const deleteCabinet = mutation({
  args: {
    id: v.id("cabinets"),
    version: v.number(),
    ownerId: v.string(),
  },
  handler: async (ctx, args) => {
    const identitySubject = args.ownerId;

    const existing = await ctx.db.get(args.id);
    if (!existing) {
      throw new Error("Not found: Document does not exist");
    }

    if (existing.ownerId !== identitySubject) {
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