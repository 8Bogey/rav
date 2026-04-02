import { query } from "../_generated/server";
import { v } from "convex/values";

/**
 * Fetch all documents modified after a given timestamp, for a specific tenant.
 * Used for Cloud-to-Local synchronization (Sync Down).
 */
export const getChangesSince = query({
  args: {
    lastSyncThreshold: v.number(),
    ownerId: v.string(), // Provide ownerId explicitly for tenant isolation
  },
  handler: async (ctx, args) => {
    // Authenticate
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated: Please log in to continue");
    }

    // Verify ownership
    if (args.ownerId !== identity.subject) {
      throw new Error("Unauthorized: Cannot fetch another tenant's data");
    }

    // We query each table for updates after lastSyncThreshold
    // Note: To make this highly efficient, an index on ["ownerId", "updatedAt"] would be ideal,
    // but we can fallback to filtering by ownerId and then updatedAt if index isn't available.

    const [
      subscribers,
      cabinets,
      payments,
      workers,
      auditLog,
      generatorSettings,
      whatsappTemplates
    ] = await Promise.all([
      ctx.db.query("subscribers")
        .withIndex("by_ownerId", (q) => q.eq("ownerId", args.ownerId))
        .filter((q) => q.gt(q.field("updatedAt"), args.lastSyncThreshold))
        .collect(),
      ctx.db.query("cabinets")
        .withIndex("by_ownerId", (q) => q.eq("ownerId", args.ownerId))
        .filter((q) => q.gt(q.field("updatedAt"), args.lastSyncThreshold))
        .collect(),
      ctx.db.query("payments")
        .withIndex("by_ownerId", (q) => q.eq("ownerId", args.ownerId))
        .filter((q) => q.gt(q.field("updatedAt"), args.lastSyncThreshold))
        .collect(),
      ctx.db.query("workers")
        .withIndex("by_ownerId", (q) => q.eq("ownerId", args.ownerId))
        .filter((q) => q.gt(q.field("updatedAt"), args.lastSyncThreshold))
        .collect(),
      ctx.db.query("auditLog")
        .withIndex("by_ownerId", (q) => q.eq("ownerId", args.ownerId))
        .filter((q) => q.gt(q.field("updatedAt"), args.lastSyncThreshold))
        .collect(),
      ctx.db.query("generatorSettings")
        .withIndex("by_ownerId", (q) => q.eq("ownerId", args.ownerId))
        .filter((q) => q.gt(q.field("updatedAt"), args.lastSyncThreshold))
        .collect(),
      ctx.db.query("whatsappTemplates")
        .withIndex("by_ownerId", (q) => q.eq("ownerId", args.ownerId))
        .filter((q) => q.gt(q.field("updatedAt"), args.lastSyncThreshold))
        .collect(),
    ]);

    return {
      subscribers,
      cabinets,
      payments,
      workers,
      auditLog,
      generatorSettings,
      whatsappTemplates,
    };
  },
});
