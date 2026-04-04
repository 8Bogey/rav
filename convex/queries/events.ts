/**
 * Event Queries for Convex
 * 
 * Queries for retrieving events from the event log for down-sync.
 * All queries enforce authentication and tenant isolation.
 */

import { query } from "../_generated/server";
import { v } from "convex/values";

/**
 * Get all events for an owner since a given timestamp.
 * Used for down-sync to pull events from Convex to the local database.
 */
export const getEventsSince = query({
  args: {
    ownerId: v.string(),
    since: v.number(), // Unix timestamp
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) { throw new Error("Unauthenticated"); }
    if (args.ownerId !== identity.subject) { return []; }

    return await ctx.db
      .query("eventLog")
      .withIndex("by_ownerId_occurredAt", (q) => 
        q.eq("ownerId", args.ownerId).gt("occurredAt", args.since)
      )
      .collect();
  },
});

/**
 * Get events for a specific entity type and ID.
 * Used for debugging and audit purposes.
 */
export const getEventsForEntity = query({
  args: {
    ownerId: v.string(),
    entityType: v.string(),
    entityId: v.string(),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) { throw new Error("Unauthenticated"); }
    if (args.ownerId !== identity.subject) { return []; }

    return await ctx.db
      .query("eventLog")
      .withIndex("by_entityType_entityId", (q) => 
        q.eq("entityType", args.entityType).eq("entityId", args.entityId)
      )
      .filter((q) => q.eq(q.field("ownerId"), args.ownerId))
      .collect();
  },
});

/**
 * Get the latest event for an entity (to determine current state).
 */
export const getLatestEventForEntity = query({
  args: {
    ownerId: v.string(),
    entityType: v.string(),
    entityId: v.string(),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) { throw new Error("Unauthenticated"); }
    if (args.ownerId !== identity.subject) { return null; }

    const events = await ctx.db
      .query("eventLog")
      .withIndex("by_entityType_entityId", (q) => 
        q.eq("entityType", args.entityType).eq("entityId", args.entityId)
      )
      .filter((q) => q.eq(q.field("ownerId"), args.ownerId))
      .collect();
    
    if (events.length === 0) return null;
    
    // Return the event with the highest version
    return events.reduce((latest, event) => 
      event.version > latest.version ? event : latest
    );
  },
});

/**
 * Get event count for an owner (for monitoring).
 */
export const getEventCount = query({
  args: {
    ownerId: v.string(),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) { throw new Error("Unauthenticated"); }
    if (args.ownerId !== identity.subject) { return { count: 0 }; }

    const events = await ctx.db
      .query("eventLog")
      .withIndex("by_ownerId", (q) => q.eq("ownerId", args.ownerId))
      .collect();
    
    return { count: events.length };
  },
});
