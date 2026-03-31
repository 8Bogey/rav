# ============================================================================
# EPIC 1: rav-987 — Project Infrastructure & Dependency Migration
# ============================================================================

bd create "Remove Drift/SQLite dependencies from pubspec.yaml" --description="Remove drift: ^2.18.0, drift_flutter: ^0.1.0, sqlite3_flutter_libs: ^0.5.24 from dependencies. Remove drift_dev: ^2.18.0 from dev_dependencies. Remove build_runner dependency if no longer needed by other generators." -t task -p 0 --deps "discovered-from:rav-987" --json

bd create "Remove Supabase dependency from pubspec.yaml" --description="Remove supabase_flutter: ^2.8.0 from dependencies. This also means removing connectivity_plus: ^6.0.3 if it was only used for Supabase sync monitoring (evaluate if still needed for Convex connectivity checks)." -t task -p 0 --deps "discovered-from:rav-987" --json

bd create "Add Isar dependencies to pubspec.yaml" --description="Add isar: ^3.1.0+1, isar_flutter_libs: ^3.1.0+1 to dependencies. Add isar_generator: ^3.1.0+1 to dev_dependencies. Ensure build_runner is present for code generation. Configure Isar initialization in main.dart." -t task -p 0 --deps "discovered-from:rav-987" --json

bd create "Add Convex Flutter SDK dependency" --description="Add convex_flutter SDK to pubspec.yaml. Research and select the appropriate Convex Dart/Flutter client package. Configure Convex deployment URL and project credentials in .env file (replacing SUPABASE_URL and SUPABASE_ANON_KEY)." -t task -p 0 --deps "discovered-from:rav-987" --json

bd create "Initialize Convex project backend" --description="Create a new Convex project via npx convex init. Set up the convex/ directory with schema.ts, configure deployment settings. Set up Convex dashboard access. Create initial project structure: convex/schema.ts, convex/_generated/, convex/mutations/, convex/queries/." -t task -p 0 --deps "discovered-from:rav-987" --json

bd create "Configure Isar database initialization in main.dart" --description="Replace the Drift database initialization in main.dart with Isar.open(). Set up Isar instance with all collection schemas. Configure encryption key from flutter_secure_storage. Replace SupabaseService.initialize() with ConvexClient initialization. Update ProviderScope overrides." -t task -p 0 --deps "discovered-from:rav-987" --json

bd create "Add flutter_secure_storage dependency for Isar encryption" --description="Add flutter_secure_storage package to pubspec.yaml for storing Isar encryption keys. Implement key generation on first launch and secure retrieval on subsequent launches. This protects financial data on field devices per the architecture spec." -t task -p 1 --deps "discovered-from:rav-987" --json

bd create "Update .env and environment configuration" --description="Replace SUPABASE_URL and SUPABASE_ANON_KEY in .env with CONVEX_URL and CONVEX_DEPLOY_KEY. Update SupabaseConfig class references throughout the codebase. Create new ConvexConfig class mirroring the pattern in lib/core/supabase/supabase_config.dart." -t task -p 1 --deps "discovered-from:rav-987" --json

# ============================================================================
# EPIC 2: rav-3am — Convex Backend Schema & Server Functions
# ============================================================================

bd create "Design Convex document schema for Subscribers" --description="Convert the relational SubscribersTable (id, name, code, cabinet, phone, status, startDate, accumulatedDebt, tags, notes + sync metadata) into a Convex document schema in convex/schema.ts. Replace integer auto-increment ID with Convex _id. Add ownerId field for multi-tenancy. Add _version field for conflict resolution. Remove legacy sync columns (dirtyFlag, syncStatus, cloudId, etc.)." -t task -p 0 --deps "discovered-from:rav-3am" --json

bd create "Design Convex document schema for Cabinets" --description="Convert CabinetsTable (id, name, letter, totalSubscribers, currentSubscribers, collectedAmount, delayedSubscribers, completionDate) to Convex document. Add ownerId for tenant isolation. Replace integer FK references with Convex document ID refs. Add _version for LWW." -t task -p 0 --deps "discovered-from:rav-3am" --json

bd create "Design Convex document schema for Payments" --description="Convert PaymentsTable (id, subscriberId FK, amount, worker, date, cabinet) to Convex document. Replace subscriberId integer FK with Convex Id reference. Add ownerId. Add _version. Map REAL amount to Convex number type." -t task -p 0 --deps "discovered-from:rav-3am" --json

bd create "Design Convex document schema for Workers" --description="Convert WorkersTable (id, name, phone, permissions JSON string, todayCollected, monthTotal) to Convex document. Change permissions from JSON string to proper Convex array/object type. Add ownerId. Add role field for RBAC enum (admin/collector)." -t task -p 0 --deps "discovered-from:rav-3am" --json

bd create "Design Convex document schema for AuditLog" --description="Convert AuditLogTable (id, user, action, target, details, type, timestamp) to Convex document. This is append-only — no updates needed. Add ownerId. Audit logs are critical for financial compliance, ensure no data loss during migration." -t task -p 0 --deps "discovered-from:rav-3am" --json

