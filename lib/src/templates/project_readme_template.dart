import '../../core/configs/project_config.dart';

/// Minimal README for generated Flutter projects.
class ProjectReadmeTemplate {
  static String content(ProjectConfig config) {
    return '''
# ${config.displayName}

Flutter project scaffolded with **XProject Generator**.

## Start here

Finish setup in **[GUIDE.md](GUIDE.md)** (env, flavors, run/build, CI/CD, troubleshooting).

```bash
cd ${config.appName}
flutter pub get
flutter run --flavor development -t lib/main_development.dart
```

Or use **Run and Debug** in `.vscode/launch.json` (choose `[DEV]`).

Generator docs: [xproject_generator](https://pub.dev/packages/xproject_generator)
'''.trim();
  }
}
