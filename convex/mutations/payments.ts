/**
 * Payments Mutations for Convex
 * 
 * Handles create, update, and soft-delete operations for payment records.
 */

import { mutation } from "../_generated/server";
import { v } from "convex/values";
import { validatePermission, Permission } from "../auth/rbac";

export const savePayment = mutation({
  args: {
    id: v.optional(v.string()), // Accept string for both Convex IDs and client UUIDs
    convexId: v.optional(v.string()), // Client's local ID or Convex mapping
    version: v.number(),
    ownerId: v.string(),
    subscriberId: v.id("subscribers"),
    amount: v.number(),
    worker: v.id("workers"),
    date: v.number(),
    cabinet: v.id("cabinets"),
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
    // Server-side auth: get real identity
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) { throw new Error("Unauthenticated"); }
    const identitySubject = identity.subject;

    // RBAC validation
    await validatePermission(ctx, identitySubject, Permission.paymentsWrite);

    if (args.amount <= 0) throw new Error("Payment amount must be positive");

    const now = Date.now();
    
    // Validate subscriber reference exists and belongs to same owner
    const subscriberDoc = await ctx.db.get(args.subscriberId);
    if (!subscriberDoc) {
      throw new Error("Referenced subscriber does not exist");
    }
    if (subscriberDoc.ownerId !== identitySubject) {
      throw new Error("Referenced subscriber does not belong to this owner");
    }

    // Validate worker reference exists and belongs to same owner
    const workerDoc = await ctx.db.get(args.worker);
    if (!workerDoc) {
      throw new Error("Referenced worker does not exist");
    }
    if (workerDoc.ownerId !== identitySubject) {
      throw new Error("Referenced worker does not belong to this owner");
    }

    // Validate cabinet reference exists and belongs to same owner
    const cabinetDoc = await ctx.db.get(args.cabinet);
    if (!cabinetDoc) {
      throw new Error("Referenced cabinet does not exist");
    }
    if (cabinetDoc.ownerId !== identitySubject) {
      throw new Error("Referenced cabinet does not belong to this owner");
    }
    
    // Determine Convex document ID
    // Priority: explicit id > cloudId lookup via index > create new
    let documentId: any = null;

    if (args.id) {
      // Check if it's a Convex document ID format (starts with table name)
      if (args.id.startsWith('payments/')) {
        documentId = args.id; // It's a Convex document ID
      } else {
        // It's a client UUID - look up by cloudId index
        const existingByCloudId = await ctx.db
          .query("payments")
          .withIndex("by_cloudId", (q) => q.eq("cloudId", args.id!))
          .first();

        if (existingByCloudId) {
          documentId = existingByCloudId._id;
        }
      }
    } else if (args.cloudId) {
      // Fallback: use cloudId lookup
      const existingByCloudId = await ctx.db
        .query("payments")
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
      const newId = await ctx.db.insert("payments", {
        ...insertData,
        cloudId: args.cloudId,
        createdAt: now,
        updatedAt: now,
        version: 1,
      });

      return { success: true, id: newId, version: 1 };
    }
  },
});

export const deletePayment = mutation({
  args: {
    // Accept either Convex document ID or string (cloudId) for lookup
    id: v.optional(v.string()),
    cloudId: v.optional(v.string()),
    version: v.number(),
    ownerId: v.string(),
  },
  handler: async (ctx, args) => {
    // Server-side auth: get real identity
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) { throw new Error("Unauthenticated"); }
    const identitySubject = identity.subject;

    // RBAC validation
    await validatePermission(ctx, identitySubject, Permission.paymentsDelete);

    // Resolve the document ID: explicit id > cloudId lookup > error
    let documentId: any = null;

    if (args.id) {
      // Check if it's a Convex document ID format (starts with table name)
      if (args.id.startsWith('payments/')) {
        documentId = args.id; // It's a Convex document ID
      } else {
        // It's a client UUID - look up by cloudId index
        const existingByCloudId = await ctx.db
          .query("payments")
          .withIndex("by_cloudId", (q) => q.eq("cloudId", args.id!))
          .first();

        if (existingByCloudId) {
          documentId = existingByCloudId._id;
        }
      }
    } else if (args.cloudId) {
      // Fallback: use cloudId lookup
      const existingByCloudId = await ctx.db
        .query("payments")
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