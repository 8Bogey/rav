# ============================================================================
# EPIC 1: rav-infrastructure — Project Infrastructure & Dependency Migration
# ============================================================================

bd create "EPIC: Project Infrastructure & Dependency Migration" --description="Upgrade Drift/SQLite + add Convex dependencies. Update pubspec.yaml, configure Convex project backend. This is the foundational epic that all other migration work depends on." -t epic -p 0 --json

bd create "Add Convex Flutter SDK dependency" --description="Add convex_flutter SDK to pubspec.yaml. Resolve any freezed_annotation conflicts. Configure Convex deployment URL and project credentials in .env file (replacing SUPABASE_URL and SUPABASE_ANON_KEY)." -t task -p 0 --deps "descendant:EPIC: Project Infrastructure & Dependency Migration" --json

bd create "Initialize Convex project backend" --description="Create a new Convex project via npx convex init. Set up the convex/ directory with schema.ts, configure deployment settings. Create initial project structure: convex/schema.ts, convex/_generated/, convex/mutations/, convex/queries/." -t task -p 0 --deps "descendant:EPIC: Project Infrastructure & Dependency Migration" --json

bd create "Update .env and environment configuration" --description="Replace SUPABASE_URL and SUPABASE_ANON_KEY in .env with CONVEX_URL and CONVEX_DEPLOY_KEY. Create new ConvexConfig class mirroring the pattern in lib/core/supabase/supabase_config.dart." -t task -p 1 --deps "descendant:EPIC: Project Infrastructure & Dependency Migration" --json

# ============================================================================
# EPIC 2: rav-convex-schema — Convex Backend Schema & Server Functions
# ============================================================================

bd create "EPIC: Convex Backend Schema & Server Functions" --description="Design and implement the entire Convex backend: document schemas for all 7 entities, mutations, queries, and real-time subscriptions. Includes multi-tenancy ownerId enforcement and soft deletes." -t epic -p 0 --json

bd create "Design Convex document schema for all entities" --description="Convert all Drift tables (Subscribers, Cabinets, Payments, Workers, AuditLog, WhatsAppTemplates, GeneratorSettings) into Convex document schemas in convex/schema.ts. Add ownerId for multi-tenancy. Add _version for conflict resolution. Add isDeleted for soft deletes." -t task -p 0 --deps "descendant:EPIC: Convex Backend Schema & Server Functions" --json

bd create "Implement Convex mutations and Soft Delete Logic" --description="Create convex/mutations/*.ts for CRUD operations. All mutations must validate identity.subject == ownerId. Implement version increment on every write for LWW conflict resolution. Update/Delete should only set isDeleted=true." -t feature -p 0 --deps "descendant:EPIC: Convex Backend Schema & Server Functions" --json

bd create "Implement Convex queries & real-time subscriptions" --description="Create convex/queries/ with query files for each entity. All queries filter by ownerId AND isDeleted == false. Implement cursor-based pagination for large datasets." -t feature -p 0 --deps "descendant:EPIC: Convex Backend Schema & Server Functions" --json

# ============================================================================
# EPIC 3: rav-drift-schema — Drift Local Database Refactoring
# ============================================================================

bd create "EPIC: Drift Local Database Layer" --description="Update existing Drift tables to match Convex UUIDs, implement Outbox table for offline-first writes, and add sync metadata fields." -t epic -p 0 --json

bd create "Update Drift Primary Keys to UUIDs" --description="Change the primary key 'id' in all Drift tables from IntColumn (auto-increment) to TextColumn (String). This is required to match Convex string IDs natively." -t task -p 0 --deps "descendant:EPIC: Drift Local Database Layer" --json

bd create "Add Sync Metadata to all Drift tables" --description="Add columns 'ownerId' (Text), 'version' (Int), 'updatedAt' (DateTime), 'createdAt' (DateTime), and 'isDeleted' (Bool) to all regular Domain tables in Drift." -t task -p 0 --deps "descendant:EPIC: Drift Local Database Layer" --json

bd create "Design Drift Outbox table for offline writes" --description="Create lib/core/database/tables/outbox_table.dart. Fields: id (Text, UUID), tableName (Text), operationType (Text: create/update/delete), documentId (Text), payload (Text JSON), createdAt (DateTime), retryCount (Int), status (Text: pending/failed/synced)." -t task -p 0 --deps "descendant:EPIC: Drift Local Database Layer" --json

