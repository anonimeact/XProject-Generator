## 1.1.1

### CLI (create & setup)
- CI/CD wizard prompts are **English only** (scope, GitLab runner modes, deployment channels, platform validation messages).
- Generated project **`README.md`** is English only (aligned with English-only `GUIDE.md`).

## 1.1.0

### Generated `BaseConnection` (token & refresh)
- New **Provider** state management option (`provider` + `go_router`); the connection is created once by `Provider<BaseConnection>` in `app.dart` and injected with `context.read<BaseConnection>()`.
- Auth/refresh logic is now **shared and identical** for GetX, Riverpod, Bloc and Provider; only how the single instance is provided differs (GetX permanent `Get.put`, Riverpod `keepAlive` provider, Bloc lazy singleton, Provider `Provider<BaseConnection>`).
- New helpers: `saveSession(token:, refreshToken:)`, `clearSession()`, `updateAuthHeaders()`, `clearAuthHeaders()`. Call `saveSession` after login so the token reaches the live connection (previously headers were built once in the constructor and the token was never applied).
- `handleTokenExpired()` now runs a real refresh flow (reads the stored refresh token, calls the refresh endpoint, saves rotated tokens, returns auth headers). Adjust endpoint / response keys to your API. A failed refresh fails the request cleanly (no retry loop).
- Fixed: the instance is no longer replaced on refresh (`Get.delete` + `Get.put` in GetX, `reset()` in Bloc). `DioExtended` already updates the headers of the same instance and retries the request.
- Fixed: Riverpod `baseConnection` was auto-disposed; it is now `keepAlive`.
- Fixed: no more empty `Bearer ` header before login.
- `UserSessions` gains `saveRefreshToken` / `getRefreshToken`; fixed the Riverpod `UserModel` import path.

### CLI — `xproject create`
- **Step progress** while scaffolding: icon + spinner, label, and **overall percentage** on the right (four steps: 0→25→50→75→100%). When a step finishes, the line shows **✓** and **total duration** (e.g. `(4.2s)`) instead of a ticking timer.
- After create, runs **`flutter pub get`** and **`dart run build_runner build`** so generated apps have l10n and `*.freezed.dart` / `*.g.dart` before you open the IDE (GetX, Riverpod, and Bloc).

### Setup commands (`xproject setup …`)
- Run inside the generated Flutter project to add integrations skipped at create time.
- **`xproject setup firebase`** — packages, splash, Gradle plugins, native placeholders; does not overwrite real `google-services.json` / `GoogleService-Info.plist` / `firebase_service.dart`.
- **`xproject setup secret-key`** (alias `secret`) — encrypted `.env` flow + stub `secretkey.dart` until you replace it with `secret_key_scrypt_generator`.
- **`xproject setup ci`** (alias `cicd`) — GitLab CI or GitHub Actions (+ optional Fastlane); confirms before overwriting existing pipeline files.
- **`xproject setup platforms`** — `flutter create --platforms …` for missing platforms, then flavor wiring when Android/iOS is new.
- Unknown setup subcommands exit with an error instead of opening the interactive menu.
- **`GUIDE.md`** is **regenerated** when a setup command changes the project; the CLI reports which integration was refreshed (checklists live in Part 2).

### Wizard & scaffolding
- **`GUIDE.md`** is **English only**; regenerated when setup changes the project (CLI notes which integration was refreshed).
- **Platform target** multi-select; `flutter create` passes `--platforms` (default Android + iOS).
- Wizard order after platforms: **state management** → **architecture** (Bloc/Riverpod) → **Firebase** → secret key → CI/CD.
- Optional **CI/CD**: **GitLab CI** or **GitHub Actions**; CI-only or **CI + deployment** (Fastlane: Play internal, TestFlight, Firebase App Distribution, artifacts-only).
- GitLab runner modes: shared Flutter image, **self-hosted shell** (`ci/GITLAB_RUNNER_SETUP.md`), or self-hosted Docker (`ci/Dockerfile`).
- GitHub: `.github/workflows/flutter_ci.yml` with `ubuntu-latest` / `macos-latest`.

