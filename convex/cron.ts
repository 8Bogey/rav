/**
 * Scheduled Cron Jobs
 *
 * - cleanExpiredTrash: Daily at midnight UTC — permanently delete expired trash
 * - pruneOldAuditLogs: Daily at 1 AM UTC — delete audit logs older than 90 days
 * - pruneOldEvents: Daily at 2 AM UTC — delete synced event logs older than 30 days
 */

import { cronJobs } from "convex/server";
import { internalAction } from "./_generated/server";

export const scheduled = cronJobs({
  cleanExpiredTrash: {
    cron: "0 0 * * *", // Daily at midnight UTC
    function: "cron:cleanExpiredTrashInternal",
  },
  pruneOldAuditLogs: {
    cron: "0 1 * * *", // Daily at 1 AM UTC
    function: "cron:pruneOldAuditLogsInternal",
  },
  pruneOldEvents: {
    cron: "0 2 * * *", // Daily at 2 AM UTC
    function: "cron:pruneOldEventsInternal",
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

/**
 * Prune audit logs older than 90 days.
 * Runs daily at 1 AM UTC.
 */
export const pruneOldAuditLogsInternal = internalAction({
  handler: async (ctx) => {
    const cutoff = Date.now() - 90 * 24 * 60 * 60 * 1000; // 90 days ago
    let deleted = 0;

    // Query all audit logs and filter by timestamp
    const allLogs = await ctx.db.query("auditLog").collect();

    for (const log of allLogs) {
      if (log.timestamp < cutoff) {
        await ctx.db.delete(log._id);
        deleted++;
      }
    }

    return { deleted };
  },
});

/**
 * Prune synced event logs older than 30 days.
 * Runs daily at 2 AM UTC.
 * Only deletes events with "synced" in their eventType to preserve
 * the audit trail for non-synced events.
 */
export const pruneOldEventsInternal = internalAction({
  handler: async (ctx) => {
    const cutoff = Date.now() - 30 * 24 * 60 * 60 * 1000; // 30 days ago
    let deleted = 0;

    // Query all event logs and filter by timestamp + eventType
    const allEvents = await ctx.db.query("eventLog").collect();

    for (const event of allEvents) {
      if (event.occurredAt < cutoff && event.eventType.includes("synced")) {
        await ctx.db.delete(event._id);
        deleted++;
      }
    }

    return { deleted };
  },
});