bd create "Run build_runner & generate Drift classes" --description="Run flutter pub run build_runner build to update all .g.dart files. Ensure Freezed models and Drift Models are correctly generated without conflicting." -t task -p 0 --deps "descendant:EPIC: Drift Local Database Layer" --json

# ============================================================================
# EPIC 4: rav-sync — Sync Bridge (Drift <-> Convex)
# ============================================================================

bd create "EPIC: Sync Bridge (Drift <-> Convex)" --description="Implement the complete Sync Bridge. Write to Drift+Outbox -> Push to Convex -> Receive real-time Convex updates -> Insert back to Drift." -t epic -p 0 --json

bd create "Implement Outbox Processor (Write Path)" --description="Create lib/core/sync/outbox_processor.dart. Reads pending entries from Drift Outbox in FIFO order. For each: send to Convex via client.mutation(), mark synced on success, increment retryCount on failure." -t feature -p 0 --deps "descendant:EPIC: Sync Bridge (Drift <-> Convex)" --json

bd create "Implement Convex Subscription Listener (Read Path)" --description="Create lib/core/sync/subscription_listener.dart. Subscribes to Convex real-time queries. When data changes, use Drift's insertOnConflictUpdate() to seamlessly apply cloud updates to local DB." -t feature -p 0 --deps "descendant:EPIC: Sync Bridge (Drift <-> Convex)" --json

bd create "Implement Connectivity & Sync Status UI" --description="Stream-based connectivity state (online/offline). Triggers outbox processing on connectivity restore. Add sync dot badge to UI showing pending Outbox counts." -t task -p 1 --deps "descendant:EPIC: Sync Bridge (Drift <-> Convex)" --json

# ============================================================================
# EPIC 5: rav-migration — Data Migration
# ============================================================================

bd create "EPIC: Data Migration (Drift V1 -> Drift V2)" --description="Handle the schema change from integer IDs to UUIDs. Wipe local db and force fresh sync, or migrate via script." -t epic -p 0 --json

bd create "Build Local DB Wipe Strategy (Simplest)" --description="Since the schema changes from Int to String for IDs, the easiest Local-First strategy is to wipe the old SQLite file locally and let the Sync Bridge rebuild it from Convex." -t task -p 0 --deps "descendant:EPIC: Data Migration (Drift V1 -> Drift V2)" --json

bd create "Build Supabase-to-Convex Cloud Migration Script" --description="Create a standalone Node.js script that reads all records from PostgreSQL (Supabase), generates new UUIDs, maps relational integer FKs to new UUIDs, and inserts into Convex." -t feature -p 1 --deps "descendant:EPIC: Data Migration (Drift V1 -> Drift V2)" --json

# ============================================================================
# EPIC 6: rav-services — Service Layer Refactoring
# ============================================================================

bd create "EPIC: Service Layer & Provider Refactoring" --description="Update DAOs to write to Outbox, support UUIDs, and expose reactive streams to the UI." -t epic -p 1 --json

bd create "Refactor Subscriptions & Payments DAOs for Outbox" --description="Rewrite update/insert methods in SubscribersDao and PaymentsDao to always perform a transaction that updates the main table AND inserts a record into the OutboxTable simultaneously." -t task -p 1 --deps "descendant:EPIC: Service Layer & Provider Refactoring" --json

bd create "Refactor all DAOs to filter Soft Deletes" --description="Update all watch() stream queries in every DAO to add a where clause: isDeleted.equals(false). Ensure the UI never displays deleted items." -t task -p 1 --deps "descendant:EPIC: Service Layer & Provider Refactoring" --json

# ============================================================================
# EPIC 7: rav-auth-rbac — Auth, Multi-tenancy & RBAC
# ============================================================================

bd create "EPIC: Auth, Multi-tenancy & RBAC" --description="Implement Convex authentication, ownerId scoping on all databases, and role-based permissions (Admin vs Worker)." -t epic -p 0 --json

bd create "Implement ownerId tenant isolation dynamically" --description="Modify all Drift DAO streams to enforce `.ownerId.equals(currentUser.id)`. Ensure no tenant sees another tenant's data." -t task -p 0 --deps "descendant:EPIC: Auth, Multi-tenancy & RBAC" --json

bd create "Refactor Worker role-based assignments" --description="AssignedWorkerId filtering. Workers only see Cabinets/Subscribers assigned to them. Admins see everything. Sync Bridge adjusts subscriptions based on roles." -t feature -p 1 --deps "descendant:EPIC: Auth, Multi-tenancy & RBAC" --json

Write-Host "New Drift-centric issues created successfully (21 tasks total)."
