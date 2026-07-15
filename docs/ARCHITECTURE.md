# AIMORA — Architecture

AIMORA follows **Clean Architecture** split into three layers, plus a thin
Flutter-specific presentation layer on top. Dependencies always point
inward: `presentation → domain ← data`.

```
lib/
├── core/                    # Cross-cutting, framework-facing concerns
│   ├── constants/           # App-wide constant values & storage keys
│   ├── services/            # StorageService, OverlayService, PermissionService
│   └── theme/                # Material 3 ColorScheme, typography, palette
│
├── domain/                  # Pure Dart, zero Flutter/plugin imports
│   └── entities/             # CrosshairType enum (the core business concept)
│
├── data/                    # Data layer — models + (de)serialization
│   ├── models/                # CrosshairConfig, PresetModel, ProfileModel
│   └── repositories/          # (reserved for future remote sync / cloud backup)
│
├── presentation/            # Flutter UI layer
│   ├── providers/             # Riverpod StateNotifiers (state management)
│   ├── screens/                # Splash, Onboarding, Home, Gallery, Overlay
│   │                            Control, Settings, Profile
│   └── widgets/                # CrosshairPainter, CrosshairPreview, AppLogo
│
└── overlay/                 # Secondary Flutter engine entry point
    └── overlay_main.dart      # Renders the full-screen system overlay
```

## Why this shape

- **`domain/entities`** never imports Flutter or a plugin — `CrosshairType`
  is just an enum. This keeps the core vocabulary of the app testable in
  pure Dart and swappable independent of any UI framework decision.
- **`data/models`** are immutable, `copyWith`-friendly, JSON round-trippable
  value objects. No code generation (`build_runner`) is required, which
  keeps CI fast and avoids generated-file drift.
- **`core/services`** wrap every plugin call (`shared_preferences`,
  `flutter_overlay_window`, `permission_handler`) behind a small
  interface. Screens and providers never call a plugin directly — this is
  the seam a future contributor would use to add cloud sync or write
  a fake `StorageService` for widget tests.
- **`presentation/providers`** hold all mutable app state via
  `StateNotifier` (Riverpod). Screens are effectively stateless: they
  `ref.watch` a provider, render, and call a notifier method on
  interaction — a strict one-way data flow that keeps the UI layer thin
  and easy to reason about.

## State management: Riverpod

Riverpod was chosen over Bloc/Provider/GetX because:

1. Compile-safe DI — every service (`StorageService`, `OverlayService`,
   `PermissionService`) is itself a `Provider`, so screens/tests can
   override any dependency via `ProviderScope(overrides: [...])`
   without a service locator or `BuildContext` plumbing.
2. `StateNotifier` gives a clear, testable, single-direction API
   (`setSize`, `setColor`, `toggle`, …) instead of a generic
   `emit(state)` call scattered across the UI.
3. No `BuildContext` requirement for reading state outside `build()`
   (used in `OverlayControlScreen._toggleOverlay`, for example).

## The overlay: two Flutter engines, one config

Android's "draw over other apps" surface cannot host the same widget
tree as the main Activity — it is a separate `WindowManager` layer. The
`flutter_overlay_window` plugin solves this by spinning up a **second,
independent Flutter engine** whose Dart entry point is the top-level
`overlayMain()` function in `lib/overlay/overlay_main.dart` (kept alive by
the `@pragma('vm:entry-point')` annotation so the tree shaker never
strips it).

Both engines share **the same `CrosshairPainter`** — so what you see in
the in-app preview is pixel-identical to what appears floating over your
game. State is bridged one-directionally, main app → overlay, through
`FlutterOverlayWindow.shareData()` / `overlayListener`, carrying the
`CrosshairConfig.toJson()` payload. The overlay engine has no
knowledge of Riverpod, presets, or profiles — it is a dumb, maximally
efficient renderer, which keeps its frame time minimal since it repaints
on every game frame while the user is playing.

## Offline-first storage

Every piece of user data — theme, language, the active crosshair,
favorites, presets, and profiles — is persisted as JSON in
`SharedPreferences` through `StorageService`. There is no network
dependency anywhere in the core flow: AIMORA opens instantly and works
fully in airplane mode, which matters because most users open it
*while already inside a game* with unstable or no connectivity.

## SOLID in practice

- **S**ingle responsibility — each service does exactly one plugin's job;
  each provider owns exactly one slice of state.
- **O**pen/closed — adding an 11th crosshair type means adding one enum
  value + one `case` in `CrosshairPainter.paint()`; no existing type's
  code changes.
- **L**iskov — `CrosshairConfig`, `PresetModel`, `ProfileModel` are all
  immutable value types with total `fromJson`/`toJson` — any instance is
  freely substitutable anywhere its type is expected.
- **I**nterface segregation — `PermissionService` and `OverlayService` are
  deliberately separate, even though the latter depends on the former,
  so a screen that only needs to check permission status doesn't pull in
  overlay lifecycle methods.
- **D**ependency inversion — screens depend on `StorageService`/
  `OverlayService` abstractions exposed via Riverpod providers, never on
  `shared_preferences` or `flutter_overlay_window` directly.
