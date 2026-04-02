# Dependency Audit Report

## Summary
The project has 18 direct dependencies with updates available. This document outlines the upgrade strategy.

## Direct Dependencies Analysis

### Critical (Breaking Changes Likely)
| Package | Current | Latest | Risk | Notes |
|---------|---------|--------|------|-------|
| drift | 2.28.2 | 2.32.1 | HIGH | Major version - breaking schema API changes |
| drift_flutter | 0.1.0 | 0.3.0 | HIGH | Major version - breaking changes |
| flutter_riverpod | 2.6.1 | 3.3.1 | MEDIUM | Provider API changes in v3 |
| go_router | 14.8.1 | 17.1.0 | MEDIUM | Navigation API changes |

### Recommended Upgrades (Safe)
| Package | Current | Latest | Notes |
|---------|---------|--------|-------|
| confetti | 0.7.0 | 0.8.0 | Minor - safe |
| connectivity_plus | 6.1.5 | 7.1.0 | Minor - safe |
| figma_squircle | 0.5.3 | 0.6.3 | Minor - safe |
| fl_chart | 0.68.0 | 1.2.0 | Medium - check API |
| intl | 0.19.0 | 0.20.2 | Minor - safe |
| package_info_plus | 8.3.1 | 9.0.1 | Minor - safe |
| screen_retriever | 0.1.9 | 0.2.0 | Minor - safe |
| talker_flutter | 4.9.3 | 5.1.16 | Major - check API |
| toastification | 2.3.0 | 3.0.3 | Major - breaking |
| trina_grid | 1.6.10 | 2.2.1 | Major - check API |
| window_manager | 0.4.2 | 0.5.1 | Minor - safe |
| riverpod_annotation | 2.6.1 | 4.0.2 | Major - codegen changes |

### Dev Dependencies
| Package | Current | Latest | Notes |
|---------|---------|--------|-------|
| build_runner | 2.5.4 | 2.13.1 | Recommended |
| drift_dev | 2.28.0 | 2.32.1 | Match drift |
| flutter_lints | 4.0.0 | 6.0.0 | Recommended |
| freezed | 3.1.0 | 3.2.5 | Recommended |
| json_serializable | 6.9.5 | 6.13.1 | Minor - safe |
| riverpod_generator | 2.6.5 | 4.0.3 | Match riverpod |

## Upgrade Phases

### Phase 1: Safe Upgrades (No Breaking Changes)
```bash
flutter pub upgrade --major-versions confetti connectivity_plus figma_squircle
flutter pub upgrade --major-versions intl package_info_plus screen_retriever window_manager
```

### Phase 2: Dev Dependencies
```bash
flutter pub upgrade --major-versions build_runner flutter_lints freezed json_serializable
flutter pub upgrade drift_dev
```

### Phase 3: Core Framework Upgrades (Requires Testing)
- flutter_riverpod → Test thoroughly after upgrade
- go_router → Check navigation changes
- trina_grid → Verify grid API compatibility

### Phase 4: High-Risk Upgrades (May Require Code Changes)
- drift → Schema API changes expected
- talker_flutter → API may have breaking changes
- toastification → Review changelog

## Security Notes
- win32: Version 5.15.0 → 6.0.0 has breaking changes for Windows
- sqlite3: Version 2.9.4 → 3.2.0 is EOL path - drift handles this

## Recommendation
Run Phase 1+2 upgrades now. Defer Phase 3-4 to separate releases with dedicated testing.
