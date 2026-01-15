# XProject Generator

XProject Generator is a command-line tool and library to scaffold Flutter applications
and feature modules using opinionated, production-ready templates. It supports both
GetX and Riverpod state management and automates common setup tasks such as environment files, flavors, localization, and example features.

Key features
- Interactive project creation with prompts for app name, package IDs, Firebase, and state management
- Generate feature templates inside an existing project (GetX or Riverpod)
- Create environment files (`.env.*`) and platform flavor configuration (Android & iOS)
- Optional Firebase initialization helpers and platform config templates
- Templates for themes, localization, base API connection, sessions, and example features

Repository layout (important files)
- [bin/xproject.dart](bin/xproject.dart) — CLI entrypoint
- [lib/xproject_generator.dart](lib/xproject_generator.dart) — interactive project generator
- [lib/xfeature_generator.dart](lib/xfeature_generator.dart) — feature generator for existing projects
- [lib/src](lib/src) — generators and template code
  - [lib/src/templates](lib/src/templates) — template implementations for GetX and Riverpod
- [pubspec.yaml](pubspec.yaml)

Installation

From pub.dev (recommended)

```bash
# Install globally from pub.dev:
dart pub global activate xproject_generator
#
# (Optional) Install a specific version:
dart pub global activate xproject_generator 1.2.3

# Run the CLI (executable is `xproject`):
xproject --help
```

Usage

Create a new project (interactive):

```bash
# Interactive: prompts for project name, package IDs, Firebase, and state management
xproject
# Or explicitly
xproject create
```

Add a new feature to an existing Flutter project:

```bash
# Generates feature templates inside the current Flutter project
xproject --feature authentication
# Short option
xproject -f authentication
```

Show version/help

```bash
xproject --version
xproject --help
```

What the generators do

- `ProjectGenerator`:
  - Prompts for app display name, project name (snake_case), Android package, iOS bundle id, Firebase usage, and state management (GetX or Riverpod).
  - Runs `flutter create`, updates `pubspec.yaml` with selected dependencies, creates folders and template files, creates `.env.*` placeholders, and writes recommended `.vscode` tasks/launch configs.

- `FeatureGenerator`:
  - Detects state management by inspecting `pubspec.yaml` and scanning `lib/` for common usage indicators (e.g., `GetMaterialApp`, `GoRouter`).
  - Generates feature files and folders under `lib/features/<feature>` using templates for the detected state management.
  - Runs `dart run build_runner build --delete-conflicting-outputs` after generation to produce generated code artifacts.

Templates

Templates live in the repository under `lib/src/templates` and include:
- `common_templates.dart` — shared snippets (theme, env helpers, app widget, firebase helpers)
- `getx/` — GetX-specific feature and app templates
- `riverpod/` — Riverpod-specific feature and app templates

Post-creation steps

1. Change directory into the newly created project:

```bash
cd <your_project_name>
flutter pub get
```

2. If you enabled Firebase, add your platform files:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

3. Run build_runner to generate code for freezed/riverpod generators (if used):

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Example

CLI quick-start (interactive)

```bash
# Start interactive project creation
xproject

# Explicit create command
xproject create

# Add a feature to an existing Flutter project
xproject --feature authentication
# Short option
xproject -f authentication

# Show version/help
xproject --version
xproject --help
```

Non-interactive (one-liners)

```bash
# Create a new project with explicit arguments (if supported by your CLI version)
xproject create --name my_app --android com.example.myapp --ios com.example.myapp

# Generate a feature (state management is auto-detected)
xproject --feature auth

Note: When creating a new project the CLI will prompt you to choose a state
management option (GetX or Riverpod). When generating features, state management
is detected automatically based on your project's dependencies and source files;
you do not need to pass a `--state-management` flag when generating features.
```

Programmatic usage (Dart)

The library can also be used directly from Dart code. The following example shows basic usage of the `ProjectGenerator` and `FeatureGenerator` APIs (illustrative):

```dart
import 'package:xproject_generator/xproject_generator.dart';
import 'package:xproject_generator/xfeature_generator.dart';

Future<void> main() async {
  // Create a new project (interactive by default)
  final projectGen = ProjectGenerator();
  await projectGen.create();

  // Add a feature programmatically to an existing project
  final featureGen = FeatureGenerator();
  await featureGen.add('authentication');
}
```

What a generated project contains

- `lib/` and `lib/features/<feature>/` (views, controllers/notifiers, bindings/providers)
- `.env.development`, `.env.production` placeholder files
- Platform flavor configuration for Android and iOS
- `.vscode` tasks and launch helpers for common workflows

Post-generation quick steps

```bash
cd <your_project_name>
flutter pub get
# If using codegen (freezed/riverpod):
flutter pub run build_runner build --delete-conflicting-outputs
```

Contributing

Contributions are welcome. Keep changes small and focused. Please open issues for
bugs or feature requests and send pull requests for improvements to templates or tooling.

License

See `pubspec.yaml` for licensing information.

If you want, I can also add example screenshots of the interactive prompts, or add a short
`CONTRIBUTING.md` with development steps. What would you like next?