bd create "Design Convex document schema for WhatsAppTemplates" --description="Convert WhatsappTemplatesTable (id, title, content, isActive, createdAt, updatedAt) to Convex document. Change isActive from integer to boolean. Add ownerId for tenant isolation." -t task -p 1 --deps "discovered-from:rav-3am" --json

bd create "Design Convex document schema for GeneratorSettings" --description="Convert GeneratorSettingsTable (id, name, phoneNumber, address, logoPath, createdAt, updatedAt) to Convex document. This is a singleton per tenant. Add ownerId. Handle logoPath as Convex file storage reference if needed." -t task -p 1 --deps "discovered-from:rav-3am" --json

bd create "Implement Convex mutations for Subscribers CRUD" --description="Create convex/mutations/subscribers.ts with: createSubscriber, updateSubscriber, deleteSubscriber (soft delete), bulkUpdateSubscribers. All mutations must validate identity.subject == ownerId. Implement version increment on every write for LWW conflict resolution." -t feature -p 0 --deps "discovered-from:rav-3am" --json

bd create "Implement Convex mutations for Payments CRUD" --description="Create convex/mutations/payments.ts with: createPayment, updatePayment, deletePayment, recordBulkPayments. Validate ownerId. Auto-update subscriber accumulatedDebt and cabinet collectedAmount on payment creation. Atomic version increment." -t feature -p 0 --deps "discovered-from:rav-3am" --json

bd create "Implement Convex mutations for Cabinets CRUD" --description="Create convex/mutations/cabinets.ts with: createCabinet, updateCabinet, deleteCabinet, recalculateCabinetStats. Validate ownerId. Implement cascading stats recalculation when subscribers/payments change." -t feature -p 0 --deps "discovered-from:rav-3am" --json

bd create "Implement Convex mutations for Workers CRUD" --description="Create convex/mutations/workers.ts with: createWorker, updateWorker, deleteWorker, updateWorkerCollectionStats, resetDailyCollections. Validate ownerId. Handle permissions array updates for RBAC." -t feature -p 0 --deps "discovered-from:rav-3am" --json

bd create "Implement Convex mutations for AuditLog" --description="Create convex/mutations/auditLog.ts with: logAction (append-only, no update/delete). Validate ownerId. Record all mutations from other modules as audit entries. This is critical for financial compliance tracking." -t feature -p 1 --deps "discovered-from:rav-3am" --json

bd create "Implement Convex mutations for WhatsApp & Settings" --description="Create convex/mutations/whatsappTemplates.ts and convex/mutations/generatorSettings.ts. Templates: CRUD + toggleActive. Settings: upsert (singleton per tenant). Both validate ownerId." -t feature -p 2 --deps "discovered-from:rav-3am" --json

bd create "Implement Convex queries for all entities" --description="Create convex/queries/ with query files for each entity. All queries must filter by ownerId. Include: listSubscribers (with status/cabinet filters), listPayments (by subscriber/date range/worker), listCabinets, listWorkers, getAuditLog (paginated), getSettings, listTemplates. Implement cursor-based pagination for large datasets." -t feature -p 0 --deps "discovered-from:rav-3am" --json

bd create "Implement Convex real-time subscriptions" --description="Set up Convex subscription endpoints for real-time data updates. Dashboard stats subscription, collection progress subscription, cabinet completion subscription. These will feed the Sync Bridge to hydrate Isar in the background." -t feature -p 1 --deps "discovered-from:rav-3am" --json

bd create "Implement ownerId enforcement on all Convex functions" --description="Audit every mutation and query to ensure identity.subject == doc.ownerId is enforced. Create a shared auth helper (e.g., convex/lib/auth.ts) that extracts and validates tenant identity. No data should ever leak across tenants." -t task -p 0 --deps "discovered-from:rav-3am" --json

# ============================================================================
# EPIC 3: rav-i6z — Isar Local Database Layer
# ============================================================================

bd create "Design Isar collection for Subscribers" --description="Create lib/core/isar/collections/subscriber_collection.dart. Map from Drift SubscribersTable: id(auto)->isarId, name, code(@Index unique), cabinet(@Index), phone, status(@Index enum), startDate, accumulatedDebt, tags(list), notes, ownerId(@Index), version(int for LWW), convexId(String? for cloud mapping), updatedAt, createdAt." -t task -p 0 --deps "discovered-from:rav-i6z" --json

bd create "Design Isar collection for Cabinets" --description="Create lib/core/isar/collections/cabinet_collection.dart. Fields: isarId, name, letter(@Index), totalSubscribers, currentSubscribers, collectedAmount, delayedSubscribers, completionDate, ownerId(@Index), version, convexId, updatedAt, createdAt." -t task -p 0 --deps "discovered-from:rav-i6z" --json

bd create "Design Isar collection for Payments" --description="Create lib/core/isar/collections/payment_collection.dart. Fields: isarId, subscriberIsarId(@Index link), amount, workerName, date(@Index), cabinetName, ownerId(@Index), version, convexId, updatedAt, createdAt. Use IsarLink<Subscriber> for subscriber relationship." -t task -p 0 --deps "discovered-from:rav-i6z" --json

bd create "Design Isar collection for Workers" --description="Create lib/core/isar/collections/worker_collection.dart. Fields: isarId, name, phone, permissions(List<String> instead of JSON string), role(enum: admin/collector), todayCollected, monthTotal, ownerId(@Index), version, convexId, updatedAt, createdAt." -t task -p 0 --deps "discovered-from:rav-i6z" --json

