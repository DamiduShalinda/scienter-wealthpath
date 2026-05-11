# WealthPath Assessment

## Flutter Version
- Flutter `3.19+` compatible
- Dart `3.3+` compatible (project currently on Dart 3.11 SDK constraint)

## Setup
1. Run `flutter pub get`
2. Run `flutter run`

## Section 1 Notes
- Clean Architecture layers are separated under `lib/features/spending/{domain,data,presentation}`.
- `Dio` calls are isolated to the spending remote data source.
- `SpendingCubit` handles loading, pagination, optimistic create, and rollback on failure.
- Dependencies are registered in `lib/core/di/injection.dart` using `get_it`.

## Assumptions
- `total` returned by `GET /spending` is treated as source of truth for list totals during fetch/pagination.
- Optimistic create updates visible list immediately and replaces temp item with server item on success.

## If More Time
- Add integration tests for optimistic rollback and infinite scrolling.
- Add structured failure mapping (e.g., validation vs network) for better user messaging.