### Generated `GUIDE.md`
- **Part 1** — prerequisites, project summary, folder tour.
- **Part 2** — numbered setup sections with `- [ ]` checklists (env, secret key, codegen, Android/iOS flavor, Firebase, CI/CD, run app, VS Code).
- **English-only** body; two-part structure with VS Code–friendly TOC anchors.
- Table of contents links match **VS Code Markdown preview** heading IDs (GitHub-style slugs + duplicate-heading handling).
- Copy pass: shorter meta intros, clearer VS Code vs terminal wording; Android section highlights **Run and Debug** / `.vscode/launch.json` per flavor.
- Sections and `.gitignore` entries follow wizard choices (Firebase, secret key, CI/CD, platforms).

### Generated project docs & DX
- Minimal generated **`README.md`** pointing to `GUIDE.md`.
- **`.vscode/`** from `VsCodeConfigBuilder` (launch per flavor, tasks including **Build AppBundle - Development**).
- **`smoke_test.dart`** when CI is enabled.
- Conditional generation audit: CI/Fastlane, VS Code tasks, gitignore paths, and related files only when selected.

### Templates & fixes
- Import `ShakeChuckerConfigs` / `ShakeForChucker` from `package:dio_extended/diox_chucker.dart` (`dio_extended` 2.x).
- Firebase placeholder **`google-services.json`** and **`GoogleService-Info.plist`** are valid JSON/XML; Google Services **4.4.2** and Crashlytics Gradle **3.0.3** on new Firebase projects.
- Template dependency bumps: Firebase Flutter 5.x stack, `dio_extended` 2.x, `freezed` 4.x, Riverpod 3.4 / `riverpod_generator` 4.0.9, `go_router` 18.x, `equatable` 3.x, `xwidgets_pack` 1.3.x.
- Generator package: `mason_logger`, `lints`, `test` updates; expanded tests (CI templates, gitignore, GUIDE sections, setup integrations, Android Gradle patches, post-create codegen).

## 1.0.6

### Architecture & token refresh
- Replaced the singleton `BaseConnection` with proper dependency injection so refreshed tokens are always picked up:
  - Riverpod: `baseConnectionProvider`
  - GetX: a permanent `AppController` + `Get.put<BaseConnection>(...)`
  - Bloc: a single resettable instance
- A single, fresh `BaseConnection` instance now lives for the whole app lifecycle and is shared across providers/controllers.
- Switched `DioExtended` initialization to the synchronous `headers` API (instead of `headersAsync`) across all templates.

### Project structure
- Moved shared widgets out of `core/widgets` into the feature that uses them (`AuthScaffold` → login feature, `HomeShell` → home feature). Truly shared widgets can live in `lib/widgets`.

### Dependencies & configuration
- Bumped all template dependencies to their latest versions.
- Added an optional "Use Secret Key (Generator Package)?" prompt to conditionally encrypt `.env` files.
- Pinned the Riverpod codegen stack to a set compatible with the meta version shipped by Flutter stable (`riverpod_generator` 4.0.3, analyzer-9-compatible `json_serializable`/`json_annotation`) to fix `flutter pub get` resolution failures.

### Fixes
- Fixed a Dart VM assertion crash on GetX startup caused by `StorageHelper` being used before initialization; `initApp()` now initializes storage, then env, then DI in order across all state managers.
- Corrected relative import paths for the shared widgets.

## 1.0.5

- Add Bloc state management option.
- Add Simple and Clean Code (domain layer) options when creating a project with Bloc or Riverpod.

## 1.0.4

- Update paths when generating features for GetX.

## 1.0.3

- Adjust logic to load assets in `lib/assets/fonts`.

## 1.0.2

- Move assets into `lib`.

## 1.0.1

- Add customizable `TextStyle` helper using Inter.
- Add customizable `AppColor`.
- Add API request boilerplate.
- Bug fixes.

## 1.0.0

- Initial release.