bd create "Design Isar collection for AuditLog" --description="Create lib/core/isar/collections/audit_log_collection.dart. Fields: isarId, user, action, target, details, type, timestamp(@Index), ownerId(@Index), convexId, createdAt. Append-only — no update operations needed." -t task -p 1 --deps "discovered-from:rav-i6z" --json

bd create "Design Isar collection for WhatsAppTemplates" --description="Create lib/core/isar/collections/whatsapp_template_collection.dart. Fields: isarId, title, content, isActive(bool — replacing int), ownerId(@Index), version, convexId, updatedAt, createdAt." -t task -p 1 --deps "discovered-from:rav-i6z" --json

bd create "Design Isar collection for GeneratorSettings" --description="Create lib/core/isar/collections/generator_settings_collection.dart. Fields: isarId, name, phoneNumber, address, logoPath, ownerId(@Index), version, convexId, updatedAt, createdAt. Singleton per tenant." -t task -p 1 --deps "discovered-from:rav-i6z" --json

bd create "Design Isar Outbox collection for offline writes" --description="Create lib/core/isar/collections/outbox_entry_collection.dart. Fields: isarId, tableName(@Index), operationType(enum: create/update/delete), documentId(String), payload(String JSON), createdAt(@Index for FIFO ordering), retryCount, lastError, status(enum: pending/processing/failed). This is the core of the Outbox Pattern for offline-first writes." -t task -p 0 --deps "discovered-from:rav-i6z" --json

bd create "Implement Isar database initialization service" --description="Create lib/core/isar/isar_database.dart. Initialize Isar with all 8 collections (7 domain + 1 outbox). Handle encryption key from flutter_secure_storage. Set up proper directory path via path_provider. Create IsarProvider for Riverpod." -t task -p 0 --deps "discovered-from:rav-i6z" --json

bd create "Implement Isar repository for Subscribers" --description="Create lib/core/isar/repositories/subscriber_repository.dart. Implement: getAll(), getById(), getByCode(), getByCabinet(), getByStatus(), watch() (reactive stream), create(), update(), delete(). All reads return Isar reactive streams for UI binding. All writes also create outbox entries." -t feature -p 0 --deps "discovered-from:rav-i6z" --json

bd create "Implement Isar repository for Cabinets" --description="Create lib/core/isar/repositories/cabinet_repository.dart. Implement: getAll(), getById(), getByLetter(), watch(), create(), update(), delete(), recalculateStats(). Reactive streams for cabinet progress cards. Writes create outbox entries." -t feature -p 0 --deps "discovered-from:rav-i6z" --json

bd create "Implement Isar repository for Payments" --description="Create lib/core/isar/repositories/payment_repository.dart. Implement: getAll(), getBySubscriber(), getByDateRange(), getByWorker(), getByCabinet(), watch(), create(), update(), delete(). Auto-update subscriber debt on payment creation. Writes create outbox entries." -t feature -p 0 --deps "discovered-from:rav-i6z" --json

bd create "Implement Isar repository for Workers" --description="Create lib/core/isar/repositories/worker_repository.dart. Implement: getAll(), getById(), getByRole(), watch(), create(), update(), delete(), updateCollectionStats(), resetDailyStats(). Writes create outbox entries." -t feature -p 0 --deps "discovered-from:rav-i6z" --json

bd create "Implement Isar repositories for AuditLog, WhatsApp, Settings" --description="Create repositories for the remaining 3 collections. AuditLog: append-only log(), getAll(paginated), watchRecent(). WhatsAppTemplates: CRUD + toggleActive(). GeneratorSettings: upsert(), get() singleton. All writes create outbox entries except audit log reads." -t feature -p 1 --deps "discovered-from:rav-i6z" --json

bd create "Implement Isar encryption with Secure Storage" --description="Generate a 256-bit encryption key on first launch using flutter_secure_storage. Store it securely. On subsequent launches, retrieve and pass to Isar.open(encryptionKey). This protects financial data (payments, debts, subscriber info) at rest on field devices." -t task -p 0 --deps "discovered-from:rav-i6z" --json

bd create "Run isar_generator code generation" --description="Configure build.yaml for isar_generator. Run dart run build_runner build to generate .g.dart files for all Isar collections. Verify generated code compiles and all indexes are created correctly." -t task -p 0 --deps "discovered-from:rav-i6z" --json

# ============================================================================
# EPIC 4: rav-neh — Sync Bridge (Isar <-> Convex)
# ============================================================================

bd create "Implement SyncManager orchestrator" --description="Create lib/core/sync/sync_manager.dart. Central orchestrator that coordinates the Outbox Processor (writes) and Subscription Listener (reads). Manages sync lifecycle: start, pause, resume, stop. Exposes sync status stream for UI. Replaces the existing EnhancedSyncService (265 lines) and SupabaseService sync logic (1467 lines)." -t feature -p 0 --deps "discovered-from:rav-neh" --json

