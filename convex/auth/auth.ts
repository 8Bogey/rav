/**
 * Convex Authentication Handlers
 * 
 * Handles user authentication and session management.
 * Uses Convex's built-in authentication with JWT.
 */

import { query, mutation } from "../_generated/server";
import { v } from "convex/values";

/**
 * Get the current authenticated user
 */
export const getCurrentUser = query({
  args: {},
  handler: async (ctx) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      return null;
    }

    return {
      id: identity.subject,
      email: identity.email,
      name: identity.name,
    };
  },
});

/**
 * Get user profile from database
 */
export const getUserProfile = query({
  args: {},
  handler: async (ctx) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      return null;
    }

    // Query user profile from the workers table (assuming workers are users)
    const workers = await ctx.db
      .query("workers")
      .withIndex("by_ownerId", (q) => q.eq("ownerId", identity.subject))
      .take(1);

    if (workers.length === 0) {
      // Return basic profile if no worker record exists
      return {
        id: identity.subject,
        email: identity.email,
        name: identity.name,
        role: "admin", // Default role
        permissions: [],
      };
    }

    const worker = workers[0];
    return {
      id: worker._id,
      ownerId: worker.ownerId,
      name: worker.name,
      phone: worker.phone,
      permissions: worker.permissions ? JSON.parse(worker.permissions) : [],
      role: "worker",
    };
  },
});

/**
 * Verify user has specific permission
 */
export const hasPermission = query({
  args: {
    permission: v.string(),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      return false;
    }

    // Get worker's permissions
    const workers = await ctx.db
      .query("workers")
      .withIndex("by_ownerId", (q) => q.eq("ownerId", identity.subject))
      .take(1);

    if (workers.length === 0) {
      // Admins have all permissions
      return true;
    }

    const permissions = workers[0].permissions 
      ? JSON.parse(workers[0].permissions) 
      : [];

    return permissions.includes(args.permission) || permissions.includes("*");
  },
});

/**
 * List all users (workers) for the current tenant
 */
export const listUsers = query({
  args: {},
  handler: async (ctx) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      return [];
    }

    const workers = await ctx.db
      .query("workers")
      .withIndex("by_ownerId", (q) => q.eq("ownerId", identity.subject))
      .filter((q) => q.eq(q.field("isDeleted"), false))
      .collect();

    return workers.map((w) => ({
      id: w._id,
      name: w.name,
      phone: w.phone,
      permissions: w.permissions ? JSON.parse(w.permissions) : [],
    }));
  },
});

/**
 * Create user (worker) - Admin only
 */
export const createUser = mutation({
  args: {
    name: v.string(),
    phone: v.string(),
    permissions: v.array(v.string()),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated");
    }

    // The ownerId should be the current user's subject (tenant ID)
    const ownerId = identity.subject;

    // Create worker record
    const workerId = await ctx.db.insert("workers", {
      ownerId,
      name: args.name,
      phone: args.phone,
      permissions: JSON.stringify(args.permissions),
      todayCollected: 0,
      monthTotal: 0,
      isDeleted: false,
      version: 0,
      updatedAt: Date.now(),
      createdAt: Date.now(),
    });

    return { success: true, id: workerId };
  },
});

/**
 * Update user (worker) permissions - Admin only
 */
export const updateUserPermissions = mutation({
  args: {
    workerId: v.id("workers"),
    permissions: v.array(v.string()),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated");
    }

    const worker = await ctx.db.get(args.workerId);
    if (!worker) {
      throw new Error("Worker not found");
    }

    // Verify ownership
    if (worker.ownerId !== identity.subject) {
      throw new Error("Unauthorized: Cannot modify another tenant's worker");
    }

    await ctx.db.patch(args.workerId, {
      permissions: JSON.stringify(args.permissions),
      version: worker.version + 1,
      updatedAt: Date.now(),
    });

    return { success: true };
  },
});

/**
 * Delete user (soft delete) - Admin only
 */
export const deleteUser = mutation({
  args: {
    workerId: v.id("workers"),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated");
    }

    const worker = await ctx.db.get(args.workerId);
    if (!worker) {
      throw new Error("Worker not found");
    }

    // Verify ownership
    if (worker.ownerId !== identity.subject) {
      throw new Error("Unauthorized: Cannot delete another tenant's worker");
    }

    // Soft delete
    await ctx.db.patch(args.workerId, {
      isDeleted: true,
      version: worker.version + 1,
      updatedAt: Date.now(),
    });

    return { success: true };
  },
});