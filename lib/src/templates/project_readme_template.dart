import '../../core/configs/project_config.dart';

/// Minimal README for generated Flutter projects.
class ProjectReadmeTemplate {
  static String content(ProjectConfig config) {
    return '''
# ${config.displayName}

Proyek Flutter hasil **XProject Generator**.

## Mulai di sini

Selesaikan konfigurasi di **[GUIDE.md](GUIDE.md)** (env, flavor, run/build, CI/CD, troubleshooting).

```bash
cd ${config.appName}
flutter pub get
flutter run --flavor development -t lib/main_development.dart
```

Atau gunakan konfigurasi **Run and Debug** di `.vscode/launch.json` (pilih `[DEV]`).

Dokumentasi generator: [xproject_generator](https://pub.dev/packages/xproject_generator)
'''.trim();
  }
}
