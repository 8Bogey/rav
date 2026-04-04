/**
 * Trash Auto-Delete Cron Job
 * 
 * Runs daily at midnight UTC to permanently delete expired trash items.
 * For each expired trash record:
 * 1. Deletes the original entity (if it still exists)
 * 2. Deletes the trash record
 */

import { cronJobs } from "convex/server";
import { internalAction } from "./_generated/server";

export const cleanExpiredTrash = cronJobs({
  cleanExpiredTrash: {
    cron: "0 0 * * *", // Daily at midnight UTC
    function: "cron:cleanExpiredTrashInternal",
  },
});

export const cleanExpiredTrashInternal = internalAction({
  handler: async (ctx) => {
    const now = Date.now();
    let cleanedCount = 0;

    // Query all expired trash items
    const expiredTrash = await ctx.db
      .query("trash")
      .filter((q) => q.lt(q.field("expiresAt"), now))
      .collect();

    for (const trashItem of expiredTrash) {
      // Delete the original entity if it still exists
      const entity = await ctx.db
        .query(trashItem.entityType)
        .withIndex("by_ownerId_cloudId", (q) =>
          q.eq("ownerId", trashItem.ownerId).eq("cloudId", trashItem.entityId)
        )
        .first();

      if (entity) {
        await ctx.db.delete(entity._id);
      }

      // Delete the trash record
      await ctx.db.delete(trashItem._id);
      cleanedCount++;
    }

    return { success: true, cleanedCount };
  },
});
