/**
 * Role-Based Access Control (RBAC) for Convex
 * 
 * Defines roles and permissions for the application.
 * - Admin: Full access to all data and features
 * - Worker: Limited access, can only see assigned data
 */

import { query, mutation } from "../_generated/server";
import { v } from "convex/values";

/**
 * Predefined roles
 */
export const Role = {
  admin: "admin",
  worker: "worker",
} as const;

export type RoleType = typeof Role[keyof typeof Role];

/**
 * Predefined permissions
 */
export const Permission = {
  // Subscribers
  subscribersRead: "subscribers:read",
  subscribersWrite: "subscribers:write",
  subscribersDelete: "subscribers:delete",
  
  // Cabinets
  cabinetsRead: "cabinets:read",
  cabinetsWrite: "cabinets:write",
  cabinetsDelete: "cabinets:delete",
  
  // Payments
  paymentsRead: "payments:read",
  paymentsWrite: "payments:write",
  paymentsDelete: "payments:delete",
  
  // Workers
  workersRead: "workers:read",
  workersWrite: "workers:write",
  workersDelete: "workers:delete",
  
  // Reports
  reportsRead: "reports:read",
  reportsExport: "reports:export",
  
  // Settings
  settingsRead: "settings:read",
  settingsWrite: "settings:write",
  
  // Users (Admin only)
  usersManage: "users:manage",
  
  // Audit
  auditRead: "audit:read",
} as const;

export type PermissionType = typeof Permission[keyof typeof Permission];

/**
 * Default permissions by role
 */
export const defaultPermissions: Record<RoleType, PermissionType[]> = {
  [Role.admin]: [
    Permission.subscribersRead,
    Permission.subscribersWrite,
    Permission.subscribersDelete,
    Permission.cabinetsRead,
    Permission.cabinetsWrite,
    Permission.cabinetsDelete,
    Permission.paymentsRead,
    Permission.paymentsWrite,
    Permission.paymentsDelete,
    Permission.workersRead,
    Permission.workersWrite,
    Permission.workersDelete,
    Permission.reportsRead,
    Permission.reportsExport,
    Permission.settingsRead,
    Permission.settingsWrite,
    Permission.usersManage,
    Permission.auditRead,
  ],
  [Role.worker]: [
    Permission.subscribersRead,
    Permission.paymentsRead,
    Permission.paymentsWrite,
    Permission.cabinetsRead,
    Permission.reportsRead,
  ],
};

/**
 * Check if user has permission
 * Returns true if user has the specific permission or is an admin
 */
export async function hasPermission(
  ctx: any,
  ownerId: string,
  permission: PermissionType
): Promise<boolean> {
  // Get worker by ownerId
  const workers = await ctx.db
    .query("workers")
    .withIndex("by_ownerId", (q: any) => q.eq("ownerId", ownerId))
    .take(1);

  if (workers.length === 0) {
    // No worker record means admin - has all permissions
    return true;
  }

  const worker = workers[0];
  const permissions = worker.permissions 
    ? JSON.parse(worker.permissions) 
    : [];

  // Admin has all permissions
  if (permissions.includes("*")) {
    return true;
  }

  return permissions.includes(permission);
}

/**
 * Filter documents based on user's role and permissions
 * Workers can only see their assigned data
 */
export async function filterByRole(
  ctx: any,
  ownerId: string,
  tableName: string,
  role: RoleType
): Promise<any> {
  // Admins see all their tenant's data
  if (role === Role.admin) {
    return ctx.db
      .query(tableName)
      .withIndex("by_ownerId", (q: any) => q.eq("ownerId", ownerId))
      .filter((q: any) => q.eq(q.field("isDeleted"), false));
  }

  // Workers need additional filtering based on assignment
  // This would need additional fields in the schema (e.g., assignedCabinetIds)
  return ctx.db
    .query(tableName)
    .withIndex("by_ownerId", (q: any) => q.eq("ownerId", ownerId))
    .filter((q: any) => q.eq(q.field("isDeleted"), false));
}

/**
 * Get user's role based on worker record
 */
export async function getUserRole(
  ctx: any,
  ownerId: string
): Promise<RoleType> {
  const workers = await ctx.db
    .query("workers")
    .withIndex("by_ownerId", (q: any) => q.eq("ownerId", ownerId))
    .take(1);

  // If no worker record, user is an admin
  if (workers.length === 0) {
    return Role.admin;
  }

  const worker = workers[0];
  
  // Check if worker has admin permissions (either explicit or wildcard)
  const permissions = worker.permissions 
    ? JSON.parse(worker.permissions) 
    : [];
  
  if (permissions.includes("*") || permissions.includes(Permission.usersManage)) {
    return Role.admin;
  }

  return Role.worker;
}

/**
 * Validate permission and throw if not allowed
 */
export async function validatePermission(
  ctx: any,
  ownerId: string,
  permission: PermissionType
): Promise<void> {
  const hasAccess = await hasPermission(ctx, ownerId, permission);
  if (!hasAccess) {
    throw new Error(`Permission denied: ${permission}`);
  }
}