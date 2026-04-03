import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

/**
 * Convex Schema for mawlid_al_dhaki
 * 
 * This schema defines all document collections for the Local-First architecture.
 * Each table includes:
 * - ownerId: Multi-tenant isolation key
 * - version: Last-Write-Wins (LWW) conflict resolution
 * - isDeleted: Soft delete flag
 * 
 * Following the MINIMAX_IMPLEMENTATION_GUIDE.md patterns.
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
    
    // Legacy sync metadata (kept for backward compatibility)
    lastModified: v.optional(v.number()),
    lastSyncedAt: v.optional(v.number()),
    syncStatus: v.optional(v.string()),
    dirtyFlag: v.optional(v.boolean()),
    cloudId: v.optional(v.string()), // Convex document ID for client ID mapping
    deletedLocally: v.optional(v.boolean()),
    permissionsMask: v.optional(v.string()),
    
    // Convex sync metadata (REQUIRED)
    version: v.number(), // LWW conflict resolution
    isDeleted: v.boolean(), // Soft delete flag
    updatedAt: v.number(), // Unix timestamp
    createdAt: v.number(), // Unix timestamp
  })
    .index("by_ownerId", ["ownerId"])
    .index("by_code", ["code"])
    .index("by_cabinet", ["cabinet"])
    .index("by_status", ["status"])
    .index("by_cloudId", ["cloudId"]), // For efficient Convex ID lookup

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
    
    // Legacy sync metadata
    lastModified: v.optional(v.number()),
    lastSyncedAt: v.optional(v.number()),
    syncStatus: v.optional(v.string()),
    dirtyFlag: v.optional(v.boolean()),
    cloudId: v.optional(v.string()),
    deletedLocally: v.optional(v.boolean()),
    permissionsMask: v.optional(v.string()),
    
    // Convex sync metadata
    version: v.number(),
    isDeleted: v.boolean(),
    updatedAt: v.number(),
    createdAt: v.number(),
  })
    .index("by_ownerId", ["ownerId"])
    .index("by_name", ["name"])
    .index("by_letter", ["letter"])
    .index("by_cloudId", ["cloudId"]),

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
    
    // Legacy sync metadata
    lastModified: v.optional(v.number()),
    lastSyncedAt: v.optional(v.number()),
    syncStatus: v.optional(v.string()),
    dirtyFlag: v.optional(v.boolean()),
    cloudId: v.optional(v.string()),
    deletedLocally: v.optional(v.boolean()),
    permissionsMask: v.optional(v.string()),
    
    // Convex sync metadata
    version: v.number(),
    isDeleted: v.boolean(),
    updatedAt: v.number(),
    createdAt: v.number(),
  })
    .index("by_ownerId", ["ownerId"])
    .index("by_subscriberId", ["subscriberId"])
    .index("by_date", ["date"])
    .index("by_worker", ["worker"])
    .index("by_cabinet", ["cabinet"])
    .index("by_cloudId", ["cloudId"]),

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
    
    // Legacy sync metadata
    lastModified: v.optional(v.number()),
    lastSyncedAt: v.optional(v.number()),
    syncStatus: v.optional(v.string()),
    dirtyFlag: v.optional(v.boolean()),
    cloudId: v.optional(v.string()),
    deletedLocally: v.optional(v.boolean()),
    permissionsMask: v.optional(v.string()),
    
    // Convex sync metadata
    version: v.number(),
    isDeleted: v.boolean(),
    updatedAt: v.number(),
    createdAt: v.number(),
  })
    .index("by_ownerId", ["ownerId"])
    .index("by_name", ["name"])
    .index("by_phone", ["phone"])
    .index("by_cloudId", ["cloudId"]),

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
    
    // Legacy sync metadata
    lastModified: v.optional(v.number()),
    lastSyncedAt: v.optional(v.number()),
    syncStatus: v.optional(v.string()),
    dirtyFlag: v.optional(v.boolean()),
    cloudId: v.optional(v.string()),
    deletedLocally: v.optional(v.boolean()),
    permissionsMask: v.optional(v.string()),
    
    // Convex sync metadata
    version: v.number(),
    isDeleted: v.boolean(),
    updatedAt: v.number(),
    createdAt: v.number(),
  })
    .index("by_ownerId", ["ownerId"])
    .index("by_user", ["user"])
    .index("by_target", ["target"])
    .index("by_action", ["action"])
    .index("by_timestamp", ["timestamp"]),

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
    
    // Convex sync metadata
    version: v.number(),
    isDeleted: v.boolean(),
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
    
    // Legacy sync metadata
    lastModified: v.optional(v.number()),
    lastSyncedAt: v.optional(v.number()),
    syncStatus: v.optional(v.string()),
    dirtyFlag: v.optional(v.boolean()),
    cloudId: v.optional(v.string()),
    deletedLocally: v.optional(v.boolean()),
    permissionsMask: v.optional(v.string()),
    
    // Convex sync metadata
    version: v.number(),
    isDeleted: v.boolean(),
    updatedAt: v.number(),
    createdAt: v.number(),
  })
    .index("by_ownerId", ["ownerId"])
    .index("by_isActive", ["isActive"]),
});
