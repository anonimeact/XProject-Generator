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

# 3. Run it
cd <your_project_name>
flutter pub get
flutter run --flavor development -t lib/main_development.dart
```

> The interactive wizard asks for app name, package IDs, Firebase, state management, architecture, and whether to encrypt `.env` files.

<div align="center">

```text
🚀 XProject - Flutter Project Generator

✔ App display name (e.g. Test App) · My App
✔ Project name (snake_case) · my_app
✔ Android package (e.g., com.example.app) · com.example.my_app
✔ iOS bundle ID · com.example.my_app
✔ Use Firebase? (Y/n): · n
✔ Select state management · Riverpod
✔ Select architecture · Clean Code
✔ Use Secret Key (Generator Package)? (Y/n): · y
```

</div>

---

## Features

<table>
<tr>
<td width="33%" valign="top">

### Scaffolding
- Interactive project wizard
- Add features to existing apps
- `flutter create` + dependency wiring
- `.vscode` tasks & launch configs

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
| `xproject --feature <name>` | Generate a feature in the current project |
| `xproject -f <name>` | Short form of `--feature` |
| `xproject --version` | Print the CLI version |
| `xproject --help` | Show help |

```bash
# Add a feature — state management & architecture are auto-detected
xproject --feature authentication
```

> When generating a feature, the tool detects your state management from `pubspec.yaml`/`lib/` usage and your architecture from the presence of `domain/` or `data/repositories/` folders, then runs `build_runner` if codegen is needed.

---

## What a generated project contains

- `lib/` with `app.dart`, environment-specific `main_*.dart`, routes, theme, l10n, sessions, and `core/`
- `lib/features/<feature>/` — views, controllers/notifiers/blocs, bindings/providers, and feature-local widgets
- `.env.development`, `.env.staging`, `.env.production`
- Android & iOS flavor configuration
- `.vscode/` tasks and launch helpers

```bash
cd <your_project_name>
flutter pub get
# If using codegen (freezed / riverpod):
dart run build_runner build --delete-conflicting-outputs
```

---

## Programmatic Usage (Dart)

The generators can also be used directly from Dart (illustrative):

```dart
import 'package:xproject_generator/xproject_generator.dart';
import 'package:xproject_generator/xfeature_generator.dart';

Future<void> main() async {
  // Create a new project (interactive by default)
  await ProjectGenerator().create();

  // Add a feature to an existing project
  await FeatureGenerator().add('authentication');
}
```

---

## Project Layout

| Path | Purpose |
| --- | --- |
| [`bin/xproject.dart`](bin/xproject.dart) | CLI entrypoint |
| [`lib/xproject_generator.dart`](lib/xproject_generator.dart) | Interactive project generator |
| [`lib/xfeature_generator.dart`](lib/xfeature_generator.dart) | Feature generator for existing projects |
| [`lib/src/templates`](lib/src/templates) | Template code for GetX, Riverpod, and Bloc |
| [`pubspec.yaml`](pubspec.yaml) | Package metadata |

---

## FAQ

<details>
<summary><b>I get a <code>flutter pub get</code> error about <code>meta</code> / <code>analyzer</code> on a Riverpod project</summary>

<br/>

This happens when the Flutter stable SDK pins an older `meta` while the newest `riverpod_generator` requires a newer `analyzer`. Generated Riverpod projects pin a compatible codegen stack (`riverpod_generator 4.0.3` with analyzer-9-compatible `json_serializable`/`json_annotation`) to avoid this. Make sure you're on a recent Flutter **stable** channel and run `flutter pub get` again.

</details>

<details>
<summary><b>How do I enable Firebase?</b></summary>

<br/>

Answer **yes** to the Firebase prompt during creation, then add your platform files:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

The iOS flavor script lives at `ios/firebase.sh`; follow the on-screen Xcode steps printed after generation.

</details>

<details>
<summary><b>Can I switch state management after creating a project?</b></summary>

<br/>

Not automatically — the scaffolding differs per state manager. Create a new project with the desired option, or migrate manually.

</details>

---

## Contributing

Contributions are welcome. Keep changes small and focused, open issues for bugs or feature requests, and send pull requests for improvements to templates or tooling.

<div align="center">

Made with Dart • Licensed under [MIT](LICENSE)

</div>
