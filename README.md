<div align="center">

# XProject Generator

### Scaffold production-ready Flutter apps and features in seconds

Opinionated, batteries-included templates for **GetX**, **Riverpod**, and **Bloc** — with flavors, localization, theming, token-refresh-ready networking, and beautiful starter screens out of the box.

<br/>

[![pub package](https://img.shields.io/pub/v/xproject_generator.svg?style=for-the-badge&color=0553B1)](https://pub.dev/packages/xproject_generator)
[![Dart](https://img.shields.io/badge/Dart-CLI-0553B1?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-ready-027DFD?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-success?style=for-the-badge)](LICENSE)

<br/>

<a href="#quick-start"><b>Quick Start</b></a> &nbsp;•&nbsp;
<a href="#features"><b>Features</b></a> &nbsp;•&nbsp;
<a href="#state-management"><b>State Management</b></a> &nbsp;•&nbsp;
<a href="#cli-reference"><b>CLI</b></a> &nbsp;•&nbsp;
<a href="#faq"><b>FAQ</b></a>

</div>

---

## Contents

<table>
<tr>
<td valign="top">

- [Quick Start](#quick-start)
- [Features](#features)
- [What you get](#what-a-generated-project-contains)
- [State Management](#state-management)

</td>
<td valign="top">

- [CLI Reference](#cli-reference)
- [Programmatic Usage](#programmatic-usage-dart)
- [Project Layout](#project-layout)
- [FAQ](#faq)

</td>
</tr>
</table>

---

## Quick Start

```bash
# 1. Install the CLI globally from pub.dev
dart pub global activate xproject_generator

# 2. Create a new project (interactive)
xproject

# The CLI shows step progress (0–100%) while scaffolding, then runs
# flutter pub get + build_runner in the project for you.

# 3. Finish setup using GUIDE.md, then run
cd <your_project_name>
flutter run --flavor development -t lib/main_development.dart
```

> The interactive wizard asks for app name, package IDs, **platform targets**, **state management**, architecture (Bloc/Riverpod), **Firebase**, secret key, and optional **CI/CD** (GitLab or GitHub; test-only or deploy via Fastlane; GitLab supports shared, Docker, or **self-hosted shell** runners e.g. Mac Mini). **`GUIDE.md`** is an English setup guide.

<div align="center">

```text
🚀 XProject - Flutter Project Generator

… wizard prompts …

📦 ⠹ Creating Flutter project...                         18%
✓ 📦 Creating Flutter project...                      (2.1s)
📁 ⠼ Generating project structure...                    42%
✓ ⚙ Resolving packages and running code generation...  (15.3s)

✅ Project created successfully
```

</div>

---

## Features

<table>
<tr>
<td width="33%" valign="top">

### Scaffolding
- Interactive project wizard (platform target, optional **GitLab CI** or **GitHub Actions**)
- **Create progress** — four steps with spinner, icon, and overall **0–100%**; step duration when done
- **Post-create** — `flutter pub get` + `build_runner` in the new project
- Add features to existing apps
- `flutter create --platforms` + dependency wiring
- `.vscode` tasks & launch configs (run/build per flavor)
- **`GUIDE.md`** — English setup guide (checklists; TOC links work in VS Code preview)

</td>
<td width="33%" valign="top">

### Architecture
- GetX, Riverpod, Bloc
- Simple **or** Clean Code layers
- DI-based, refresh-ready networking
- Single shared `BaseConnection`

</td>
<td width="33%" valign="top">

### Out of the box
- Flavors (dev / staging / prod)
- Localization (`en` / `id`)
- Light/dark theming + toggles
- Modern login & home screens

</td>
</tr>
</table>

<details>
<summary><b>Networking & token refresh</b></summary>

<br/>

`BaseConnection` (built on [`dio_extended`](https://pub.dev/packages/dio_extended)) is provided through dependency injection instead of a global singleton, so a refreshed token is always picked up on the next request:

| State management | How it's provided |
| --- | --- |
| **Riverpod** | `baseConnectionProvider` |
| **GetX** | `Get.put<BaseConnection>(..., permanent: true)` |
| **Bloc** | single resettable instance |

A single, fresh instance lives for the entire app lifecycle and is shared everywhere. `handleTokenExpired()` is wired for automatic 401/402 retry.

</details>

<details>
<summary><b>Theming & localization</b></summary>

<br/>

- App-wide **theme** and **locale** state with one-tap toggles on the home screen.
- Shared widgets read from `Theme.of(context)`, so switching light/dark is reflected immediately.
- Explicit light/dark `ColorScheme`, input, button, and app-bar themes in `theme/app_theme.dart`.

</details>

<details>
<summary><b>Environment & secrets</b></summary>

<br/>

- Generates `.env.development`, `.env.staging`, and `.env.production`.
- Optional **"Use Secret Key"** prompt: when enabled, `.env` files are encrypted via `secure_compressor` + a generated secret key; when disabled, plain `.env` loading is used.

</details>

---

## State Management

Pick the flavor that fits your team. Riverpod and Bloc additionally let you choose **Simple** or **Clean Code**.

<details open>
<summary><b>GetX</b></summary>

<br/>

```text
lib/features/<feature>/
├─ bindings/      # dependency wiring
├─ controllers/   # GetxController
├─ providers/     # data sources
├─ views/         # screens
└─ widgets/       # feature-local widgets (e.g. auth_scaffold, home_shell)
```

</details>

<details>
<summary><b>Riverpod (Simple / Clean Code)</b></summary>

<br/>

```text
lib/features/<feature>/
├─ data/
│  ├─ datasources/
│  ├─ models/
│  └─ repositories/        # Clean Code only
├─ domain/                 # Clean Code only
│  ├─ entities/
│  ├─ repositories/
│  └─ usecases/
└─ presentation/
   ├─ providers/
   ├─ views/
   └─ widgets/
```

Uses `riverpod_annotation` + `riverpod_generator` codegen for providers.

</details>

<details>
<summary><b>Bloc (Simple / Clean Code)</b></summary>

<br/>

```text
lib/features/<feature>/
├─ data/
│  ├─ datasources/
│  ├─ models/
│  └─ repositories/        # Clean Code only
├─ domain/                 # Clean Code only
│  ├─ entities/
│  ├─ repositories/
│  └─ usecases/
└─ presentation/
   ├─ bloc/                # bloc + event + state
   ├─ views/
   └─ widgets/
```

App-wide theme/locale handled by an `AppCubit`.

</details>

---

## CLI Reference

| Command | Description |
| --- | --- |
| `xproject` | Start the interactive project wizard |
| `xproject create` | Explicitly create a new project |
| `xproject setup` | Menu of integrations not yet installed (run inside the project) |
| `xproject setup firebase` | Add Firebase after create answered no |
| `xproject setup secret-key` | Turn on encrypted `.env` loading (`setup secret` is the same) |
| `xproject setup ci` | Add GitLab CI or GitHub Actions (`setup cicd` is the same) |
| `xproject setup platforms` | Add Flutter platforms that were not selected at create |
| `xproject setup guide` | Regenerate **`GUIDE.md`** (English) |
| `xproject --feature <name>` | Generate a feature in the current project |
| `xproject -f <name>` | Short form of `--feature` |
| `xproject --version` | Print the CLI version |
| `xproject --help` | Show help |

```bash
# Add a feature — state management & architecture are auto-detected
xproject --feature authentication
```

> When generating a feature, the tool detects your state management from `pubspec.yaml`/`lib/` usage and your architecture from the presence of `domain/` or `data/repositories/` folders, then runs `build_runner` if codegen is needed.

Setup commands read the current project (name, package, state management, platforms, and which integrations are already on). They do not ask those questions again. Run them from the generated app directory:

```bash
cd <your_project_name>
xproject setup                 # menu
xproject setup firebase        # only if create answered no to Firebase
xproject setup secret-key
xproject setup ci
xproject setup platforms
xproject setup guide           # regenerate GUIDE.md only
```

`setup firebase` does not replace a `google-services.json` or `GoogleService-Info.plist` you already downloaded. `setup secret-key` does not rewrite `.env.*` and does not invent a real secret; it writes a stub `lib/core/config/secretkey.dart` that throws until you replace it. `setup ci` asks before overwriting an existing pipeline. After setup, **`GUIDE.md`** is regenerated and the CLI notes which integration was updated (checklist in Part 2).

---

## What a generated project contains

- `lib/` with `app.dart`, environment-specific `main_*.dart`, routes, theme, l10n, sessions, and `core/`
- `lib/features/<feature>/` — views, controllers/notifiers/blocs, bindings/providers, and feature-local widgets
- `.env.development`, `.env.staging`, `.env.production`
- **`GUIDE.md`** — English setup guide; regenerated after `xproject setup`
- **`README.md`** (in generated project) — quick pointer to `GUIDE.md`
- Optional CI/CD: **`.gitlab-ci.yml`** + `ci/Dockerfile` (GitLab) or **`.github/workflows/flutter_ci.yml`** (GitHub Actions), plus `fastlane/` when deployment is enabled
- Android & iOS flavor configuration
- `.vscode/` tasks and launch helpers

```bash
cd <your_project_name>
# pub get + build_runner already ran during `xproject create`; repeat only if needed:
# flutter pub get
# dart run build_runner build --delete-conflicting-outputs
```

Follow **`GUIDE.md`** for env files, flavors, Firebase, and the rest. Quick run after checklist:

```bash
flutter run --flavor development -t lib/main_development.dart
```

Or use **Run and Debug** in VS Code (`[DEV]` / `[STG]` / production) as described in GUIDE Part 2.

---

## Programmatic Usage (Dart)

The generators can also be used directly from Dart (illustrative):

```dart
import 'package:xproject_generator/xproject_generator.dart';
import 'package:xproject_generator/xfeature_generator.dart';
import 'package:xproject_generator/xsetup_generator.dart';

Future<void> main() async {
  // Create a new project (interactive by default)
  await ProjectGenerator().create();

  // Add a feature to an existing project
  await FeatureGenerator().add('authentication');

  // Add an integration that was skipped at create time.
  // Run with the working directory set to that Flutter project.
  await SetupGenerator().firebase();
  await SetupGenerator().secretKey();
  await SetupGenerator().ciCd();
  await SetupGenerator().platforms();
  await SetupGenerator().regenerateGuide();
}
```

---

## Project Layout

| Path | Purpose |
| --- | --- |
| [`bin/xproject.dart`](bin/xproject.dart) | CLI entrypoint |
| [`lib/xproject_generator.dart`](lib/xproject_generator.dart) | Interactive project generator |
| [`lib/xfeature_generator.dart`](lib/xfeature_generator.dart) | Feature generator for existing projects |
| [`lib/xsetup_generator.dart`](lib/xsetup_generator.dart) | Post-create Firebase, secret key, CI/CD, and platforms |
| [`lib/src/post_create_codegen.dart`](lib/src/post_create_codegen.dart) | `flutter pub get` + `build_runner` after create |
| [`lib/src/cli_step_progress.dart`](lib/src/cli_step_progress.dart) | Terminal progress during create |
| [`lib/src/templates`](lib/src/templates) | Template code for GetX, Riverpod, and Bloc |
| [`CHANGELOG.md`](CHANGELOG.md) | Version history (latest **1.1.0**) |
| [`pubspec.yaml`](pubspec.yaml) | Package metadata |

---

## FAQ

<details>
<summary><b>I get a <code>flutter pub get</code> error about <code>meta</code> / <code>analyzer</code> on a Riverpod project</summary>

<br/>

This usually means an outdated Flutter SDK or a stale `pubspec.lock`. Generated Riverpod projects use `riverpod_generator ^4.0.9` with `build_runner ^2.16.0` (newer `build_runner` 2.17+ is not yet compatible with `riverpod_generator`). Upgrade Flutter **stable**, delete `pubspec.lock`, then run `flutter pub get` again.

</details>

<details>
<summary><b>How do I enable Firebase?</b></summary>

<br/>

Answer **yes** to the Firebase prompt during creation, or from the project directory run:

```bash
xproject setup firebase
```

Then replace the placeholders (these files are not overwritten if they already exist):

- `android/app/src/<flavor>/google-services.json` for `development`, `staging`, and `production`
- `ios/config/<flavor>/GoogleService-Info.plist`

The iOS flavor script lives at `ios/firebase.sh`. In Xcode, add a Run Script phase that runs it before Copy Bundle Resources. `xproject setup secret-key` and `xproject setup ci` cover the other optional prompts from create.

</details>

<details>
<summary><b>Can I switch state management after creating a project?</b></summary>

<br/>

Not automatically — the scaffolding differs per state manager. Create a new project with the desired option, or migrate manually.

</details>

<details>
<summary><b>Android build fails after upgrading to AGP 8+ / 9+ (custom resource values disabled)</b></summary>

<br/>

Newer Android Gradle Plugin versions disable `resValue()` generation unless you enable it. Generated projects include `buildFeatures { resValues = true }` (or `resValues true` in Groovy) and set `android:label="@string/app_name"` in the manifest so flavor-specific app names work.

If you created a project with an older generator version, add the same `buildFeatures` block to `android/app/build.gradle(.kts)` and point the manifest label at `@string/app_name`.

</details>

<details>
<summary><b>Built-in Kotlin (AGP 9) and <code>gradle.properties</code> flags</b></summary>

<br/>

Generated Android projects follow Flutter’s [built-in Kotlin migration for app developers](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers): the `:app` module does not apply the Kotlin Gradle Plugin directly, and uses `kotlin { compilerOptions { … } }` with JVM 17 when the Flutter template provides it.

`android/gradle.properties` includes `android.newDsl=false` and `android.builtInKotlin=false` (Flutter’s transitional default). After your app and its Flutter plugins support built-in Kotlin, set `android.builtInKotlin=true` and run `flutter build apk` to validate. If a plugin still applies KGP and breaks the build, use the [report template](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers#report-incompatible-kotlin-gradle-plugin-usage-to-plugin-authors) on the plugin’s repository.

</details>

---

## Contributing

Contributions are welcome. Keep changes small and focused, open issues for bugs or feature requests, and send pull requests for improvements to templates or tooling.

<div align="center">

Made with Dart • Licensed under [MIT](LICENSE)

</div>
