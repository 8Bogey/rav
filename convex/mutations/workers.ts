/**
 * Workers Mutations for Convex
 * 
 * Handles create, update, and soft-delete operations for workers/collectors.
 */

import { mutation } from "../_generated/server";
import { v } from "convex/values";
import { validatePermission, Permission } from "../auth/rbac";

export const saveWorker = mutation({
  args: {
    id: v.optional(v.string()), // Accept string for both Convex IDs and client UUIDs
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
    inTrash: v.boolean(),
    updatedAt: v.number(),
    createdAt: v.number(),
  },
  handler: async (ctx, args) => {
    // Server-side auth: get real identity, never trust client-provided ownerId
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) { throw new Error("Unauthenticated"); }
    const identitySubject = identity.subject;

    // RBAC validation
    await validatePermission(ctx, identitySubject, Permission.workersWrite);

    // If client provided ownerId, validate it matches auth identity
    if (args.ownerId !== identitySubject) {
      throw new Error("Unauthorized");
    }

    if (args.todayCollected < 0) throw new Error("Today collected cannot be negative");
    if (args.monthTotal < 0) throw new Error("Month total cannot be negative");

    const now = Date.now();
    
    // Determine Convex document ID
    // Priority: explicit id > cloudId lookup via index > create new
    let documentId = args.id;
    if (!documentId && args.cloudId) {
      // Use the by_cloudId index for efficient lookup
      const existingByCloudId = await ctx.db
        .query("workers")
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

      const { id, ...updateData } = args;
      await ctx.db.patch(documentId, {
        ...updateData,
        updatedAt: now,
        version: args.version,
      });

      return { success: true, id: documentId, version: args.version };
    } else {
      const { id, ...insertData } = args;
      const newId = await ctx.db.insert("workers", {
        ...insertData,
        cloudId: args.cloudId ?? null,
        createdAt: now,
        updatedAt: now,
        version: 1,
      });

      return { success: true, id: newId, version: 1 };
    }
  },
});

export const deleteWorker = mutation({
  args: {
    // Accept either Convex document ID or string (cloudId) for lookup
    id: v.optional(v.string()),
    cloudId: v.optional(v.string()),
    version: v.number(),
    ownerId: v.string(),
  },
  handler: async (ctx, args) => {
    // Server-side auth: get real identity, never trust client-provided ownerId
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) { throw new Error("Unauthenticated"); }
    const identitySubject = identity.subject;

    // RBAC validation
    await validatePermission(ctx, identitySubject, Permission.workersDelete);

    // If client provided ownerId, validate it matches auth identity
    if (args.ownerId !== identitySubject) {
      throw new Error("Unauthorized");
    }

    // Resolve the document ID: explicit id > cloudId lookup > error
    let documentId: any = null;

    if (args.id) {
      // Check if it's a Convex document ID format (starts with table name)
      if (args.id.startsWith('workers/')) {
        documentId = args.id; // It's a Convex document ID
      } else {
        // It's a client UUID - look up by cloudId index
        const existingByCloudId = await ctx.db
          .query("workers")
          .withIndex("by_cloudId", (q) => q.eq("cloudId", args.id!))
          .first();

        if (existingByCloudId) {
          documentId = existingByCloudId._id;
        }
      }
    } else if (args.cloudId) {
      // Fallback: use cloudId lookup
      const existingByCloudId = await ctx.db
        .query("workers")
        .withIndex("by_cloudId", (q) => q.eq("cloudId", args.cloudId!))
        .first();

      if (existingByCloudId) {
        documentId = existingByCloudId._id;
      }
    }

    if (!documentId) {
      throw new Error("Not found: Document ID or cloudId required");
    }

    const existing = await ctx.db.get(documentId);
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
    await ctx.db.patch(documentId, {
      inTrash: true,
      version: args.version,
      updatedAt: Date.now(),
    });

    return { success: true, id: documentId };
  },
});