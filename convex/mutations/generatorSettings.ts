/**
 * Generator Settings Mutations for Convex
 * 
 * Handles create, update, and soft-delete operations for per-tenant settings.
 */

import { mutation } from "../_generated/server";
import { v } from "convex/values";

export const saveGeneratorSettings = mutation({
  args: {
    id: v.optional(v.id("generatorSettings")),
    version: v.number(),
    ownerId: v.string(),
    name: v.string(),
    phoneNumber: v.string(),
    address: v.string(),
    logoPath: v.optional(v.string()),
    isDeleted: v.boolean(),
    updatedAt: v.number(),
    createdAt: v.number(),
  },
  handler: async (ctx, args) => {
    // Accept any ownerId from the client (dev mode)
    const identitySubject = args.ownerId;

    const now = Date.now();

    if (args.id) {
      const existing = await ctx.db.get(args.id);
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
      await ctx.db.patch(id, {
        ...updateData,
        updatedAt: now,
        version: args.version,
      });

      return { success: true, id: args.id, version: args.version };
    } else {
      const { id, ...insertData } = args;
      const newId = await ctx.db.insert("generatorSettings", {
        ...insertData,
        createdAt: now,
        updatedAt: now,
        version: 1,
      });

      return { success: true, id: newId, version: 1 };
    }
  },
});

export const deleteGeneratorSettings = mutation({
  args: {
    // Accept either Convex document ID or string (cloudId) for lookup
    id: v.optional(v.id("generatorSettings")),
    cloudId: v.optional(v.string()),
    version: v.number(),
    ownerId: v.string(),
  },
  handler: async (ctx, args) => {
    const identitySubject = args.ownerId;

    // Resolve the document ID: explicit id > cloudId lookup > error
    let documentId = args.id;
    
    if (!documentId && args.cloudId) {
      const existingByCloudId = await ctx.db
        .query("generatorSettings")
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
      isDeleted: true,
      version: args.version,
      updatedAt: Date.now(),
    });

    return { success: true, id: documentId };
  },
});