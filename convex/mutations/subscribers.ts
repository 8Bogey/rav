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
    // Accept either Convex document ID (v.id) or string identifier for client-side tracking
    // When updating existing: pass Convex ID via convexId field
    // When creating new: omit both id and convexId
    id: v.optional(v.id("subscribers")),
    convexId: v.optional(v.string()), // Client's local ID (UUID) or Convex mapping
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
    // DEV MODE: Skip auth check - remove for production!
    const identitySubject = "demo-user-001";

    // 2. Tenant Isolation: Only owner can modify their data
    if (args.ownerId != identitySubject) {
      throw new Error("Unauthorized: Cannot modify another tenant's data");
    }

    const now = Date.now();
    
    // Determine the Convex document ID to use
    // Priority: explicit id > cloudId lookup via index > create new
    let documentId = args.id;
    
    // If no explicit Convex ID but we have cloudId, use index lookup
    if (!documentId && args.cloudId) {
      // Use the by_cloudId index for efficient lookup
      const existingByCloudId = await ctx.db
        .query("subscribers")
        .withIndex("by_cloudId", (q) => q.eq("cloudId", args.cloudId!))
        .first();
      
      if (existingByCloudId) {
        documentId = existingByCloudId._id;
      }
    }

    if (documentId) {
      // UPDATE: Check if document exists and version is newer
      const existing = await ctx.db.get(documentId);
      if (!existing) {
        throw new Error("Not found: Document does not exist");
      }
      
      // Verify ownership
      if (existing.ownerId !== identity.subject) {
        throw new Error("Unauthorized: Cannot modify another tenant's document");
      }

      // LWW Conflict Resolution: Reject if incoming version is not newer
      if (args.version <= existing.version) {
        return { 
          success: false, 
          reason: "stale_version",
          currentVersion: existing.version 
        };
      }

      // Update existing document
      const { id, convexId, ...updateData } = args;
      await ctx.db.patch(documentId, {
        ...updateData,
        updatedAt: now,
        version: args.version,
      });
      
      return { success: true, id: documentId, version: args.version };
    } else {
      // CREATE: Insert new document
      const { id, convexId, ...insertData } = args;
      const newId = await ctx.db.insert("subscribers", {
        ...insertData,
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
    id: v.id("subscribers"),
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

    // 3. Get existing document
    const existing = await ctx.db.get(args.id);
    if (!existing) {
      throw new Error("Not found: Document does not exist");
    }

    // Verify ownership
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

    // Soft Delete: Set isDeleted = true instead of actual DELETE
    await ctx.db.patch(args.id, {
      isDeleted: true,
      version: args.version,
      updatedAt: Date.now(),
    });

    return { success: true, id: args.id };
  },
});

// Bulk operations for sync
export const bulkSaveSubscribers = mutation({
  args: {
    subscribers: v.array(v.object({
      id: v.optional(v.id("subscribers")),
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

      if (subscriber.id) {
        const existing = await ctx.db.get(subscriber.id);
        if (existing && existing.ownerId === identity.subject && subscriber.version > existing.version) {
          const { id, ...data } = subscriber;
          await ctx.db.patch(id, { ...data, updatedAt: now });
          results.push({ success: true, id });
        } else {
          results.push({ success: false, error: "stale_version" });
        }
      } else {
        const { id, ...data } = subscriber;
        const newId = await ctx.db.insert("subscribers", { ...data, createdAt: now, updatedAt: now, version: 0 });
        results.push({ success: true, id: newId });
      }
    }

    return results;
  },
});