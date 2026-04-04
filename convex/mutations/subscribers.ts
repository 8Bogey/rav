/**
 * Subscribers Mutations for Convex
 * 
 * Handles create, update, and soft-delete operations for subscribers.
 * All operations enforce:
 * - Authentication (server-side identity, never trust client ownerId)
 * - Tenant isolation (ownerId)
 * - LWW conflict resolution (version check)
 * - Soft deletes only
 * - Referential integrity (cabinet must exist and belong to same owner)
 */

import { mutation } from "../_generated/server";
import { v } from "convex/values";
import { validatePermission, Permission } from "../auth/rbac";

export const saveSubscriber = mutation({
  args: {
    // Accept either Convex document ID (v.id) or string identifier for client-side tracking
    // When updating existing: pass Convex ID via convexId field
    // When creating new: omit both id and convexId
    id: v.optional(v.string()), // Accept string for both Convex IDs and client UUIDs
    convexId: v.optional(v.string()), // Client's local ID (UUID) or Convex mapping
    version: v.number(),
    ownerId: v.string(),
    name: v.string(),
    code: v.string(),
    cabinet: v.id("cabinets"),
    phone: v.string(),
    status: v.union(v.literal("inactive"), v.literal("active"), v.literal("suspended"), v.literal("disconnected")),
    startDate: v.number(),
    accumulatedDebt: v.number(),
    tags: v.optional(v.array(v.string())),
    notes: v.nullable(v.string()), // Allow null for notes
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
    await validatePermission(ctx, identitySubject, Permission.subscribersWrite);

    // If client provided ownerId, validate it matches auth identity
    if (args.ownerId !== identitySubject) {
      throw new Error("Unauthorized");
    }

    const now = Date.now();
    
    // Validate numeric fields
    if (args.accumulatedDebt < 0) throw new Error("Debt cannot be negative");
    
    // Validate cabinet reference exists and belongs to same owner
    const cabinetDoc = await ctx.db.query("cabinets").withIndex("by_ownerId_cloudId", (q) => q.eq("ownerId", identitySubject).eq("cloudId", args.cabinet)).first();
    if (!cabinetDoc) {
      throw new Error("Referenced cabinet does not exist");
    }
    
    // Determine the Convex document ID to use
    // Priority: explicit id > cloudId lookup via index > create new
    let documentId: any = null;

    if (args.id) {
      // Check if it's a Convex document ID format (starts with table name)
      if (args.id.startsWith('subscribers/')) {
        documentId = args.id; // It's a Convex document ID
      } else {
        // It's a client UUID - look up by cloudId index
        const existingByCloudId = await ctx.db
          .query("subscribers")
          .withIndex("by_cloudId", (q) => q.eq("cloudId", args.id!))
          .first();

        if (existingByCloudId) {
          documentId = existingByCloudId._id;
        }
      }
    } else if (args.cloudId) {
      // Fallback: use cloudId lookup
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
      if (existing.ownerId !== identitySubject) {
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
      // IMPORTANT: Persist cloudId so delete lookups work later
      const { id, convexId, ...insertData } = args;
      const newId = await ctx.db.insert("subscribers", {
        ...insertData,
        cloudId: args.cloudId, // Persist the client's local UUID
        createdAt: now,
        updatedAt: now,
        version: 1, // Match Drift default version
      });
      
      return { success: true, id: newId, version: 1 };
    }
  },
});

export const deleteSubscriber = mutation({
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
    await validatePermission(ctx, identitySubject, Permission.subscribersDelete);

    // If client provided ownerId, validate it matches auth identity
    if (args.ownerId !== identitySubject) {
      throw new Error("Unauthorized");
    }

    // Resolve the document ID: explicit id > cloudId lookup > error
    let documentId: any = null;

    if (args.id) {
      // Check if it's a Convex document ID format (starts with table name)
      if (args.id.startsWith('subscribers/')) {
        documentId = args.id; // It's a Convex document ID
      } else {
        // It's a client UUID - look up by cloudId index
        const existingByCloudId = await ctx.db
          .query("subscribers")
          .withIndex("by_cloudId", (q) => q.eq("cloudId", args.id!))
          .first();

        if (existingByCloudId) {
          documentId = existingByCloudId._id;
        }
      }
    } else if (args.cloudId) {
      // Fallback: use cloudId lookup
      const existingByCloudId = await ctx.db
        .query("subscribers")
        .withIndex("by_cloudId", (q) => q.eq("cloudId", args.cloudId!))
        .first();

      if (existingByCloudId) {
        documentId = existingByCloudId._id;
      }
    }

    if (!documentId) {
      throw new Error("Not found: Document ID or cloudId required");
    }

    // Get existing document
    const existing = await ctx.db.get(documentId);
    if (!existing) {
      throw new Error("Not found: Document does not exist");
    }

    // Verify ownership
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

    // Soft Delete: Set inTrash = true instead of actual DELETE
    await ctx.db.patch(documentId, {
      inTrash: true,
      version: args.version,
      updatedAt: Date.now(),
    });

    return { success: true, id: documentId };
  },
});

// Bulk operations for sync
export const bulkSaveSubscribers = mutation({
  args: {
    subscribers: v.array(v.object({
      id: v.optional(v.string()),
      version: v.number(),
      ownerId: v.string(),
      name: v.string(),
      code: v.string(),
    cabinet: v.string(),
      phone: v.string(),
      status: v.union(v.literal("inactive"), v.literal("active"), v.literal("suspended"), v.literal("disconnected")),
      startDate: v.number(),
      accumulatedDebt: v.number(),
      tags: v.optional(v.array(v.string())),
      notes: v.nullable(v.string()), // Allow null for notes
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

      // Validate cabinet reference exists and belongs to same owner
      try {
        const cabinetDoc = await ctx.db.query("cabinets").withIndex("by_ownerId_cloudId", (q) => q.eq("ownerId", identity.subject).eq("cloudId", subscriber.cabinet)).first();
        if (!cabinetDoc) {
          results.push({ success: false, error: "Referenced cabinet does not exist" });
          continue;
        }
      } catch {
        results.push({ success: false, error: "Invalid cabinet reference" });
        continue;
      }

      let documentId: any = null;

      if (subscriber.id) {
        // Check if it's a Convex document ID format
        if (subscriber.id.startsWith('subscribers/')) {
          documentId = subscriber.id; // It's a Convex document ID
        } else {
          // It's a client UUID - look up by cloudId index
          const existingByCloudId = await ctx.db
            .query("subscribers")
            .withIndex("by_cloudId", (q) => q.eq("cloudId", subscriber.id!))
            .first();

          if (existingByCloudId) {
            documentId = existingByCloudId._id;
          }
        }
      }

      if (documentId) {
        const existing = await ctx.db.get(documentId);
        if (existing && existing.ownerId === identity.subject && subscriber.version > existing.version) {
          const { id, ...data } = subscriber;
          await ctx.db.patch(documentId, { ...data, updatedAt: now });
          results.push({ success: true, id: documentId });
        } else {
          results.push({ success: false, error: "stale_version" });
        }
      } else {
        const { id, ...data } = subscriber;
        const newId = await ctx.db.insert("subscribers", { ...data, createdAt: now, updatedAt: now, version: 1 });
        results.push({ success: true, id: newId });
      }
    }

    return results;
  },
});
