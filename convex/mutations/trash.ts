/**
 * Trash Mutations for Convex
 * 
 * Handles trash operations: move to trash, restore, permanent delete.
 */

import { mutation } from "../_generated/server";
import { v } from "convex/values";

const TRASH_EXPIRY_DAYS = 30;
const MS_PER_DAY = 24 * 60 * 60 * 1000;

/**
 * Move an entity to trash.
 * This creates a trash record and marks the entity as inTrash.
 */
export const moveToTrash = mutation({
  args: {
    ownerId: v.string(),
    entityType: v.string(),
    entityId: v.string(),
    entityData: v.string(), // JSON snapshot
    deletedBy: v.string(),
  },
  handler: async (ctx, args) => {
    const now = Date.now();
    const expiresAt = now + (TRASH_EXPIRY_DAYS * MS_PER_DAY);

    // Create trash record
    await ctx.db.insert("trash", {
      ownerId: args.ownerId,
      entityType: args.entityType,
      entityId: args.entityId,
      entityData: args.entityData,
      deletedAt: now,
      deletedBy: args.deletedBy,
      expiresAt,
    });

    // Mark entity as in trash
    const entity = await ctx.db
      .query(args.entityType)
      .withIndex("by_ownerId_cloudId", (q) => q.eq("ownerId", args.ownerId).eq("cloudId", args.entityId))
      .first();

    if (entity) {
      await ctx.db.patch(entity._id, {
        inTrash: true,
        trashMovedAt: now,
      });
    }

    return { success: true, expiresAt };
  },
});

/**
 * Restore an entity from trash.
 */
export const restoreFromTrash = mutation({
  args: {
    ownerId: v.string(),
    entityType: v.string(),
    entityId: v.string(),
  },
  handler: async (ctx, args) => {
    // Find and delete trash record
    const trashItem = await ctx.db
      .query("trash")
      .withIndex("by_ownerId", (q) => q.eq("ownerId", args.ownerId))
      .filter((q) => 
        q.and(
          q.eq(q.field("entityType"), args.entityType),
          q.eq(q.field("entityId"), args.entityId)
        )
      )
      .first();

    if (!trashItem) {
      throw new Error("Trash item not found");
    }

    await ctx.db.delete(trashItem._id);

    // Restore entity
    const entity = await ctx.db
      .query(args.entityType)
      .withIndex("by_ownerId_cloudId", (q) => q.eq("ownerId", args.ownerId).eq("cloudId", args.entityId))
      .first();

    if (entity) {
      await ctx.db.patch(entity._id, {
        inTrash: false,
        trashMovedAt: undefined,
      });
    }

    return { success: true };
  },
});

/**
 * Permanently delete an entity from trash.
 */
export const permanentlyDelete = mutation({
  args: {
    ownerId: v.string(),
    entityType: v.string(),
    entityId: v.string(),
  },
  handler: async (ctx, args) => {
    // Find and delete trash record
    const trashItem = await ctx.db
      .query("trash")
      .withIndex("by_ownerId", (q) => q.eq("ownerId", args.ownerId))
      .filter((q) => 
        q.and(
          q.eq(q.field("entityType"), args.entityType),
          q.eq(q.field("entityId"), args.entityId)
        )
      )
      .first();

    if (trashItem) {
      await ctx.db.delete(trashItem._id);
    }

    // Delete the entity
    const entity = await ctx.db
      .query(args.entityType)
      .withIndex("by_ownerId_cloudId", (q) => q.eq("ownerId", args.ownerId).eq("cloudId", args.entityId))
      .first();

    if (entity) {
      await ctx.db.delete(entity._id);
    }

    return { success: true };
  },
});

/**
 * Empty all trash for an owner.
 */
export const emptyTrash = mutation({
  args: {
    ownerId: v.string(),
  },
  handler: async (ctx, args) => {
    const trashItems = await ctx.db
      .query("trash")
      .withIndex("by_ownerId", (q) => q.eq("ownerId", args.ownerId))
      .collect();

    let deletedCount = 0;
    for (const item of trashItems) {
      // Delete the entity if it exists
      const entity = await ctx.db
        .query(item.entityType)
        .withIndex("by_ownerId_cloudId", (q) => q.eq("ownerId", args.ownerId).eq("cloudId", item.entityId))
        .first();

      if (entity) {
        await ctx.db.delete(entity._id);
      }

      await ctx.db.delete(item._id);
      deletedCount++;
    }

    return { success: true, deletedCount };
  },
});
