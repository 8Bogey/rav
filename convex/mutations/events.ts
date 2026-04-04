/**
 * Event Mutations for Convex
 * 
 * Implements event-sourced architecture for data synchronization.
 * Events are immutable and append-only, providing a complete audit trail.
 * 
 * Multi-tenancy: ALL queries use by_ownerId_cloudId composite index to ensure
 * strict tenant isolation. No query can access another owner's data.
 */

import { mutation, MutationCtx } from "../_generated/server";
import { v } from "convex/values";

type EventType =
  | 'ENTITY_CREATED'
  | 'ENTITY_UPDATED'
  | 'ENTITY_MOVED_TO_TRASH'
  | 'ENTITY_RESTORED_FROM_TRASH'
  | 'ENTITY_PERMANENTLY_DELETED';

interface SyncEvent {
  ownerId: string;
  eventType: EventType;
  entityType: string;
  entityId: string;
  payload: string;
  version: number;
  occurredAt: number;
  recordedBy: string;
}

/**
 * Record an event in the event log.
 * This is the primary mutation for all data changes in the event-sourced system.
 */
export const recordEvent = mutation({
  args: {
    ownerId: v.string(),
    eventType: v.string(), // 'ENTITY_CREATED', 'ENTITY_UPDATED', 'ENTITY_MOVED_TO_TRASH', 'ENTITY_RESTORED_FROM_TRASH', 'ENTITY_PERMANENTLY_DELETED'
    entityType: v.string(), // 'subscribers', 'cabinets', 'payments', 'workers', etc.
    entityId: v.string(), // The client's UUID for the entity
    payload: v.string(), // JSON serialized event data
    version: v.number(), // Entity version at time of event
    occurredAt: v.number(), // Unix timestamp when event occurred on client
    recordedBy: v.string(), // Device/client identifier
  },
  handler: async (ctx, args) => {
    // Validate payload is valid JSON
    try {
      JSON.parse(args.payload);
    } catch {
      throw new Error("Invalid JSON in payload");
    }

    const now = Date.now();
    
    // Append event to event log (always succeeds - append only)
    const eventId = await ctx.db.insert("eventLog", {
      ...args,
      recordedAt: now,
    });
    
    // Apply event to state tables
    await applyEvent(ctx, args);
    
    return { success: true, eventId, recordedAt: now };
  },
});

/**
 * Internal helper - applies an event to the appropriate state table.
 * This function routes events to their specific handlers based on event type.
 */
async function applyEvent(ctx: MutationCtx, event: SyncEvent) {
  switch (event.eventType) {
    case 'ENTITY_CREATED':
      await handleCreateEvent(ctx, event);
      break;
    case 'ENTITY_UPDATED':
      await handleUpdateEvent(ctx, event);
      break;
    case 'ENTITY_MOVED_TO_TRASH':
      await handleTrashEvent(ctx, event);
      break;
    case 'ENTITY_RESTORED_FROM_TRASH':
      await handleRestoreEvent(ctx, event);
      break;
    case 'ENTITY_PERMANENTLY_DELETED':
      await handlePermanentDeleteEvent(ctx, event);
      break;
    default:
      // Unknown event type - log but don't fail
      console.warn(`Unknown event type: ${event.eventType}`);
  }
}

/**
 * Handle ENTITY_CREATED events.
 * Creates a new document in the appropriate entity table.
 * 
 * Multi-tenancy: Queries with ownerId to prevent cross-tenant access.
 */
async function handleCreateEvent(ctx: MutationCtx, event: SyncEvent) {
  const { entityType, entityId, payload, ownerId, version } = event;
  const data = JSON.parse(payload);
  
  // Check if document already exists (scoped to owner)
  const existing = await ctx.db
    .query(entityType)
    .withIndex("by_ownerId_cloudId", (q: any) => q.eq("ownerId", ownerId).eq("cloudId", entityId))
    .first();
  
  if (existing) {
    // Document exists - this might a replay, skip if version matches
    if (existing.version >= version) {
      return; // Already applied
    }
    // Update with new data
    await ctx.db.patch(existing._id, {
      ...data,
      cloudId: entityId,
      version,
    });
  } else {
    // Create new document
    await ctx.db.insert(entityType, {
      ...data,
      cloudId: entityId,
      ownerId,
      version,
    });
  }
}