bd create "Implement Outbox Processor (Write Path)" --description="Create lib/core/sync/outbox_processor.dart. Reads pending entries from Isar Outbox collection in FIFO order. For each entry: deserialize payload, call corresponding Convex mutation, mark as completed on success, increment retryCount on failure. Implements sequential push with configurable batch size. Respects connectivity state." -t feature -p 0 --deps "discovered-from:rav-neh" --json

bd create "Implement Convex Subscription Listener (Read Path)" --description="Create lib/core/sync/subscription_listener.dart. Subscribes to Convex real-time queries for each entity. On data change from Convex, upsert into local Isar collections. Skip updates that originated from this device (check outbox). This is the background hydration loop that keeps Isar in sync with Convex." -t feature -p 0 --deps "discovered-from:rav-neh" --json

bd create "Implement LWW Conflict Resolution with version vectors" --description="Create lib/core/sync/conflict_resolver.dart. Replace existing sync_conflict.dart (201 lines) with new LWW strategy using _version fields. Compare version numbers on Convex mutations — reject if stale. On conflict: field-level merge when possible (e.g., Admin updates subscriber name while Collector updates payment), fallback to LWW by timestamp." -t feature -p 0 --deps "discovered-from:rav-neh" --json

bd create "Implement Connectivity Monitor" --description="Create lib/core/sync/connectivity_monitor.dart. Replace the existing connectivity_plus usage in supabase_service.dart. Stream-based connectivity state (online/offline/metered). Triggers outbox processing on connectivity restore. Supports manual sync trigger for low-bandwidth environments." -t task -p 1 --deps "discovered-from:rav-neh" --json

bd create "Implement Sync Status Provider for UI" --description="Create lib/core/sync/sync_providers.dart. Replace existing sync_provider.dart (31 lines). Expose Riverpod providers: syncStatusProvider (idle/syncing/error), pendingChangesCountProvider, lastSyncTimeProvider, connectivityStateProvider. These feed the sync status dot and settings sync panel." -t task -p 1 --deps "discovered-from:rav-neh" --json

bd create "Implement retry logic and exponential backoff" --description="Add retry logic to OutboxProcessor: exponential backoff (1s, 2s, 4s, 8s, max 60s) on transient failures. Mark entries as permanently failed after MAX_RETRIES (configurable, default 10). Surface failed entries in admin UI for manual retry/discard." -t task -p 1 --deps "discovered-from:rav-neh" --json

bd create "Implement delta sync optimization" --description="Instead of full table syncs (current approach in SupabaseService), implement delta sync: track lastSyncTimestamp per collection. Convex subscriptions only push changes since last sync. Reduces bandwidth for 4G/low-connectivity field environments." -t task -p 2 --deps "discovered-from:rav-neh" --json

# ============================================================================
# EPIC 5: rav-ju9 — Data Migration
# ============================================================================

bd create "Build Drift-to-Isar migration utility" --description="Create lib/core/migration/drift_to_isar_migrator.dart. Read all records from existing Drift/SQLite database (mawlid_al_dhaki_v1.db). Transform each record to Isar collection format. Handle: integer IDs to Isar auto-IDs, DateTime format differences, JSON string permissions to List<String>, integer isActive to bool. Write to Isar in batched transactions." -t feature -p 0 --deps "discovered-from:rav-ju9" --json

bd create "Build ID mapping table for migration" --description="Create a temporary mapping collection in Isar that maps old Drift integer IDs to new Isar IDs and Convex document IDs. Essential for preserving referential integrity: payments.subscriberId must correctly map to the new subscriber Isar ID. Map: oldDriftId -> newIsarId -> convexDocId for each entity." -t task -p 0 --deps "discovered-from:rav-ju9" --json

bd create "Migrate Subscribers data (Drift -> Isar)" --description="Migrate all records from SubscribersTable. Transform: id(int->auto), code(preserve unique constraint), cabinet(text->text), status(int->enum), accumulatedDebt(real->double), tags(nullable text->List<String>?), sync metadata columns(drop entirely). Verify record count matches after migration." -t task -p 0 --deps "discovered-from:rav-ju9" --json

bd create "Migrate Cabinets data (Drift -> Isar)" --description="Migrate all records from CabinetsTable. Transform: id(int->auto), letter(text->text indexed), numeric fields preserved. Drop all sync metadata columns. Verify completion_date nullable handling." -t task -p 0 --deps "discovered-from:rav-ju9" --json

bd create "Migrate Payments data with FK remapping" --description="Migrate PaymentsTable records. Critical: remap subscriberId FK from old Drift integer ID to new Isar subscriber ID using the ID mapping table. Transform date formats. Drop sync metadata. Verify payment-subscriber linkage integrity after migration." -t task -p 0 --deps "discovered-from:rav-ju9" --json

bd create "Migrate Workers data with permissions transformation" --description="Migrate WorkersTable records. Transform permissions from JSON string to List<String>. Map todayCollected and monthTotal (real->double). Add default role (collector for existing workers, admin for owner). Drop sync metadata." -t task -p 0 --deps "discovered-from:rav-ju9" --json

bd create "Migrate AuditLog data" --description="Migrate AuditLogTable records. Preserve all audit history for compliance. Transform timestamp formats. This is append-only data — no FK remapping needed. Drop sync metadata." -t task -p 1 --deps "discovered-from:rav-ju9" --json

