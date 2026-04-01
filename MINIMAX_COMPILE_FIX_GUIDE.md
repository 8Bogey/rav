# 🛠️ Minimax Guide: Post-Migration Compile Fixes & Cleanups

**Attention Agent:** You are working on the final stabilization phase (Epic `rav-3n7e`). This document contains explicit hints and code patterns for your remaining `bd` tasks. Read the specific section for your current task before writing code.

---

## 🏗️ 1. [rav-dq9s] Fix ID type mismatches (int → String UUID)
**The Problem:** The old database used auto-incrementing integers for IDs. The new Convex architecture uses `String` UUIDs. `flutter analyze` shows hundreds of errors where a parameter expects a `String` but gets an `int`, or vice versa.
**The Fix:**
- Search globally in `lib/features/` and `lib/core/services/` for functions expecting `int id`. Change them to `String id`.
- Example in UI widgets: Update `final int cabinetId;` to `final String cabinetId;`.
- **Do not parse strings to ints.** If you see `int.parse(id)`, remove the `int.parse`.

---

## 🗑️ 2. [rav-czho] Remove obsolete Supabase sync function calls
**The Problem:** `flutter analyze` reports `undefined_method` for methods like `markConflictForManualResolution()`, `clearDirtyFlag()`, `getDirtyCabinets()`.
**The Fix:**
- Go to `lib/core/services/audit_log_service.dart`, `cabinets_service.dart`, etc., and completely **DELETE** these old methods.
- The new `OutboxTable` handles sync automatically. We do not use manual flags anymore.

---

## 🗺️ 3. [rav-qdr3] Fix Navigation and Routing (int → String)
**The Problem:** `go_router` paths pass parameters as strings, but the UI might be trying to interpret them as `int`.
**The Fix:**
- Open your router file (e.g., `app_router.dart` or where `GoRoute` is defined).
- Change route parameter parsing. 
- **Old:** `final id = int.parse(state.pathParameters['id']!);`
- **New:** `final id = state.pathParameters['id']!;`

---

## 👤 4. [rav-ga3g] Fix missing 'ownerId' arguments in DAO/Service inserts
**The Problem:** Drift DAOs now strictly require `ownerId` to enforce tenant isolation. You will see `missing_required_argument` errors in services like `DashboardService` or `ReportsService`.
**The Fix:**
- When a service or Riverpod provider inserts or queries data, it must pass `ownerId`.
- **In Services:** Ensure functions accept `required String ownerId`.
- **In Providers:** Read `ownerId` from the `authSessionProvider` (or active user) and inject it into the service call:
  ```dart
  // Example provider fix
  final activeCabinetsProvider = StreamProvider<List<Cabinet>>((ref) {
    final dao = ref.watch(cabinetsDaoProvider);
    final user = ref.watch(currentUserProvider).value;
    if (user == null) return const Stream.empty();
    
    return dao.watchCabinets(ownerId: user.tenantId);
  });
  ```

---

## 🧹 5. [rav-twwn] Cleanup: Remove legacy sync metadata fields
**The Problem:** `app_database.dart` and `convex/schema.ts` have leftover bloat fields like `dirtyFlag`, `syncStatus`, `lastModified`, `cloudId`, `deletedLocally`.
**The Fix:**
- Go into `app_database.dart` and delete those getter columns from `SubscribersTable`, `CabinetsTable`, etc.
- Also, remove them from `convex/schema.ts` entirely.
- We strictly rely on: `ownerId`, `version`, `isDeleted`, `updatedAt`, `createdAt`.
- Run `flutter pub run build_runner build -d` after removing them to update the generated code.

---

## 💥 6. [rav-sisd] Migration: Implement Wipe-and-Sync strategy
**The Problem:** Version 4 of the local database changed primary keys from integers to text. Normal SQLite migrations cannot easily alter a primary key type without complex table reconstructions.
**The Fix:**
- In `app_database.dart` inside the `MigrationStrategy`'s `onUpgrade` logic for `v4`, execute the nuclear option (Wipe DB).
- We are local-first, meaning the Source-of-Truth is in Convex. Wiping local data is completely safe.
```dart
onUpgrade: (Migrator m, int from, int to) async {
  if (from < 4) {
    print('Critical Architecture Update: Wiping old integer-based schema...');
    // Drop all old tables
    for (final table in allTables) {
      await m.drop(table);
    }
    // Recreate them with String UUIDs
    await m.createAll();
    // The Sync Bridge will automatically download all data from Convex
  }
}
```

---

## ⚡ 7. [rav-louj] Optimization: Add Compound Indexes
**The Problem:** Since every query must filter by `ownerId` and `isDeleted`, sequential scans will slow down the UI as the database grows.
**The Fix:**
- In `app_database.dart`, override the `customConstraints` or `indexes` method for your tables.
```dart
@DataClassName('Subscriber')
class SubscribersTable extends Table {
  // ... fields ...
  
  @override
  List<String> get customConstraints => [
    'CREATE INDEX IF NOT EXISTS idx_subscribers_owner_deleted ON subscribers_table(owner_id, is_deleted)'
  ];
}
```
*Note: Make sure to run `build_runner` after modifying the tables.*

---

## 🏁 8. Final Boss: Zero Errors
Before closing `rav-7f9a`, you must run:
`flutter analyze`

If it says `No issues found!`, the migration is truly complete. You can build the app.