/**
 * Handle ENTITY_UPDATED events.
 * Updates an existing document in the appropriate entity table.
 * 
 * Multi-tenancy: Queries with ownerId to prevent cross-tenant access.
 */
async function handleUpdateEvent(ctx: MutationCtx, event: SyncEvent) {
  const { entityType, entityId, payload, ownerId, version } = event;
  const data = JSON.parse(payload);
  
  // Find the document scoped to owner
  const existing = await ctx.db
    .query(entityType)
    .withIndex("by_ownerId_cloudId", (q: any) => q.eq("ownerId", ownerId).eq("cloudId", entityId))
    .first();
  
  if (!existing) {
    // Document doesn't exist - might need to create it
    console.warn(`Entity not found for update: ${entityType}/${entityId}`);
    return;
  }
  
  // LWW: Only apply if incoming version is newer
  if (version <= existing.version) {
    return; // Stale version, skip
  }
  
  await ctx.db.patch(existing._id, {
    ...data,
    version,
  });
}

/**
 * Handle ENTITY_MOVED_TO_TRASH events.
 * Marks an entity as being in trash (soft delete with trash semantics).
 * 
 * Multi-tenancy: Queries with ownerId to prevent cross-tenant access.
 */
async function handleTrashEvent(ctx: MutationCtx, event: SyncEvent) {
  const { entityType, entityId, ownerId, version } = event;
  
  // Find the document scoped to owner
  const existing = await ctx.db
    .query(entityType)
    .withIndex("by_ownerId_cloudId", (q: any) => q.eq("ownerId", ownerId).eq("cloudId", entityId))
    .first();
  
  if (!existing) {
    console.warn(`Entity not found for trash: ${entityType}/${entityId}`);
    return;
  }
  
  // LWW: Only apply if incoming version is newer
  if (version <= existing.version) {
    return;
  }
  
  // Mark as in trash (state machine: active → inTrash)
  await ctx.db.patch(existing._id, {
    inTrash: true,
    trashMovedAt: event.occurredAt,
    version,
  });
}

/**
 * Handle ENTITY_RESTORED_FROM_TRASH events.
 * Restores an entity from trash back to active state.
 * 
 * Multi-tenancy: Queries with ownerId to prevent cross-tenant access.
 */
async function handleRestoreEvent(ctx: MutationCtx, event: SyncEvent) {
  const { entityType, entityId, ownerId, version } = event;
  
  // Find the document scoped to owner
  const existing = await ctx.db
    .query(entityType)
    .withIndex("by_ownerId_cloudId", (q: any) => q.eq("ownerId", ownerId).eq("cloudId", entityId))
    .first();
  
  if (!existing) {
    console.warn(`Entity not found for restore: ${entityType}/${entityId}`);
    return;
  }
  
  // LWW: Only apply if incoming version is newer
  if (version <= existing.version) {
    return;
  }
  
  // Restore from trash (state machine: inTrash → active)
  await ctx.db.patch(existing._id, {
    inTrash: false,
    trashMovedAt: undefined,
    version,
  });
}

/**
 * Handle ENTITY_PERMANENTLY_DELETED events.
 * Actually removes the document from the database (hard delete).
 * 
 * Multi-tenancy: Queries with ownerId to prevent cross-tenant access.
 */
async function handlePermanentDeleteEvent(ctx: MutationCtx, event: SyncEvent) {
  const { entityType, entityId, ownerId } = event;
  
  // Find the document scoped to owner
  const existing = await ctx.db
    .query(entityType)
    .withIndex("by_ownerId_cloudId", (q: any) => q.eq("ownerId", ownerId).eq("cloudId", entityId))
    .first();
  
  if (existing) {
    // Actually delete the document
    await ctx.db.delete(existing._id);
  }
}