bd create "Migrate WhatsApp Templates and Generator Settings" --description="Migrate WhatsappTemplatesTable: isActive int->bool. Migrate GeneratorSettingsTable: preserve as singleton. Both are simple transformations. Drop sync metadata from templates." -t task -p 1 --deps "discovered-from:rav-ju9" --json

bd create "Build Supabase-to-Convex cloud data migration" --description="Create a one-time migration script that reads all data from Supabase PostgreSQL tables (subscribers, payments, cabinets, workers, audit_log, whatsapp_templates, generator_settings) and inserts into Convex via mutations. Handle ID generation. Can run as a standalone Node.js script using Convex client." -t feature -p 1 --deps "discovered-from:rav-ju9" --json

bd create "Implement migration validation and rollback" --description="Create validation step that compares record counts, checksums, and key field values between old (Drift/Supabase) and new (Isar/Convex) databases. Implement rollback: keep old Drift DB file as backup until migration is confirmed successful. Add migration status tracking in shared_preferences." -t task -p 0 --deps "discovered-from:rav-ju9" --json

bd create "Implement incremental migration with progress UI" --description="Add a migration progress dialog that shows: table being migrated, records processed/total, estimated time remaining. Allow migration to be paused/resumed. Handle app crash during migration gracefully (idempotent migration — skip already migrated records)." -t task -p 1 --deps "discovered-from:rav-ju9" --json

# ============================================================================
# EPIC 6: rav-sem — Service Layer Refactoring
# ============================================================================

bd create "Refactor SubscribersService to use Isar repository" --description="Rewrite lib/core/services/subscribers_service.dart (4098 bytes). Replace all AppDatabase/SubscribersDao references with SubscriberRepository. Change return types from Drift Subscriber model to Isar Subscriber collection. Update getAllSubscribers(), getSubscriberById(), addSubscriber(), updateSubscriber(), deleteSubscriber(), getSubscriberByCode()." -t task -p 1 --deps "discovered-from:rav-sem" --json

bd create "Refactor CabinetsService to use Isar repository" --description="Rewrite lib/core/services/cabinets_service.dart (3296 bytes). Replace AppDatabase/CabinetsDao with CabinetRepository. Remove resetSyncError/updateSyncError methods (no longer needed). Update getAllCabinets(), getCabinetById(), addCabinet(), updateCabinet()." -t task -p 1 --deps "discovered-from:rav-sem" --json

bd create "Refactor PaymentsService to use Isar repository" --description="Rewrite lib/core/services/payments_service.dart (3078 bytes). Replace AppDatabase/PaymentsDao with PaymentRepository. Update getAllPayments(), getPaymentById(), addPayment(), updatePayment(). Ensure subscriber debt auto-recalculation is preserved." -t task -p 1 --deps "discovered-from:rav-sem" --json

bd create "Refactor WorkersService to use Isar repository" --description="Rewrite lib/core/services/workers_service.dart (3184 bytes). Replace AppDatabase/WorkersDao with WorkerRepository. Handle permissions as List<String> instead of JSON string. Update collection stats methods." -t task -p 1 --deps "discovered-from:rav-sem" --json

bd create "Refactor DashboardService to use Isar repository" --description="Rewrite lib/core/services/dashboard_service.dart (12029 bytes — largest service). Replace all Drift queries with Isar queries. Dashboard aggregates data from multiple collections (subscribers, payments, cabinets). Use Isar's where() clauses and aggregation for stat cards." -t task -p 1 --deps "discovered-from:rav-sem" --json

bd create "Refactor AuditService and AuditLogService" --description="Rewrite lib/core/services/audit_service.dart (10054 bytes) and audit_log_service.dart (3081 bytes). Replace Drift DAOs with AuditLogRepository. Preserve the detailed audit logging functionality used for financial compliance." -t task -p 1 --deps "discovered-from:rav-sem" --json

bd create "Refactor WhatsappService to use Isar repository" --description="Rewrite lib/core/services/whatsapp_service.dart (7056 bytes). Replace Drift DAO with WhatsAppTemplateRepository. Update template CRUD operations. Preserve Node.js WhatsApp bridge integration (process_run)." -t task -p 2 --deps "discovered-from:rav-sem" --json

bd create "Refactor SettingsService to use Isar repository" --description="Rewrite lib/core/services/settings_service.dart (14539 bytes — second largest). Replace Drift queries with Isar GeneratorSettingsRepository. Handle singleton pattern (one settings doc per tenant). Preserve ampere price, generator info management." -t task -p 1 --deps "discovered-from:rav-sem" --json

bd create "Refactor ReportsService to use Isar repository" --description="Rewrite lib/core/services/reports_service.dart (4472 bytes). Replace Drift aggregate queries with Isar equivalents. Reports need cross-collection joins (subscribers+payments+cabinets). Isar handles this via links and embedded objects." -t task -p 1 --deps "discovered-from:rav-sem" --json

bd create "Refactor PrintService for new data models" --description="Update lib/core/services/print_service.dart (5978 bytes). Change Drift model references to Isar collection types. PDF generation and ESC/POS receipt printing logic should mostly be unchanged — only the input data types change." -t task -p 2 --deps "discovered-from:rav-sem" --json

