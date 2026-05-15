# WealthPath Assessment

## Flutter Version
- Flutter `3.19+` compatible
- Dart `3.3+` compatible (project currently on Dart 3.11 SDK constraint)

## Setup
1. Run `flutter pub get`
2. Run `flutter run`

## Implemented Features

### Section 1: Spending
- Clean Architecture layers under `lib/features/spending/{domain,data,presentation}`.
- `Dio` calls isolated to spending remote data source.
- `SpendingCubit` supports:
  - initial load
  - pagination
  - optimistic add with rollback on failure
- Dependencies are registered via `get_it` in `lib/core/di/injection.dart`.

### Section 2: Budgets
- Clean Architecture layers under `lib/features/budgets/{domain,data,presentation}`.
- Added local persistence with **Drift** (`lib/core/database/app_database.dart`).
- Added `BudgetRepository` with remote (`Dio`) + local (`Drift`) sources.
- Added `BudgetCubit` with:
  - cache-first load
  - background remote refresh
  - debounced local search (`300ms`, no API call)
  - pagination using `page` and backend `hasMore`
  - optimistic update for budget limit with rollback on PATCH failure
  - offline banner (`BudgetLoaded.isOffline == true` when serving cache after remote failure)
- Added Budget UI:
  - budget overview page
  - category cards
  - search bar
  - offline banner
  - load more
  - edit-limit flow
- Added app navigation using `go_router` with bottom navigation between Spending and Budgets.

## Important Note on Offline Behavior
- **Reads** are offline-first (cache-first).
- **Writes are not true offline-first sync** in this implementation.
- Budget limit updates are optimistic in UI/cache but still call PATCH immediately; if network is unavailable, update is rolled back and error is shown.
- This was implemented intentionally to match the task requirement for optimistic update + rollback behavior.

## Assumptions
- `total` from `GET /spending` is treated as source of truth during spending fetch/pagination.
- Optimistic spending create inserts immediately, then reconciles with server response.
- Budget refresh action avoids temporarily showing offline banner unless refresh actually fails.

## If More Time
- Implement true offline-write queue for budgets (`pendingSync` + retry + reconciliation) instead of immediate rollback on no connectivity.
- Add integration tests for budget edit rollback with forced failure header.
- Add richer error mapping (network vs validation vs server) for clearer user messaging.
