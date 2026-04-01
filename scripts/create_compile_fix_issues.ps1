# ============================================================================
# EPIC 8: rav-compile-fixes — Post-Migration Refactoring & Compile Error Resolution
# ============================================================================

bd create "EPIC: Post-Migration Refactoring & Compile Error Resolution" --description="Fix the ~694 compilation errors caused by the Data Layer migration to UUIDs, Convex integration, and the removal of Supabase. This epic ensures the app compiles successfully." -t epic -p 0 --json

bd create "Fix ID type mismatches (int -> String UUID)" --description="Search through the codebase (especially lib/features and lib/core/services) for any legacy code passing or expecting 'int' for IDs. Update all parameters, models, and function signatures to expect a 'String' (UUID) to match the new Drift TextColumn primary keys." -t task -p 0 --deps "descendant:EPIC: Post-Migration Refactoring & Compile Error Resolution" --json

bd create "Remove obsolete Supabase sync function calls" --description="Files like lib/core/services/audit_log_service.dart and others are throwing 'undefined_method' errors because they are trying to call removed Supabase methods like 'markConflictForManualResolution()'. Completely remove these legacy conflict/sync calls." -t task -p 0 --deps "descendant:EPIC: Post-Migration Refactoring & Compile Error Resolution" --json

bd create "Fix missing 'ownerId' arguments in DAO/Service inserts" --description="The new Drift tables strictly require 'ownerId' to enforce multi-tenancy. Several DAOs and Service layer insert statements are failing because they are missing the 'ownerId' named parameter. Retrieve the tenant ID from the current session and pass it into these inserts." -t task -p 0 --deps "descendant:EPIC: Post-Migration Refactoring & Compile Error Resolution" --json

bd create "Fix missing Riverpod imports and Provider definitions" --description="There are errors related to 'FutureProvider' and other Riverpod classes being undefined (e.g., in database_migration_manager.dart and others). Clean up the imports, verify 'flutter_riverpod' is imported correctly, and refactor any removed Providers." -t task -p 1 --deps "descendant:EPIC: Post-Migration Refactoring & Compile Error Resolution" --json

bd create "Fix Navigation and Routing arguments (int -> String)" --description="Verify all go_router route definitions pathParameters and queryParameters. Any route that previously expected a numeric ID (e.g., /subscriber/:id) and parsed it using int.parse() must be updated to simply pass the String UUID directly." -t task -p 1 --deps "descendant:EPIC: Post-Migration Refactoring & Compile Error Resolution" --json

bd create "Final pass: Zero 'flutter analyze' errors" --description="Run 'flutter analyze' and systematically eliminate any remaining syntax errors, missing variables, or broken imports until the command returns 'No issues found!'. Test compilation via 'flutter build windows' or 'flutter build apk'." -t task -p 0 --deps "descendant:EPIC: Post-Migration Refactoring & Compile Error Resolution" --json

Write-Host "Compile fix issues created successfully in the tracker."