bd create "Rewrite database_provider.dart for Isar" --description="Replace lib/core/database/database_provider.dart (61 lines). Remove databaseProvider (AppDatabase), subscribersDaoProvider, cabinetsDaoProvider, paymentsDaoProvider, workersDaoProvider, auditLogDaoProvider. Create isarProvider, subscriberRepoProvider, cabinetRepoProvider, paymentRepoProvider, workerRepoProvider, auditLogRepoProvider, templateRepoProvider, settingsRepoProvider." -t task -p 0 --deps "discovered-from:rav-sem" --json

bd create "Rewrite service_providers.dart for Isar" --description="Update lib/core/services/service_providers.dart (50 lines). All 6 service providers (cabinets, subscribers, payments, workers, auditLog, whatsapp) now depend on Isar repositories instead of AppDatabase. Update constructor signatures." -t task -p 0 --deps "discovered-from:rav-sem" --json

bd create "Replace supabase_provider.dart with convex_provider.dart" --description="Remove lib/core/supabase/supabase_provider.dart (3792 bytes). Create lib/core/convex/convex_provider.dart with ConvexClient provider. This provider feeds the SyncManager instead of the old SupabaseService." -t task -p 0 --deps "discovered-from:rav-sem" --json

# ============================================================================
# EPIC 7: rav-476 — Auth & Multi-tenancy & RBAC
# ============================================================================

bd create "Implement Convex authentication integration" --description="Set up Convex auth provider (e.g., Convex + Clerk, or custom JWT). Replace the current simple password-based LoginScreen auth with proper identity-based authentication. Store auth tokens securely via flutter_secure_storage. Handle token refresh and session management." -t feature -p 0 --deps "discovered-from:rav-476" --json

bd create "Implement ownerId tenant isolation in Isar" --description="Add ownerId field to all Isar collections. All repository queries must filter by the current authenticated user's ownerId. Create a CurrentUserProvider that exposes the authenticated user's identity for use in all repository operations." -t task -p 0 --deps "discovered-from:rav-476" --json

bd create "Implement dynamic RBAC permission system" --description="Create lib/core/auth/rbac_service.dart. Define permission scopes: collection_read, collection_write, subscriber_manage, cabinet_manage, reports_view, settings_manage, audit_view, whatsapp_manage. Admin role gets all scopes. Collector role gets configurable subset. Store role/permissions in Workers collection." -t feature -p 0 --deps "discovered-from:rav-476" --json

bd create "Implement Admin permission granting UI" --description="Create UI in Settings or Workers screen where Admin can grant/revoke specific permission scopes to Collector accounts. Dynamic checkboxes for each scope. Changes sync to Convex so Collector devices pick up permission updates." -t feature -p 1 --deps "discovered-from:rav-476" --json

bd create "Update LoginScreen for Convex auth" --description="Refactor lib/features/auth/login_screen.dart (15171 bytes) to use Convex authentication instead of simple password check. Add user role detection post-login (Admin vs Collector). Route to appropriate UI based on role. Preserve existing Bitepoint-style visual design." -t task -p 0 --deps "discovered-from:rav-476" --json

bd create "Implement permission-guarded navigation" --description="Update app_router.dart to check RBAC permissions before allowing route access. Collector should not see Admin-only routes (e.g., full reports, settings, worker management). Show permission-denied feedback if unauthorized route is accessed." -t task -p 1 --deps "discovered-from:rav-476" --json

# ============================================================================
# EPIC 8: rav-dnk — Feature Screen Updates
# ============================================================================

bd create "Update DashboardScreen for Isar streams" --description="Refactor lib/features/dashboard/dashboard_screen.dart (54173 bytes — largest screen). Replace all Drift-based providers with Isar reactive stream providers. Stat cards (collected today, subscribers, unpaid, CTA) must use Isar watch() streams. Charts (PieChart, collection progress) use Isar aggregate queries. Preserve all Bitepoint animations and RTL layout." -t task -p 1 --deps "discovered-from:rav-dnk" --json

bd create "Update SubscribersScreen for Isar streams" --description="Refactor lib/features/subscribers/subscribers_screen.dart (28473 bytes). Replace Drift query providers with Isar reactive streams. Update filter tabs (active/suspended/disconnected) to use Isar where() clauses. Update PlutoGrid data source. Preserve context menu, drawer details, and all existing UI interactions." -t task -p 1 --deps "discovered-from:rav-dnk" --json

bd create "Update CabinetsScreen for Isar streams" --description="Refactor cabinets feature screens. Replace Drift cabinet queries with Isar CabinetRepository.watch(). Update progress bar calculations. Preserve confetti celebration on 100% completion. Update subscriber-per-cabinet drill-down." -t task -p 1 --deps "discovered-from:rav-dnk" --json

bd create "Update CollectionScreen for Isar streams" --description="Refactor collection feature screens. Replace Drift payment queries with Isar PaymentRepository streams. Update Kanban columns (unpaid/partial/completed) with Isar filtered streams. Update payment dialog to use Isar write + outbox. Preserve ampere price editing and monthly progress bar." -t task -p 1 --deps "discovered-from:rav-dnk" --json

