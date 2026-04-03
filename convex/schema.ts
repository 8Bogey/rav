import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

/**
 * Convex Schema for mawlid_al_dhaki
 * 
 * This schema defines all document collections for the Local-First architecture.
 * Each table includes:
 * - ownerId: Multi-tenant isolation key
 * - cloudId: Client-side UUID for entity mapping
 * - version: Last-Write-Wins (LWW) conflict resolution
 * - inTrash/trashMovedAt: Trash state machine fields
 * 
 * State machine: active (default) → inTrash=true (soft delete) → permanently deleted (removed from DB)
 */
export default defineSchema({
  // ============================================================
  // SUBSCRIBERS - Entity representing electricity subscribers
  // ============================================================
  subscribers: defineTable({
    // Multi-tenant isolation (CRITICAL)
    ownerId: v.string(),
    
    // Domain Data
    name: v.string(),
    code: v.string(), // Unique subscriber code
    cabinet: v.string(),
    phone: v.string(),
    status: v.number(), // 0: inactive, 1: active, 2: suspended, 3: disconnected
    startDate: v.number(), // Unix timestamp
    accumulatedDebt: v.number(),
    tags: v.nullable(v.string()), // Stored as comma-separated or JSON
    notes: v.nullable(v.string()), // Allow null for notes
    
    // Entity identification
    cloudId: v.string(), // Client-side UUID for entity mapping
    
    // Trash state machine
    inTrash: v.optional(v.boolean()),
    trashMovedAt: v.optional(v.number()),
    
    // Convex sync metadata
    version: v.number(), // LWW conflict resolution
    isDeleted: v.optional(v.boolean()), // Legacy: use inTrash instead
    updatedAt: v.number(), // Unix timestamp
    createdAt: v.number(), // Unix timestamp
  })
    .index("by_ownerId", ["ownerId"])
    .index("by_code", ["code"])
    .index("by_cabinet", ["cabinet"])
    .index("by_status", ["status"])
    .index("by_cloudId", ["cloudId"]) // For efficient Convex ID lookup
    .index("by_ownerId_cloudId", ["ownerId", "cloudId"]), // Multi-tenant safe lookup

  // ============================================================
  // CABINETS - Generator cabinets/zones
  // ============================================================
  cabinets: defineTable({
    // Multi-tenant isolation
    ownerId: v.string(),
    
    // Domain Data
    name: v.string(),
    letter: v.optional(v.string()), // Cabinet letter (A, B, C, etc.)
    totalSubscribers: v.number(),
    currentSubscribers: v.number(),
    collectedAmount: v.number(),
    delayedSubscribers: v.number(),
    completionDate: v.nullable(v.number()), // Unix timestamp - allow null
    
    // Entity identification
    cloudId: v.string(),
    
    // Trash state machine
    inTrash: v.optional(v.boolean()),
    trashMovedAt: v.optional(v.number()),
    
    // Convex sync metadata
    version: v.number(),
    isDeleted: v.optional(v.boolean()), // Legacy: use inTrash instead
    updatedAt: v.number(),
    createdAt: v.number(),
  })
    .index("by_ownerId", ["ownerId"])
    .index("by_name", ["name"])
    .index("by_letter", ["letter"])
    .index("by_cloudId", ["cloudId"])
    .index("by_ownerId_cloudId", ["ownerId", "cloudId"]),

  // ============================================================
  // PAYMENTS - Payment records for subscribers
  // ============================================================
  payments: defineTable({
    // Multi-tenant isolation
    ownerId: v.string(),
    
    // Domain Data
    subscriberId: v.string(), // UUID reference to subscriber
    amount: v.number(),
    worker: v.string(), // Worker who collected the payment
    date: v.number(), // Unix timestamp
    cabinet: v.string(),
    
    // Entity identification
    cloudId: v.string(),
    
    // Trash state machine
    inTrash: v.optional(v.boolean()),
    trashMovedAt: v.optional(v.number()),
    
    // Convex sync metadata
    version: v.number(),
    isDeleted: v.optional(v.boolean()), // Legacy: use inTrash instead
    updatedAt: v.number(),
    createdAt: v.number(),
  })
    .index("by_ownerId", ["ownerId"])
    .index("by_subscriberId", ["subscriberId"])
    .index("by_date", ["date"])
    .index("by_worker", ["worker"])
    .index("by_cabinet", ["cabinet"])
    .index("by_cloudId", ["cloudId"])
    .index("by_ownerId_cloudId", ["ownerId", "cloudId"]),

  // ============================================================
  // WORKERS - Staff/collectors with roles and permissions
  // ============================================================
  workers: defineTable({
    // Multi-tenant isolation
    ownerId: v.string(),
    
    // Domain Data
    name: v.string(),
    phone: v.string(),
    permissions: v.string(), // JSON string of permissions
    todayCollected: v.number(),
    monthTotal: v.number(),
    
    // Entity identification
    cloudId: v.string(),
    
    // Trash state machine
    inTrash: v.optional(v.boolean()),
    trashMovedAt: v.optional(v.number()),
    
    // Convex sync metadata
    version: v.number(),
    isDeleted: v.optional(v.boolean()), // Legacy: use inTrash instead
    updatedAt: v.number(),
    createdAt: v.number(),
  })
    .index("by_ownerId", ["ownerId"])
    .index("by_name", ["name"])
    .index("by_phone", ["phone"])
    .index("by_cloudId", ["cloudId"])
    .index("by_ownerId_cloudId", ["ownerId", "cloudId"]),

  // ============================================================
  // AUDIT_LOG - Financial compliance audit trail
  // ============================================================
  auditLog: defineTable({
    // Multi-tenant isolation
    ownerId: v.string(),
    
    // Domain Data
    user: v.string(),
    action: v.string(),
    target: v.string(),
    details: v.string(),
    type: v.string(),
    timestamp: v.number(), // Unix timestamp
    
    // Entity identification
    cloudId: v.string(),
    
    // Trash state machine
    inTrash: v.optional(v.boolean()),
    trashMovedAt: v.optional(v.number()),
    
    // Convex sync metadata
    version: v.number(),
    isDeleted: v.optional(v.boolean()), // Legacy: use inTrash instead
    updatedAt: v.number(),
    createdAt: v.number(),
  })
    .index("by_ownerId", ["ownerId"])
    .index("by_user", ["user"])
    .index("by_target", ["target"])
    .index("by_action", ["action"])
    .index("by_timestamp", ["timestamp"])
    .index("by_cloudId", ["cloudId"])
    .index("by_ownerId_cloudId", ["ownerId", "cloudId"]),

  // ============================================================
  // GENERATOR_SETTINGS - Per-tenant singleton settings
  // ============================================================
  generatorSettings: defineTable({
    // Multi-tenant isolation
    ownerId: v.string(),
    
    // Domain Data
    name: v.string(),
    phoneNumber: v.string(),
    address: v.string(),
    logoPath: v.optional(v.string()),
    
    // Trash state machine
    inTrash: v.optional(v.boolean()),
    trashMovedAt: v.optional(v.number()),
    
    // Convex sync metadata
    version: v.number(),
    isDeleted: v.optional(v.boolean()), // Legacy: use inTrash instead
    updatedAt: v.number(),
    createdAt: v.number(),
  })
    .index("by_ownerId", ["ownerId"]),

  // ============================================================
  // WHATSAPP_TEMPLATES - Message templates for WhatsApp bridge
  // ============================================================
  whatsappTemplates: defineTable({
    // Multi-tenant isolation
    ownerId: v.string(),
    
    // Domain Data
    title: v.string(),
    content: v.string(),
    isActive: v.number(), // 0 or 1
    
    // Entity identification
    cloudId: v.string(),
    
    // Trash state machine
    inTrash: v.optional(v.boolean()),
    trashMovedAt: v.optional(v.number()),
    
    // Convex sync metadata
    version: v.number(),
    isDeleted: v.optional(v.boolean()), // Legacy: use inTrash instead
    updatedAt: v.number(),
    createdAt: v.number(),
  })
    .index("by_ownerId", ["ownerId"])
    .index("by_isActive", ["isActive"])
    .index("by_cloudId", ["cloudId"])
    .index("by_ownerId_cloudId", ["ownerId", "cloudId"]),

  // ============================================================
  // EVENT_LOG - Append-only event log for event-sourced sync
  // ============================================================
  // This table is the source of truth for all data changes.
  // Events are immutable and never deleted (kept forever for audit trail).
  eventLog: defineTable({
    // Multi-tenant isolation
    ownerId: v.string(),
    
    // Event metadata
    eventType: v.string(), // 'ENTITY_CREATED', 'ENTITY_UPDATED', 'ENTITY_MOVED_TO_TRASH', 'ENTITY_RESTORED_FROM_TRASH', 'ENTITY_PERMANENTLY_DELETED'
    entityType: v.string(), // 'subscribers', 'cabinets', 'payments', 'workers', etc.
    entityId: v.string(), // The client's UUID for the entity
    payload: v.string(), // JSON serialized event data
    
    // Versioning and timing
    version: v.number(), // Entity version at time of event
    occurredAt: v.number(), // Unix timestamp when event occurred on client
    recordedAt: v.number(), // Unix timestamp when event was recorded in Convex
    recordedBy: v.string(), // Device/client identifier (e.g., device UUID)
  })
    .index("by_ownerId", ["ownerId"])
    .index("by_entityType_entityId", ["entityType", "entityId"])
    .index("by_occurredAt", ["occurredAt"])
    .index("by_ownerId_occurredAt", ["ownerId", "occurredAt"]),

  // ============================================================
  // TRASH - Bin for soft-deleted items before permanent deletion
  // ============================================================
  // Items in trash auto-delete after 30 days via cron job.
  trash: defineTable({
    // Multi-tenant isolation
    ownerId: v.string(),
    
    // Trash metadata
    entityType: v.string(), // 'subscribers', 'cabinets', 'payments', 'workers'
    entityId: v.string(), // The client's UUID
    entityData: v.string(), // JSON snapshot of entity when moved to trash
    deletedAt: v.number(), // Unix timestamp when moved to trash
    deletedBy: v.string(), // User/device identifier
    expiresAt: v.number(), // Auto-delete after this timestamp (30 days from deletedAt)
  })
    .index("by_ownerId", ["ownerId"])
    .index("by_ownerId_deletedAt", ["ownerId", "deletedAt"])
    .index("by_ownerId_expiresAt", ["ownerId", "expiresAt"]),
});
