# Nokta — Agent Instructions

Flutter ride-hailing / delivery MVP template. Architecture aligned with Technology 92 conventions.

## Stack

- **Architecture**: Clean Architecture + BLoC, sub-feature folders under `lib/features/<domain>/`
- **State**: `flutter_bloc` (BLoC for features, Cubit for settings/connectivity)
- **Routing**: `go_router` — use `RouteNames` in `lib/config/routes/route_names.dart`
- **DI**: GetIt in `lib/injection_container.dart`
- **i18n**: `easy_localization` + JSON in `assets/translations/` (not ARB)
- **Offline**: Hive cache under `core/cache/` + `ConnectivityCubit` + `SyncService`

## Folder layout

```
lib/
├── main.dart, app.dart, injection_container.dart
├── config/          # routes, theme, environment
├── core/            # api, error, usecase, network, sync, map utils
├── shared/          # spacing, buttons, inputs, banners, navigation, branding
└── features/
    ├── settings/
    ├── auth/        # shared/ + splash, onboarding, auth_select, login, register, forgot_password
    ├── home/        # main_shell, map_view, ride_request
    ├── trips/       # shared/ + trip_list, trip_detail, tracking
    ├── notifications/  # shared/ + notification_list
    └── profile/     # shared/ + profile_view, orders
```

## Rules

- BLoCs call **use cases** returning `Either<Failure, T>` (dartz), not repositories directly.
- Domain layer has no Flutter imports.
- Use `AppColors` / `AppSpacing` design tokens — avoid hardcoded colors.
- App display name is **Nokta** (`AppConstants.appName`); UI strings use `app_name` in translations.
- Keep ride-hailing domain (maps, trips, FCM, Hive) — do not port tech92 attendance/KPI features.
- Secrets via `--dart-define` + `EnvConfig` when adding real API keys.

## Key entry points

| File | Purpose |
|------|---------|
| `lib/main.dart` | Init: Firebase, Hive, DI, EasyLocalization |
| `lib/app.dart` | MaterialApp.router + global providers |
| `lib/config/routes/app_router.dart` | GoRouter + auth redirects |
| `lib/injection_container.dart` | GetIt registrations |
