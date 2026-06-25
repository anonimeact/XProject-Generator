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
- Pinned the Riverpod codegen stack to a set compatible with the meta version shipped by Flutter stable (`riverpod_generator 4.0.3`, analyzer-9-compatible `json_serializable`/`json_annotation`) to fix `flutter pub get` resolution failures.

### Fixes
- Fixed a Dart VM assertion crash on GetX startup caused by `StorageHelper` being used before initialization; `initApp()` now initializes storage, then env, then DI in order across all state managers.
- Corrected relative import paths for the shared widgets.

## 1.0.5

- Add Bloc State Management Option
- Add Simple and Clean Code (Using domainlayer) option when create project using Bloc and Riverpod

## 1.0.4

- Update path when generate feature for getx

## 1.0.3

- Adjust logic to load assets in lib/assets/fonts

## 1.0.2

- Move assets into lib

## 1.0.1

- Add customable TextStyle function using Inter
- Add customable AppColor
- Add api request boilerplate
- Bug Fixing

## 1.0.0

- Initial version.