bd create "Update WorkersScreen for Isar streams" --description="Refactor workers feature screens. Replace Drift worker queries with Isar WorkerRepository.watch(). Update permission display from JSON string to List<String> chips. Update collection stats display." -t task -p 1 --deps "discovered-from:rav-dnk" --json

bd create "Update ReportsScreen for Isar queries" --description="Refactor reports feature screens. Replace Drift aggregate queries with Isar equivalents. Multi-collection aggregations for financial reports (subscribers+payments+cabinets). Update PDF generation with new data models." -t task -p 2 --deps "discovered-from:rav-dnk" --json

bd create "Update WhatsAppScreen for Isar streams" --description="Refactor whatsapp feature screens. Replace Drift template queries with Isar WhatsAppTemplateRepository.watch(). Preserve Node.js bridge integration. Update template CRUD dialogs." -t task -p 2 --deps "discovered-from:rav-dnk" --json

bd create "Update SettingsScreen for Isar + sync status" --description="Refactor settings feature screens. Replace Drift settings queries with Isar GeneratorSettingsRepository. Update sync status panel to show new SyncManager status (pending outbox count, last sync time, connectivity state). Add manual sync trigger button." -t task -p 1 --deps "discovered-from:rav-dnk" --json

bd create "Update AuditScreen for Isar streams" --description="Refactor audit feature screens. Replace Drift audit log queries with Isar AuditLogRepository.watchRecent(). Update paginated list display. Preserve existing filtering and search." -t task -p 2 --deps "discovered-from:rav-dnk" --json

bd create "Update PaymentsScreen for Isar streams" --description="Refactor payments feature screens. Replace Drift payment queries with Isar PaymentRepository streams. Update payment recording dialog. Preserve audio feedback (payment_success.mp3) and toast notifications." -t task -p 1 --deps "discovered-from:rav-dnk" --json

bd create "Update subscriber/payment dialogs for Isar writes" --description="Refactor lib/features/subscribers/dialogs/ and collection payment dialogs. All form submissions now write to Isar + outbox instead of Drift + SupabaseService. Preserve validation, quick amount chips, worker dropdown, and print+record flow." -t task -p 1 --deps "discovered-from:rav-dnk" --json

# ============================================================================
# EPIC 9: rav-8dg — Offline-First & Collector Mode
# ============================================================================

bd create "Build Collector Mode UI shell" --description="Create a simplified app shell for Collector role. Stripped-down sidebar with only permitted sections (e.g., collection, subscriber lookup). Optimized for tablet/phone form factors. High-speed data entry focus. Large touch targets for field use." -t feature -p 1 --deps "discovered-from:rav-8dg" --json

bd create "Implement offline payment recording" --description="Payment recording must work with zero network. Write payment to Isar + outbox entry. Show instant success feedback (audio + toast). Queue outbox for later sync. Display unsynced payment indicator badge on payment records." -t feature -p 0 --deps "discovered-from:rav-8dg" --json

bd create "Implement background auto-sync worker" --description="Create a background isolate/timer that periodically processes the outbox queue when connectivity is available. Configurable sync interval (default: 30 seconds). Respects battery and bandwidth constraints. Auto-triggers on connectivity restore." -t feature -p 1 --deps "discovered-from:rav-8dg" --json

bd create "Implement manual sync trigger for low-bandwidth" --description="Add a prominent sync button in the Collector UI and Settings screen. Allow field workers on 4G/slow networks to manually trigger sync when they find good connectivity. Show sync progress with record count and estimated time." -t task -p 1 --deps "discovered-from:rav-8dg" --json

bd create "Implement offline indicator and sync status badge" --description="Add a persistent network status indicator in the app bar/top bar. Show: green dot (online+synced), yellow dot (online+pending), red dot (offline). Show pending outbox count badge. Replaces existing sync_status_dot.dart widget with new implementation." -t task -p 1 --deps "discovered-from:rav-8dg" --json

bd create "Implement data prefetch for offline readiness" --description="On initial sync or manual trigger, prefetch all subscriber and cabinet data for the Collector's assigned scope into Isar. Ensure Collector can browse subscribers, view payment history, and record payments even with zero connectivity." -t task -p 1 --deps "discovered-from:rav-8dg" --json

bd create "Implement Admin Mode real-time monitoring" --description="Admin Mode retains full dashboard with real-time monitoring of field transactions. Convex subscriptions push Collector payment activity to Admin dashboard in real-time. Show which Collectors are active, their sync status, and latest transactions." -t feature -p 2 --deps "discovered-from:rav-8dg" --json

# ============================================================================
# EPIC 10: rav-qsl — Testing & Validation
# ============================================================================

bd create "Unit tests for Isar repositories" --description="Write unit tests for all 7 Isar repositories (subscriber, cabinet, payment, worker, auditLog, whatsappTemplate, generatorSettings) + outbox repository. Test CRUD operations, reactive streams, index queries, and ownerId filtering. Use Isar's in-memory mode for testing." -t task -p 1 --deps "discovered-from:rav-qsl" --json

bd create "Unit tests for Outbox Processor" --description="Test outbox processing: FIFO ordering, retry logic with exponential backoff, max retry limit, permanent failure marking, batch processing, connectivity-gated processing. Mock Convex client for isolated testing." -t task -p 1 --deps "discovered-from:rav-qsl" --json

