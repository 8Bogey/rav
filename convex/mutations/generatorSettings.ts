/**
 * Generator Settings Mutations for Convex
 * 
 * Handles create, update, and soft-delete operations for per-tenant settings.
 */

import { mutation } from "../_generated/server";
import { v } from "convex/values";
import { validatePermission, Permission } from "../auth/rbac";

export const saveGeneratorSettings = mutation({
  args: {
    id: v.optional(v.id("generatorSettings")),
    version: v.number(),
    ownerId: v.string(),
    name: v.string(),
    phoneNumber: v.string(),
    address: v.string(),
    logoPath: v.optional(v.string()),
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
    await validatePermission(ctx, identitySubject, Permission.settingsWrite);

    // If client provided ownerId, validate it matches auth identity
    if (args.ownerId !== identitySubject) {
      throw new Error("Unauthorized");
    }

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
      // Enforce singleton: check if settings already exist for this owner
      const existingSettings = await ctx.db
        .query("generatorSettings")
        .withIndex("by_ownerId", (q) => q.eq("ownerId", identitySubject))
        .first();

      if (existingSettings) {
        // Update existing instead of creating new
        const { id, ...updateData } = args;
        await ctx.db.patch(existingSettings._id, {
          ...updateData,
          updatedAt: now,
          version: existingSettings.version + 1,
        });
        return { success: true, id: existingSettings._id, version: existingSettings.version + 1 };
      }

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
    // Server-side auth: get real identity, never trust client-provided ownerId
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) { throw new Error("Unauthenticated"); }
    const identitySubject = identity.subject;

    // RBAC validation
    await validatePermission(ctx, identitySubject, Permission.settingsWrite);

    // If client provided ownerId, validate it matches auth identity
    if (args.ownerId !== identitySubject) {
      throw new Error("Unauthorized");
    }

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
      inTrash: true,
      version: args.version,
      updatedAt: Date.now(),
    });

    return { success: true, id: documentId };
  },
});