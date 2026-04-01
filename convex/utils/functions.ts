/**
 * Convex Multi-Tenancy Utilities
 * 
 * Provides reusable wrappers to enforce the Golden Rule:
 * - Automatically inject identity.orgId || identity.subject as tenantId
 * - Handle authentication
 * - Ensure multi-tenant isolation
 * 
 * Usage:
 *   export const getActiveCabinets = withTenantQuery({
 *     args: { ... },  // NO ownerId needed
 *     handler: async (ctx, args, ownerId) => {
 *       // Use ownerId directly - it's already validated
 *       return await ctx.db.query("cabinets")...
 *     }
 *   });
 */

import { query, mutation } from "../_generated/server";
import { GenericExpression, DataModel } from "../_generated/dataModel";

/**
 * Extract tenantId (organization or user) from authenticated identity
 * 
 * Priority: orgId (organization-level) > subject (individual user)
 * This allows multiple workers within a single Buyer's organization to share data.
 */
export async function getTenantId(ctx: { auth: { getUserIdentity: () => Promise<any> } }): Promise<string> {
  const identity = await ctx.auth.getUserIdentity();
  if (!identity) {
    throw new Error("Unauthenticated: Please log in to continue");
  }
  // Use orgId if available (organization-level tenant), otherwise fall back to subject (individual)
  return identity.orgId || identity.subject;
}

/**
 * Extract ownerId from authenticated identity (legacy alias)
 * @deprecated Use getTenantId instead
 */
export async function getOwnerId(ctx: { auth: { getUserIdentity: () => Promise<any> } }): Promise<string> {
  return getTenantId(ctx);
}

/**
 * Verify the caller owns the requested resource
 */
export async function verifyOwnership(
  ctx: { auth: { getUserIdentity: () => Promise<any> } },
  requestedOwnerId: string
): Promise<string> {
  const tenantId = await getTenantId(ctx);
  
  if (requestedOwnerId !== tenantId) {
    throw new Error("Unauthorized: Cannot access another tenant's data");
  }
  
  return tenantId;
}

/**
 * Type for tenant-aware query handlers
 */
type TenantQueryHandler<Args extends Record<string, any>, Return> = (
  ctx: { db: any; auth: { getUserIdentity: () => Promise<any> } },
  args: Args,
  tenantId: string
) => Promise<Return>;

/**
 * Type for tenant-aware mutation handlers
 */
type TenantMutationHandler<Args extends Record<string, any>, Return> = (
  ctx: { db: any; auth: { getUserIdentity: () => Promise<any> } },
  args: Args,
  tenantId: string
) => Promise<Return>;

/**
 * Wrapper for tenant-aware queries
 * 
 * Automatically:
 * - Validates authentication
 * - Injects tenantId from identity.orgId || identity.subject
 * - Provides tenantId to the handler
 * 
 * The handler receives (ctx, args, tenantId) instead of just (ctx, args)
 */
export function withTenantQuery<
  Args extends Record<string, any>,
  Return
>(config: {
  args: Args;
  handler: TenantQueryHandler<Args, Return>;
}) {
  return query({
    args: config.args,
    handler: async (ctx, args) => {
      // Get tenantId from authenticated identity
      const tenantId = await getTenantId(ctx);
      
      // Pass tenantId to the handler
      return await config.handler(ctx, args, tenantId);
    },
  });
}

/**
 * Wrapper for tenant-aware mutations
 * 
 * Automatically:
 * - Validates authentication
 * - Injects tenantId from identity.orgId || identity.subject
 * - Provides tenantId to the handler
 * 
 * The handler receives (ctx, args, tenantId) instead of just (ctx, args)
 */
export function withTenantMutation<
  Args extends Record<string, any>,
  Return
>(config: {
  args: Args;
  handler: TenantMutationHandler<Args, Return>;
}) {
  return mutation({
    args: config.args,
    handler: async (ctx, args) => {
      // Get tenantId from authenticated identity
      const tenantId = await getTenantId(ctx);
      
      // Pass tenantId to the handler
      return await config.handler(ctx, args, tenantId);
    },
  });
}

/**
 * Create a filtered query for tenant data
 * 
 * Usage:
 *   const q = tenantQuery(ctx, "cabinets", ownerId);
 *   const results = await q.filter((q) => q.eq(q.field("isDeleted"), false)).collect();
 */
export function tenantQuery(
  ctx: { db: any },
  tableName: keyof DataModel,
  ownerId: string,
  indexName?: string
): GenericExpression<DataModel[keyof DataModel]> {
  const baseQuery = indexName
    ? ctx.db.query(tableName).withIndex(indexName, (q) => q.eq("ownerId", ownerId))
    : ctx.db.query(tableName).withIndex("by_ownerId", (q) => q.eq("ownerId", ownerId));
  
  return baseQuery;
}

/**
 * Query builder for tenant data with common filters
 */
export class TenantQueryBuilder {
  constructor(
    private ctx: { db: any },
    private tableName: keyof DataModel,
    private ownerId: string
  ) {}

  /**
   * Add ownerId index filter
   */
  byOwnerId(indexName: string = "by_ownerId") {
    return this.ctx.db
      .query(this.tableName)
      .withIndex(indexName, (q) => q.eq("ownerId", this.ownerId));
  }

  /**
   * Add isDeleted = false filter
   */
  excludeDeleted(baseQuery: GenericExpression<DataModel[keyof DataModel]>) {
    return baseQuery.filter((q) => q.eq(q.field("isDeleted"), false));
  }

  /**
   * Create a basic tenant query with owner filter
   */
  create(indexName?: string) {
    return this.byOwnerId(indexName);
  }
}

/**
 * Create a TenantQueryBuilder instance
 */
export function createTenantQuery(
  ctx: { db: any },
  tableName: keyof DataModel,
  ownerId: string
) {
  return new TenantQueryBuilder(ctx, tableName, ownerId);
}
