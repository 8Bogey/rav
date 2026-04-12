import { mutation } from "../_generated/server";
import { v } from "convex/values";

/**
 * Upsert a user profile from Auth0 identity.
 * Called on every login to sync user info from JWT to Convex.
 * Creates the user on first login, updates on subsequent logins.
 */
export const upsertUser = mutation({
  args: {
    email: v.optional(v.string()),
    name: v.optional(v.string()),
    picture: v.optional(v.string()),
    role: v.optional(v.union(v.literal("admin"), v.literal("worker"))),
    permissions: v.optional(v.array(v.string())),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Not authenticated");
    }

    // SECURITY: Use identity.subject from JWT, not caller-supplied auth0Id
    const now = Date.now();
    const existing = await ctx.db
      .query("users")
      .withIndex("by_auth0Id", (q) => q.eq("auth0Id", identity.subject))
      .first();

    if (existing) {
      // Update existing user
      await ctx.db.patch(existing._id, {
        email: args.email ?? existing.email,
        name: args.name ?? existing.name,
        picture: args.picture ?? existing.picture,
        role: args.role ?? existing.role,
        permissions: args.permissions ?? existing.permissions,
        updatedAt: now,
      });
      return { _id: existing._id, created: false };
    } else {
      // Create new user
      const userId = await ctx.db.insert("users", {
        auth0Id: identity.subject,
        email: args.email,
        name: args.name,
        picture: args.picture,
        role: args.role ?? "worker",
        permissions: args.permissions ?? [],
        createdAt: now,
        updatedAt: now,
      });
      return { _id: userId, created: true };
    }
  },
});

/**
 * Get the current user's profile and permissions.
 */
export const getCurrentUser = mutation({
  args: {},
  handler: async (ctx) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      return null;
    }

    const user = await ctx.db
      .query("users")
      .withIndex("by_auth0Id", (q) => q.eq("auth0Id", identity.subject))
      .first();

    return user;
  },
});