bd create "Integration tests for Sync Bridge" --description="Test full sync cycle: write to Isar + outbox -> outbox processor sends to Convex -> Convex subscription listener hydrates other Isar instance. Test conflict resolution: concurrent writes, version vector comparison, LWW outcomes. Test offline->online transition." -t task -p 1 --deps "discovered-from:rav-qsl" --json

bd create "Migration validation tests" --description="Test data migration accuracy: record count comparison between Drift and Isar for all tables. Field-by-field validation for a sample of records. FK integrity check (payment->subscriber links). ID mapping correctness. Rollback functionality test." -t task -p 0 --deps "discovered-from:rav-qsl" --json

bd create "End-to-end workflow tests for Admin flow" --description="Test complete Admin workflows: login -> dashboard stats -> add subscriber -> add cabinet -> record payment -> view reports -> generate PDF -> audit log entry. Verify all data flows through Isar+Convex correctly. Test in both online and offline modes." -t task -p 1 --deps "discovered-from:rav-qsl" --json

bd create "End-to-end workflow tests for Collector flow" --description="Test complete Collector workflows: login as Collector -> view assigned subscribers -> record payment offline -> sync when online -> verify payment appears in Admin dashboard. Test RBAC: verify Collector cannot access restricted routes." -t task -p 1 --deps "discovered-from:rav-qsl" --json

bd create "Performance benchmarks: Isar vs Drift" --description="Benchmark read/write performance of new Isar setup vs old Drift setup. Measure: bulk insert 10K records, query with filters, reactive stream latency, full sync cycle time. Document results for comparison. Target: Isar should match or exceed Drift performance." -t task -p 2 --deps "discovered-from:rav-qsl" --json

# ============================================================================
# EPIC 11: rav-ehd — Legacy Cleanup & Documentation
# ============================================================================

bd create "Remove Drift database files" --description="Delete: lib/core/database/app_database.dart (347 lines), app_database.g.dart (382KB generated), database_provider.dart, schema.sql. Delete lib/core/database/daos/ directory (12 files: 6 DAOs + 6 .g.dart). Delete lib/core/database/migrations/ and policies/ directories." -t task -p 2 --deps "discovered-from:rav-ehd" --json

bd create "Remove Supabase integration files" --description="Delete: lib/core/supabase/supabase_service.dart (1467 lines), supabase_config.dart, supabase_provider.dart (3792 bytes), sync_conflict.dart (201 lines), indexes.sql. Delete supabase/ directory and supabase_tables.sql (179 lines)." -t task -p 2 --deps "discovered-from:rav-ehd" --json

bd create "Remove old sync service files" --description="Delete: lib/core/sync/enhanced_sync_service.dart (265 lines), sync_provider.dart (31 lines). These are fully replaced by the new SyncManager, OutboxProcessor, and SubscriptionListener." -t task -p 2 --deps "discovered-from:rav-ehd" --json

bd create "Clean up .env and remove Supabase credentials" --description="Remove SUPABASE_URL and SUPABASE_ANON_KEY from .env (280 bytes). Remove hardcoded Supabase URL and anon key from supabase_config.dart. Ensure Convex credentials are properly configured. Update .gitignore if needed." -t task -p 1 --deps "discovered-from:rav-ehd" --json

bd create "Remove legacy documentation files" --description="Clean up root-level legacy docs: DATABASE_ARCHITECTURE_ENHANCEMENT_STATUS.md, DATABASE_ARCHITECTURE_PROGRESS.md, FINAL_DATABASE_ARCHITECTURE_SUMMARY.md, SYNC_TEST_HARNESS_DESIGN.md, SYNC_VALIDATION_FINDINGS.md, SYNC_VALIDATION_SPIKE_PLAN.md, STRATEGIC_APPROACH_SUMMARY.md, B08_IMPLEMENTATION_NOTES.md, status_report.md, code_issues_summary.md, database_architecture_status.md, analyze_dash_null.txt." -t task -p 3 --deps "discovered-from:rav-ehd" --json

bd create "Update PRD for Isar+Convex architecture" --description="Update PRD.md (59KB) Section 2 (pubspec.yaml) and Section 3 (Project Structure) to reflect: Isar collections replacing Drift tables, Convex backend replacing Supabase, new sync architecture, RBAC system, Admin/Collector modes. Add new architecture diagrams." -t task -p 2 --deps "discovered-from:rav-ehd" --json

bd create "Create architecture documentation for new system" --description="Write comprehensive architecture doc covering: Isar collection schemas, Convex schema design, Sync Bridge design (outbox pattern + subscription listener), conflict resolution strategy, RBAC model, Admin vs Collector mode routing, encryption at rest, migration process. Store in docs/ directory." -t task -p 2 --deps "discovered-from:rav-ehd" --json

bd create "Final performance optimization pass" --description="Profile the complete app with new Isar+Convex stack. Optimize: Isar index coverage for common queries, Convex query efficiency, sync batch sizes, reactive stream debouncing (rxdart 300ms for search). Ensure dashboard loads in under 200ms from local Isar cache." -t task -p 3 --deps "discovered-from:rav-ehd" --json

Write-Host "ALL ISSUES CREATED SUCCESSFULLY"
