---
description: Guide for AI Agents to execute database sync integration (Local-First fixes)
---

# Database Synchronization Repair Guide for AI Agents

This workflow document provides a structured guide for any AI Agent working on resolving the database architectural gaps in this project, specifically the Local-First Drift/Convex sync bridge issues. 

**Context:** The system architecture expects a local-first system using `Drift` for offline local storage and `Convex` for cloud multi-tenant storage. There are currently critical lacks in this synchronization logic.

## Prerequisites
1. Ensure `bd` is correctly tracking issues (use `bd ready --json`).
2. Claim the target Database Issue before starting work:
   - `bd update <ISSUE_ID> --claim --json`
3. Always verify changes using Convex typescript checking (`npm run typecheck` or similar inside the `convex` folder) and Flutter constraints (`flutter analyze`).

---

## Issue 1: Fix ID Mismatch (Drift UUID vs Convex Native IDs)
**Objective:** Prevent sync failures caused by offline-generated UUIDs being rejected by Convex's Native `v.id()` constraints.

### Execution Steps
1. **Schema Update (`convex/schema.ts`):** 
   - Add a `syncId: v.string()` field to ALL tables (`subscribers`, `cabinets`, `payments`, `workers`, `auditLog`, `whatsappTemplates`).
   - Add an index for the `syncId`: `.index("by_syncId", ["syncId"])`
2. **Mutations Update (`convex/mutations/*.ts`):**
   - In all `save[Entity]` and `delete[Entity]` functions, replace `id: v.optional(v.id("table"))` with `syncId: v.string()`.
   - Implement the **Upsert Pattern**:
     ```typescript
     const existing = await ctx.db.query("entityTable")
         .withIndex("by_syncId", q => q.eq("syncId", args.syncId))
         .first();
     ```
   - If `existing` is true, perform a `patch` on `existing._id`.
   - If `existing` is false, perform an `insert`.
   - Make sure LWW conflict resolution (`args.version > existing.version`) is preserved.
3. **Flutter Drift Outbox Payload (`lib/core/sync/convex_sync_processor.dart`):**
   - Ensure the JSON payload correctly maps the Drift string `id` to the new `syncId` field before invoking the Convex mutation.
   ```dart
   final mappedPayload = Map<String, dynamic>.from(payload);
   mappedPayload['syncId'] = entry.documentId; 
   // Adjust as needed depending on existing logic
   ```

---

## Issue 2: Implement Sync Down (Cloud to Local)
**Objective:** Ensure local Drift data isn't stale compared to other devices by actively fetching cloud-born updates.

### Execution Steps
1. **Create Sync Down Engine (`lib/core/sync/sync_down_processor.dart`):**
   - The agent should implement a new Dart class that manages pulling data from Convex.
   - Utilize a "Last Sync Timestamp" approach. Get the highest `updatedAt` value stored locally.
   - Query Convex (using a new query `getChangesSince(timestamp)`) to fetch any documents where `updatedAt > localLastSync`.
2. **Convex Query (`convex/queries/sync.ts`):**
   - Write a Convex `query` that accepts `lastSyncThreshold` and returns modified documents across all relevant tables.
3. **LWW Merge Strategy (Drift):**
   - When updates are fetched, compare the `version` field.
   - For each updated document from the cloud:
     - Check local DB `getById`.
     - If local `version < cloud version`, perform `update()` in Drift.
     - If local `version >= cloud version`, ignore it (local wins or is identical).
4. **Wire It Up:**
   - Integrate `SyncDownProcessor` in the same place where `ConvexSyncProcessor` is initiated (e.g. at app start, when network is restored, or on a polling interval/web socket notification).

---

## Finalizing the Work (Post-Execution)
When you (the agent) complete the integration:
1. Verify no lint limits: `flutter analyze`
2. Validate Convex: Re-run `npx convex dev` to ensure schema definitions patch perfectly.
3. Follow the `bd` Completion instructions:
   ```bash
   git add .
   git commit -m "fix(db): resolve ID mismatch and implement Sync Down"
   bd close <ISSUE_ID> --reason "Implemented schema Upserts and DownSync engines" --json
   bd dolt push
   git push
   ```
