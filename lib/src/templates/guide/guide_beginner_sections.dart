import '../../../core/configs/project_config.dart';
import 'guide_labels.dart';
import 'guide_localization.dart';
import 'markdown_github_slug.dart';

/// Numbered sections and checklist items for GUIDE Bagian 2.
class _Part2ChecklistWriter {
  _Part2ChecklistWriter(this.buffer);

  final StringBuffer buffer;
  int sectionIndex = 0;

  void beginSection(String title, String slug) {
    sectionIndex++;
    buffer.writeln('### $sectionIndex. $title');
    buffer.writeln();
  }

  void check(String text) {
    buffer.writeln('- [ ] $text');
  }
}

typedef _Part2SectionEntry = ({String title, String slug});

/// Long-form GUIDE sections for developers new to Flutter.
class GuideBeginnerSections {
  static String _docTitle(ProjectConfig config) => guideText(
        config,
        en: 'Setup guide: ${config.displayName}',
        id: 'Panduan setup: ${config.displayName}',
      );

  static String _partOneTitle(ProjectConfig config) => guideText(
        config,
        en: 'Part 1: Understanding the project',
        id: 'Bagian 1: Memahami proyek',
      );

  static String _partTwoTitle(ProjectConfig config) => guideText(
        config,
        en: 'Part 2: Configuration to complete',
        id: 'Bagian 2: Konfigurasi yang perlu diselesaikan',
      );

  static String _vscodeSectionTitle(ProjectConfig config) => guideText(
        config,
        en: 'VS Code: run & build',
        id: 'VS Code: run & build',
      );

  static String _tableOfContentsTitle(ProjectConfig config) => guideText(
        config,
        en: 'Table of contents',
        id: 'Daftar isi',
      );

  static String _prerequisitesTitle(ProjectConfig config) => guideText(
        config,
        en: 'Prerequisites & environment check',
        id: 'Prasyarat & cek lingkungan',
      );

  static String _whatToInstallTitle(ProjectConfig config) => guideText(
        config,
        en: 'What to install',
        id: 'Yang perlu diinstall',
      );

  static String _verificationTitle(ProjectConfig config) => guideText(
        config,
        en: 'Verification',
        id: 'Verifikasi',
      );

  static String _projectSummaryTitle(ProjectConfig config) => guideText(
        config,
        en: 'Project summary',
        id: 'Ringkasan proyek',
      );

  static String _identifiersPerFlavorTitle(ProjectConfig config) => guideText(
        config,
        en: 'Identifiers per flavor',
        id: 'Identifier per flavor',
      );

  static String _folderStructureTitle(ProjectConfig config) => guideText(
        config,
        en: 'Folder structure',
        id: 'Struktur folder',
      );

  static String _glossaryTitle(ProjectConfig config) => guideText(
        config,
        en: 'Glossary',
        id: 'Glosarium',
      );

  static String _learnMoreTitle(ProjectConfig config) => guideText(
        config,
        en: 'Learn more',
        id: 'Belajar lanjut',
      );

  static String _troubleshootingTitle(ProjectConfig config) => guideText(
        config,
        en: 'Troubleshooting',
        id: 'Troubleshooting',
      );

  static String _partOneLinkLabel(ProjectConfig config) => guideText(
        config,
        en: 'Part 1',
        id: 'Bagian 1',
      );

  static String _partOneSectionAnchor(
    ProjectConfig config,
    int sectionNumber,
    String Function(ProjectConfig) titleFn,
  ) {
    return '#${markdownPreviewHeadingSlug('$sectionNumber. ${titleFn(config)}')}';
  }

  static List<_Part2SectionEntry> _partTwoSections(ProjectConfig config) {
    final sections = <_Part2SectionEntry>[
      (
        title: guideText(
          config,
          en: 'Initial steps & dependencies',
          id: 'Langkah awal & dependency',
        ),
        slug: 'langkah-awal',
      ),
      (
        title: guideText(
          config,
          en: 'Environment files (`.env`)',
          id: 'File environment (`.env`)',
        ),
        slug: 'file-env',
      ),
    ];
    if (config.useSecretKey) {
      sections.add((
        title: guideText(
          config,
          en: 'Secret key (SecureCompressor)',
          id: 'Secret key (SecureCompressor)',
        ),
        slug: 'secret-key',
      ));
    }
    sections.add((
      title: guideText(
        config,
        en: 'Code generation (build_runner)',
        id: 'Code generation (build_runner)',
      ),
      slug: 'build-runner',
    ));
    if (config.targetsAndroid) {
      sections.add((
        title: guideText(config, en: 'Android', id: 'Android'),
        slug: 'android',
      ));
    }
    if (config.targetsIos) {
      sections.add((
        title: guideText(
          config,
          en: 'iOS flavor (Xcode)',
          id: 'iOS flavor (Xcode)',
        ),
        slug: 'ios-flavor',
      ));
    }
    if (config.useFirebase) {
      sections.add((
        title: guideText(config, en: 'Firebase', id: 'Firebase'),
        slug: 'firebase',
      ));
    }
    if (config.hasCiCd) {
      sections.add((
        title: config.usesGitHubActions
            ? guideText(
                config,
                en: 'CI/CD (GitHub Actions)',
                id: 'CI/CD (GitHub Actions)',
              )
            : guideText(
                config,
                en: 'CI/CD (GitLab)',
                id: 'CI/CD (GitLab)',
              ),
        slug: config.usesGitHubActions ? 'cicd-github' : 'cicd-gitlab',
      ));
    }
    sections.add((
      title: guideText(
        config,
        en: 'Running the app',
        id: 'Menjalankan aplikasi',
      ),
      slug: 'menjalankan-app',
    ));
    sections.add((
      title: _vscodeSectionTitle(config),
      slug: 'vscode',
    ));
    return sections;
  }

  static void _seedSlugBuilderBeforePartTwoSections(
    MarkdownPreviewSlugBuilder builder,
    ProjectConfig config,
  ) {
    builder.add(_docTitle(config));
    builder.add(_tableOfContentsTitle(config));
    builder.add(_partOneTitle(config));
    builder.add(_partTwoTitle(config));
    builder.add(_partOneTitle(config));
    builder.add('1. ${_prerequisitesTitle(config)}');
    builder.add(_whatToInstallTitle(config));
    builder.add(_verificationTitle(config));
    builder.add('2. ${_projectSummaryTitle(config)}');
    builder.add(_identifiersPerFlavorTitle(config));
    builder.add('3. ${_folderStructureTitle(config)}');
    builder.add(_partTwoTitle(config));
  }

  static Map<String, String> _partTwoSectionAnchors(ProjectConfig config) {
    final builder = MarkdownPreviewSlugBuilder();
    _seedSlugBuilderBeforePartTwoSections(builder, config);
    final anchors = <String, String>{};
    final sections = _partTwoSections(config);
    for (var i = 0; i < sections.length; i++) {
      final section = sections[i];
      final id = builder.add('${i + 1}. ${section.title}');
      anchors[section.slug] = '#$id';
    }
    return anchors;
  }

  static String part2LinkForSlug(ProjectConfig config, String slug) {
    return _partTwoSectionAnchors(config)[slug] ?? '#';
  }

  static String _partTwoSectionTitle(ProjectConfig config, String slug) {
    for (final entry in _partTwoSections(config)) {
      if (entry.slug == slug) {
        return entry.title;
      }
    }
    return slug;
  }

  static void tableOfContents(StringBuffer buffer, ProjectConfig config) {
    final partOne = _partOneTitle(config);
    final partTwo = _partTwoTitle(config);
    buffer.writeln('## ${_tableOfContentsTitle(config)}');
    buffer.writeln();
    buffer.writeln(
      '### [$partOne](#${markdownPreviewHeadingSlug(partOne)})',
    );
    buffer.writeln(
      '1. [${_prerequisitesTitle(config)}](${_partOneSectionAnchor(config, 1, _prerequisitesTitle)})',
    );
    buffer.writeln(
      '2. [${_projectSummaryTitle(config)}](${_partOneSectionAnchor(config, 2, _projectSummaryTitle)})',
    );
    buffer.writeln(
      '3. [${_folderStructureTitle(config)}](${_partOneSectionAnchor(config, 3, _folderStructureTitle)})',
    );
    buffer.writeln();
    buffer.writeln(
      '### [$partTwo](#${markdownPreviewHeadingSlug(partTwo)})',
    );
    final partTwoAnchors = _partTwoSectionAnchors(config);
    final partTwoSections = _partTwoSections(config);
    for (var i = 0; i < partTwoSections.length; i++) {
      final section = partTwoSections[i];
      final label = section.title.replaceAll('`', '');
      buffer.writeln(
        '${i + 1}. [$label](${partTwoAnchors[section.slug]})',
      );
    }
    buffer.writeln();
    final troubleshooting = _troubleshootingTitle(config);
    final learnMore = _learnMoreTitle(config);
    final glossary = _glossaryTitle(config);
    buffer.writeln(
      '- [$troubleshooting](#${markdownPreviewHeadingSlug(troubleshooting)})',
    );
    buffer.writeln(
      '- [$learnMore](#${markdownPreviewHeadingSlug(learnMore)})',
    );
    buffer.writeln(
      '- [$glossary](#${markdownPreviewHeadingSlug(glossary)})',
    );
    buffer.writeln();
  }

  static void partOneHeader(StringBuffer buffer, ProjectConfig config) {
    buffer.writeln('# ${_partOneTitle(config)}');
    buffer.writeln();
  }

  static void partTwoHeader(StringBuffer buffer, ProjectConfig config) {
    buffer.writeln('# ${_partTwoTitle(config)}');
    buffer.writeln();
  }

  static void configurationChecklists(StringBuffer buffer, ProjectConfig config) {
    final w = _Part2ChecklistWriter(buffer);

    w.beginSection(_partTwoSectionTitle(config, 'langkah-awal'), 'langkah-awal');
    buffer.writeln(
      guideText(
        config,
        en: 'Ensure the Flutter project is **ready to build** before filling in `.env` or native setup. '
            'This step confirms Dart packages are fetched and the toolchain (Android SDK, Xcode, etc.) is healthy.',
        id: 'Pastikan proyek Flutter **siap di-build** sebelum mengisi `.env` atau native setup. '
            'Langkah ini memastikan paket Dart terunduh dan toolchain (Android SDK, Xcode, dll.) tidak bermasalah.',
      ),
    );
    buffer.writeln();
    w.check(
      guideText(
        config,
        en: 'Change to the project folder: `cd ${config.appName}`',
        id: 'Masuk ke folder proyek: `cd ${config.appName}`',
      ),
    );
    w.check(
      guideText(
        config,
        en: '`flutter pub get` completes without errors (downloads dependencies from `pubspec.yaml` into `.dart_tool`)',
        id: '`flutter pub get` selesai tanpa error (mengunduh dependency dari `pubspec.yaml` ke folder `.dart_tool`)',
      ),
    );
    w.check(
      guideText(
        config,
        en: '`flutter doctor -v` shows no critical issues for your platforms (see [${_partOneLinkLabel(config)}](${_partOneSectionAnchor(config, 1, _prerequisitesTitle)}))',
        id: '`flutter doctor -v` tidak ada masalah kritis untuk platform Anda (lihat [${_partOneLinkLabel(config)}](${_partOneSectionAnchor(config, 1, _prerequisitesTitle)}))',
      ),
    );
    if (config.targetsIos) {
      w.check(
        guideText(
          config,
          en: 'Run `cd ios && pod install && cd ..` once after clone or `pub get` (downloads native iOS dependencies into `ios/Pods`)',
          id: '`cd ios && pod install && cd ..` sekali setelah clone atau `pub get` (mengunduh dependency native iOS ke `ios/Pods`)',
        ),
      );
    }
    buffer.writeln();

    w.beginSection(_partTwoSectionTitle(config, 'file-env'), 'file-env');
    buffer.writeln(
      guideText(
        config,
        en: 'The app loads runtime configuration (for example **API URLs**) from text files at the **project root**, not hard-coded in Dart. '
            'The generator created **three files** (one per flavor) and registered them as assets in `pubspec.yaml`. '
            'On startup, `EnvConfig.load(...)` reads the file that matches the flavor/entry point (`main_development.dart`, etc.).',
        id: 'Aplikasi memuat konfigurasi runtime (misalnya **URL API**) dari file teks di **root proyek**, bukan hard-code di Dart. '
            'Generator sudah membuat **tiga file** (satu per flavor) dan mendaftarkannya sebagai asset di `pubspec.yaml`. '
            'Saat app start, `EnvConfig.load(...)` membaca file yang sesuai flavor/entry point (`main_development.dart`, dll.).',
      ),
    );
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: 'Format: **one variable per line**, `NAME=value` (example `BASE_URL=https://api.dev.example.com`). '
            '**`.env*`** files are listed in **`.gitignore`**; real values stay on your machine only. Do not commit them to git.',
        id: 'Format: **satu variabel per baris**, `NAMA=nilai` (contoh `BASE_URL=https://api.dev.example.com`). '
            'File **`.env*`** sudah masuk **`.gitignore`**; isi asli hanya di mesin Anda. Jangan commit ke git.',
      ),
    );
    buffer.writeln();
    w.check(
      guideText(config, en: '`.env.development` is filled in', id: '`.env.development` terisi'),
    );
    w.check(
      guideText(config, en: '`.env.staging` is filled in', id: '`.env.staging` terisi'),
    );
    w.check(
      guideText(config, en: '`.env.production` is filled in', id: '`.env.production` terisi'),
    );
    if (config.useSecretKey) {
      w.check(
        guideText(
          config,
          en: '`.env` values are encrypted (see [Secret key](${part2LinkForSlug(config, 'secret-key')}); without encryption the app may fail to load env',
          id: 'Nilai `.env` sudah di-enkripsi (lihat [Secret key](${part2LinkForSlug(config, 'secret-key')}); jika tanpa enkripsi, app bisa gagal memuat env',
        ),
      );
    } else {
      buffer.writeln(
        guideText(
          config,
          en: '> This project has **no** secret key: `.env` contents can be **plain text**; the simple `get_env.dart` loads directly from assets.',
          id: '> Proyek ini **tanpa** secret key: isi `.env` cukup **teks biasa**; `get_env.dart` versi simple memuat langsung dari asset.',
        ),
      );
      buffer.writeln();
    }
    buffer.writeln();

    if (config.useSecretKey) {
      w.beginSection(_partTwoSectionTitle(config, 'secret-key'), 'secret-key');
      buffer.writeln(
        guideText(
          config,
          en: 'The **secret key** is the project’s private key (file `lib/core/config/secretkey.dart`) used by **`secure_compressor`** '
              'to **encrypt `.env` contents** before they are stored or read on device. The goal: sensitive values (internal URLs, static tokens, etc.) '
              'are not stored as plain text in assets or local storage.',
          id: '**Secret key** adalah kunci rahasia proyek (file `lib/core/config/secretkey.dart`) yang dipakai paket **`secure_compressor`** '
              'untuk **mengenkripsi isi `.env`** sebelum disimpan/dibaca di perangkat. Tujuannya: nilai sensitif (URL internal, token statis, dll.) '
              'tidak tersimpan sebagai teks biasa di asset atau storage lokal.',
        ),
      );
      buffer.writeln();
      buffer.writeln(
        guideText(
          config,
          en: 'Short flow: generate `secretkey.dart` → encrypt `.env` values using helpers in **`cryptic.dart`** / **`get_env.dart`** '
              '→ at runtime the app decrypts and loads into `EnvConfig`. **`secretkey.dart`** is also in **`.gitignore`**: '
              'each developer/environment keeps a local copy; do not push it to the repository.',
          id: 'Alur singkat: Anda generate `secretkey.dart` → enkripsi nilai `.env` sesuai helper **`cryptic.dart`** / **`get_env.dart`** '
              '→ saat runtime app mendekripsi lalu memuat ke `EnvConfig`. File **`secretkey.dart`** juga di **`.gitignore`**: '
              'setiap developer/environment punya salinan lokal; jangan push ke repository.',
        ),
      );
      buffer.writeln();
      w.check(
        guideText(
          config,
          en: 'Generate `secretkey.dart` with [secret_key_scrypt_generator](https://pub.dev/packages/secret_key_scrypt_generator) (follow that package’s README)',
          id: 'Generate `secretkey.dart` dengan [secret_key_scrypt_generator](https://pub.dev/packages/secret_key_scrypt_generator) (ikuti README paket tersebut)',
        ),
      );
      w.check(
        guideText(
          config,
          en: 'Save the result at `lib/core/config/secretkey.dart` (path expected by project code)',
          id: 'Simpan hasilnya di `lib/core/config/secretkey.dart` (path yang diharapkan kode proyek)',
        ),
      );
      w.check(
        guideText(
          config,
          en: '`.env.development` / `.env.staging` / `.env.production` are encrypted per the flow in `cryptic.dart` & `get_env.dart`',
          id: 'Isi `.env.development` / `.env.staging` / `.env.production` sudah di-enkripsi sesuai alur di `cryptic.dart` & `get_env.dart`',
        ),
      );
      w.check(
        guideText(
          config,
          en: 'Run the app (development flavor); no errors loading environment (check logs if decrypt fails)',
          id: 'Jalankan app (flavor development); tidak ada error saat memuat environment (cek log jika gagal decrypt)',
        ),
      );
      buffer.writeln();
    }

    w.beginSection(_partTwoSectionTitle(config, 'build-runner'), 'build-runner');
    buffer.writeln(
      guideText(
        config,
        en: 'Some Dart files are **not written by hand**: they are **generated** from annotations (e.g. **`@freezed`**, **`@JsonSerializable`**, '
            '${config.needsCodegen ? '**`@riverpod`/`@Bloc`-related**,' : ''} etc.). **`build_runner`** reads your sources and writes files such as '
            '**`*.freezed.dart`** and **`*.g.dart`** next to the model/provider.',
        id: 'Beberapa file Dart **tidak ditulis manual**: mereka di-**generate** dari annotation (mis. **`@freezed`**, **`@JsonSerializable`**, '
            '${config.needsCodegen ? '**`@riverpod`/`@Bloc`-related**,' : ''} dll.). Tool **`build_runner`** membaca source Anda lalu menulis file seperti '
            '**`*.freezed.dart`** dan **`*.g.dart`** di folder yang sama dengan model/provider.',
      ),
    );
    buffer.writeln();
    if (config.needsCodegen) {
      buffer.writeln(
        guideText(
          config,
          en: 'This project uses **${stateManagementLabel(config)}** + **freezed**. Without this step, imports to `*.g.dart` / `*.freezed.dart` will fail.',
          id: 'Proyek ini memakai **${stateManagementLabel(config)}** + **freezed**. Tanpa langkah ini, import ke `*.g.dart` / `*.freezed.dart` akan error.',
        ),
      );
    } else {
      buffer.writeln(
        guideText(
          config,
          en: 'This project uses **freezed** for models. Without this step, imports to `*.freezed.dart` will fail.',
          id: 'Proyek ini memakai **freezed** untuk model. Tanpa langkah ini, import ke `*.freezed.dart` akan error.',
        ),
      );
    }
    buffer.writeln(
      guideText(
        config,
        en: 'Re-run **`build_runner`** whenever you change model/provider classes that use code generation.',
        id: 'Jalankan ulang **`build_runner`** setiap kali Anda mengubah class model/provider yang pakai code generation.',
      ),
    );
    buffer.writeln();
    w.check(
      guideText(
        config,
        en: 'Run the command below (copy into terminal):',
        id: 'Jalankan perintah berikut (salin ke terminal):',
      ),
    );
    buffer.writeln();
    buffer.writeln('```bash');
    buffer.writeln('dart run build_runner build --delete-conflicting-outputs');
    buffer.writeln('```');
    buffer.writeln();
    w.check(
      guideText(
        config,
        en: 'No errors; repeat after changing annotated models',
        id: 'Tidak ada error; ulangi setelah ubah model ber-annotation',
      ),
    );
    w.check(
      guideText(
        config,
        en: '(VS Code) Task **Synchronize Build Runners** if needed',
        id: '(VS Code) Task **Synchronize Build Runners** jika perlu',
      ),
    );
    buffer.writeln();

    if (config.targetsAndroid) {
      w.beginSection(_partTwoSectionTitle(config, 'android'), 'android');
      buffer.writeln(
        guideText(
          config,
          en: 'On Android, a **flavor** is an app variant with a different **applicationId** and resources (development / staging / production). '
              'The generator added **`productFlavors`** in `android/app/build.gradle` (or `.kts`). '
              'You **do not** need to change Dart code when switching environments; pick the flavor when running `flutter run` / `flutter build`.',
          id: 'Di Android, **flavor** = varian app dengan **applicationId** dan resource berbeda (development / staging / production). '
              'Generator sudah menambahkan blok **`productFlavors`** di `android/app/build.gradle` (atau `.kts`). '
              'Anda **tidak** perlu mengubah kode Dart saat ganti environment; cukup pilih flavor saat `flutter run` / `flutter build`.',
        ),
      );
      buffer.writeln();
      buffer.writeln(
        guideText(
          config,
          en: 'To verify: open **`android/app/build.gradle`** → find **`productFlavors`** (flavor names must match `--flavor`).',
          id: 'Untuk memverifikasi: buka **`android/app/build.gradle`** → cari **`productFlavors`** (nama flavor harus cocok dengan `--flavor`).',
        ),
      );
      buffer.writeln();
      if (config.useFirebase) {
        w.check(
          guideText(
            config,
            en: 'Replace placeholder **`google-services.json`** per flavor in `android/app/src/<flavor>/` with files from Firebase Console (package name must match the flavor applicationId)',
            id: 'Ganti placeholder **`google-services.json`** per flavor di `android/app/src/<flavor>/` dengan file dari Firebase Console (package name harus match applicationId flavor)',
          ),
        );
      }
      w.check(
        guideText(
          config,
          en: 'Test Android runs per environment: VS Code **Run and Debug** → **`[DEV]`** (development), **`[STG]`** (staging), or **production** in **`.vscode/launch.json`** (see [${_vscodeSectionTitle(config)}](${part2LinkForSlug(config, 'vscode')}))',
          id: 'Uji run Android per environment: VS Code **Run and Debug** → pilih **`[DEV]`** (development), **`[STG]`** (staging), atau konfigurasi **production** di **`.vscode/launch.json`** (lihat [${_vscodeSectionTitle(config)}](${part2LinkForSlug(config, 'vscode')}))',
        ),
      );
      w.check(
        guideText(
          config,
          en: 'Terminal alternative: `flutter run --flavor <development|staging|production> -t lib/main_<environment>.dart` (flags must match)',
          id: 'Alternatif terminal: `flutter run --flavor <development|staging|production> -t lib/main_<environment>.dart` (flag harus selaras)',
        ),
      );
      buffer.writeln();
    }

    if (config.targetsIos) {
      w.beginSection(_partTwoSectionTitle(config, 'ios-flavor'), 'ios-flavor');
      _iosFlavorChecklistBody(buffer, config, w);
    } else if (!config.targetsAndroid) {
      buffer.writeln(
        guideText(
          config,
          en: '> No mobile platform was selected at generate time. Skip the Android/iOS checklists.',
          id: '> Platform mobile tidak dipilih saat generate. Lewati checklist Android/iOS.',
        ),
      );
      buffer.writeln();
    }

    if (config.useFirebase) {
      w.beginSection(_partTwoSectionTitle(config, 'firebase'), 'firebase');
      buffer.writeln(
        guideText(
          config,
          en: '**Firebase** (Analytics, Crashlytics, Messaging, etc.) requires configuration **per platform**: `google-services.json` on Android, '
              '`GoogleService-Info.plist` on iOS, and **`lib/firebase_options.dart`** (+ **`web/firebase-messaging-sw.js`** for FCM) on **web**. '
              'Because this project is multi-flavor on mobile, **each flavor has a different ID** (see the identifier table in ${_partOneLinkLabel(config)}); '
              'create separate apps or configs in [Firebase Console](https://console.firebase.google.com/) and place files in the paths the generator prepared.',
          id: '**Firebase** (Analytics, Crashlytics, Messaging, dll.) butuh konfigurasi **per platform**: `google-services.json` (Android), '
              '`GoogleService-Info.plist` (iOS), **`lib/firebase_options.dart`** (+ **`web/firebase-messaging-sw.js`** untuk FCM) di **web**. '
              'Karena proyek ini multi-flavor di mobile, **setiap flavor punya ID berbeda** (lihat tabel identifier di ${_partOneLinkLabel(config)}); '
              'Anda perlu app terpisah atau konfigurasi terpisah di [Firebase Console](https://console.firebase.google.com/) lalu tempel file ke path yang generator siapkan.',
        ),
      );
      buffer.writeln();
      buffer.writeln(
        guideText(
          config,
          en: 'Generator placeholders are **not** production config; replace them before release. Without correct files, Firebase plugins fail at runtime.',
          id: 'Placeholder dari generator **bukan** config production; ganti sebelum rilis. Tanpa file benar, plugin Firebase gagal saat runtime.',
        ),
      );
      buffer.writeln();
      w.check(
        guideText(
          config,
          en: 'Download or create Firebase project & apps for each flavor you use',
          id: 'Unduh / buat project & app di Firebase Console untuk setiap flavor yang dipakai',
        ),
      );
      w.check(
        guideText(
          config,
          en: 'Replace placeholder values in **`lib/firebase_options.dart`** (or run **`flutterfire configure`** in the project root to regenerate the file)',
          id: 'Ganti placeholder di **`lib/firebase_options.dart`** (atau **`flutterfire configure`**) ',
        ),
      );
      if (config.targetsAndroid) {
        w.check(
          guideText(
            config,
            en: 'Android `google-services.json` per flavor installed under `android/app/src/<flavor>/`',
            id: '`google-services.json` per flavor Android terpasang di `android/app/src/<flavor>/`',
          ),
        );
      }
      if (config.targetsIos) {
        w.check(
          guideText(
            config,
            en: '`GoogleService-Info.plist` per flavor exists under `ios/config/<flavor>/` (generator placeholder)',
            id: '`GoogleService-Info.plist` per flavor sudah ada di `ios/config/<flavor>/` (placeholder dari generator)',
          ),
        );
        w.check(
          guideText(
            config,
            en: 'Xcode → TARGET **Runner** → **Build Phases** tab → **+** → **New Run Script Phase**',
            id: 'Xcode → TARGET **Runner** → tab **Build Phases** → **+** → **New Run Script Phase**',
          ),
        );
        w.check(
          guideText(
            config,
            en: 'Drag the **Run Script** phase **above** **Copy Bundle Resources**',
            id: 'Tarik fase **Run Script** **di atas** **Copy Bundle Resources**',
          ),
        );
        w.check(
          guideText(
            config,
            en: 'Script body: `/bin/sh "\$PROJECT_DIR/firebase.sh"` (generator created `ios/firebase.sh`)',
            id: 'Isi script: `/bin/sh "\$PROJECT_DIR/firebase.sh"` (file `ios/firebase.sh` sudah dibuat generator)',
          ),
        );
      }
      if (config.targetsWeb) {
        w.check(
          guideText(
            config,
            en: 'Firebase Console → **Add app → Web** — register one Web app; copy **apiKey**, **appId**, **messagingSenderId**, **projectId**, **storageBucket** into the **`web`** constants in `lib/firebase_options.dart`',
            id: 'Firebase Console → **Add app → Web** — salin config ke bagian **`web`** di `lib/firebase_options.dart`',
          ),
        );
        w.check(
          guideText(
            config,
            en: 'Replace **`YOUR_*`** in **`web/firebase-messaging-sw.js`** with the same Web app config (required for FCM on web)',
            id: 'Ganti **`YOUR_*`** di **`web/firebase-messaging-sw.js`** (untuk FCM web)',
          ),
        );
        w.check(
          guideText(
            config,
            en: '(Optional, FCM on web) **Project settings → Cloud Messaging → Web configuration** — generate a key pair if `getToken` fails in Chrome; pass `vapidKey` to `FirebaseMessaging.instance.getToken(vapidKey: ...)`',
            id: '(Opsional FCM web) Web Push key pair di Firebase Console jika `getToken` gagal',
          ),
        );
        w.check(
          guideText(
            config,
            en: 'Verify: `flutter run -d chrome` — no Firebase errors in the browser console',
            id: 'Uji: `flutter run -d chrome` — tidak ada error Firebase di console browser',
          ),
        );
      }
      buffer.writeln();
    }

    if (config.hasCiCd) {
      if (config.usesGitHubActions) {
        w.beginSection(_partTwoSectionTitle(config, 'cicd-github'), 'cicd-github');
        buffer.writeln(
          guideText(
            config,
            en: '**CI/CD** runs tests and code analysis on a server (not on your laptop). '
                'The generator wrote **`.github/workflows/flutter_ci.yml`**: typically **`flutter analyze`** + **`flutter test`** '
                'on every push/PR. If you chose deploy, build/upload jobs run manually or via secrets (see `fastlane/.env.example`).',
            id: '**CI/CD** menjalankan tes & analisis kode otomatis di server (bukan di laptop Anda). '
                'Generator menulis workflow **`.github/workflows/flutter_ci.yml`**: biasanya **`flutter analyze`** + **`flutter test`** '
                'pada setiap push/PR. Jika Anda memilih deploy, job build/upload dijalankan manual atau lewat secrets (lihat `fastlane/.env.example`).',
          ),
        );
        buffer.writeln();
        w.check(
          guideText(
            config,
            en: 'Repository on GitHub: `git remote -v` shows `origin` pointing at your GitHub repo; push the branch that contains `.github/workflows/flutter_ci.yml`',
            id: 'Repo di GitHub: `git remote -v` menunjuk ke repo GitHub; push branch yang berisi `.github/workflows/flutter_ci.yml`',
          ),
        );
        w.check(
          guideText(
            config,
            en: 'Open **GitHub → your repo → Actions**: workflow **Flutter CI** runs on push or pull request (defined in `.github/workflows/flutter_ci.yml`)',
            id: 'Buka **GitHub → repo → Actions**: workflow **Flutter CI** jalan saat push atau pull request',
          ),
        );
        w.check(
          guideText(
            config,
            en: 'Job **`analyze_and_test`** finishes green (runs `flutter analyze` and `flutter test`) — fix any failures locally before relying on CI',
            id: 'Job **`analyze_and_test`** hijau (menjalankan `flutter analyze` dan `flutter test`)',
          ),
        );
        if (config.hasCiDeploy) {
          w.check(
            guideText(
              config,
              en: 'Read `fastlane/.env.example`: for each deploy target you use, create matching **repository secrets** under **Settings → Secrets and variables → Actions → New repository secret** (masked; never commit values)',
              id: 'Baca `fastlane/.env.example`: buat **repository secrets** yang sesuai di **Settings → Secrets and variables → Actions**',
            ),
          );
          w.check(
            guideText(
              config,
              en: 'Signing files (Android keystore, App Store `.p8`, Play JSON key): store on the runner or as GitHub secrets/files as described in `fastlane/.env.example` — not in git',
              id: 'File signing (keystore Android, `.p8`, JSON Play): simpan di runner atau secrets GitHub — jangan di git',
            ),
          );
          w.check(
            guideText(
              config,
              en: 'When secrets are ready: **Actions → Flutter CI → Run workflow** to trigger manual build/deploy jobs (if generated in the YAML)',
              id: 'Setelah secrets siap: **Actions → Flutter CI → Run workflow** untuk build/deploy manual',
            ),
          );
        }
      } else {
        w.beginSection(_partTwoSectionTitle(config, 'cicd-gitlab'), 'cicd-gitlab');
        buffer.writeln(
          guideText(
            config,
            en: '**GitLab CI** runs **quality** (analyze) and **test** stages from **`.gitlab-ci.yml`**. '
                'Runners may be shared cloud, a project Docker image (`ci/Dockerfile`), or a **local Mac** (self-hosted), depending on generate options. '
                'Deploy (Fastlane) applies only if you chose CI + deployment; store secrets in GitLab CI/CD Variables, not in git.',
            id: '**GitLab CI** menjalankan stage **quality** (analyze) dan **test** dari file **`.gitlab-ci.yml`**. '
                'Runner bisa shared cloud, Docker image proyek (`ci/Dockerfile`), atau **Mac lokal** (self-hosted), sesuai pilihan saat generate. '
                'Deploy (Fastlane) hanya relevan jika Anda memilih CI + deployment; variabel rahasia di GitLab CI/CD Variables, bukan di git.',
          ),
        );
        buffer.writeln();
        buffer.writeln(
          guideText(
            config,
            en: '**Suggested order:** (1) runner machine ready → (2) register runner in GitLab → (3) push code → (4) confirm pipeline jobs pass → '
                '(5) if deploy: add CI/CD variables from `fastlane/.env.example`. Detailed commands: **`ci/GITLAB_RUNNER_SETUP.md`**.',
            id: '**Urutan disarankan:** (1) mesin runner siap → (2) register di GitLab → (3) push → (4) pipeline hijau → '
                '(5) jika deploy: variabel CI/CD. Detail: **`ci/GITLAB_RUNNER_SETUP.md`**.',
          ),
        );
        buffer.writeln();
        if (config.gitLabSelfHostedShell) {
          w.check(
            guideText(
              config,
              en: '**Runner machine:** Flutter SDK installed; run `flutter doctor` as the **same OS user** that will run `gitlab-runner` (shell executor uses that user\'s PATH)',
              id: '**Mesin runner:** Flutter terpasang; `flutter doctor` sebagai **user OS yang sama** dengan `gitlab-runner`',
            ),
          );
          w.check(
            guideText(
              config,
              en: 'Install GitLab Runner on that machine (see **`ci/GITLAB_RUNNER_SETUP.md` §2**, e.g. macOS: `brew install gitlab-runner`, then `gitlab-runner install` and `gitlab-runner start`)',
              id: 'Install GitLab Runner di mesin itu (lihat **`ci/GITLAB_RUNNER_SETUP.md` §2**)',
            ),
          );
          w.check(
            guideText(
              config,
              en: 'In GitLab: **Settings → CI/CD → Runners → New project runner** — create a runner and copy the **registration token** shown by GitLab',
              id: 'Di GitLab: **Settings → CI/CD → Runners → New project runner** — salin **registration token**',
            ),
          );
          w.check(
            guideText(
              config,
              en: 'On the machine, run `gitlab-runner register`: **executor** = `shell`; **tags** = `self-hosted`, `flutter`${config.targetsIos ? ', `macos`' : ''} (must match the `tags:` block on jobs in `.gitlab-ci.yml`)',
              id: 'Jalankan `gitlab-runner register`: **executor** `shell`; **tags** `self-hosted`, `flutter`${config.targetsIos ? ', `macos`' : ''}',
            ),
          );
          w.check(
            guideText(
              config,
              en: '**Settings → CI/CD → Runners** lists your runner as **online** (green). If jobs stay **pending**, tags or executor do not match — re-check register answers and **`ci/GITLAB_RUNNER_SETUP.md` §3**',
              id: 'Runner **online** (hijau) di **Settings → CI/CD → Runners**. Job **pending** = tag/executor tidak cocok',
            ),
          );
        } else if (config.gitlabRunnerMode == GitLabRunnerMode.dockerfile) {
          w.check(
            guideText(
              config,
              en: 'Build and push the CI image: `docker build -f ci/Dockerfile -t <your-gitlab-registry>/ci-flutter:latest .` then `docker push` (registry path must match `\$CI_REGISTRY_IMAGE` in `.gitlab-ci.yml`)',
              id: 'Build & push image dari `ci/Dockerfile` ke registry GitLab proyek',
            ),
          );
          w.check(
            guideText(
              config,
              en: 'Register a **self-hosted Docker** runner (`executor: docker`) that can pull your registry image; see comments in `.gitlab-ci.yml` and **`ci/GITLAB_RUNNER_SETUP.md` §6**',
              id: 'Register runner Docker self-hosted; lihat `.gitlab-ci.yml` dan **`ci/GITLAB_RUNNER_SETUP.md` §6**',
            ),
          );
        } else {
          w.check(
            guideText(
              config,
              en: '**GitLab.com shared runners:** no local runner install for analyze/test — jobs use image `ghcr.io/cirruslabs/flutter:stable`. Confirm **Settings → CI/CD → Runners** shows shared runners available for the project',
              id: '**Shared runner GitLab.com:** tidak perlu install runner lokal untuk analyze/test',
            ),
          );
        }
        w.check(
          guideText(
            config,
            en: 'Push a commit or open a merge request: **Build → Pipelines** shows a new pipeline from `.gitlab-ci.yml`',
            id: 'Push atau buka MR: **Build → Pipelines** menampilkan pipeline baru',
          ),
        );
        w.check(
          guideText(
            config,
            en: 'Stages **quality** (job `analyze`) and **test** (job `unit_test`) complete successfully — not stuck **pending** (usually means no runner with matching tags)',
            id: 'Stage **quality** (`analyze`) dan **test** (`unit_test`) sukses — bukan **pending**',
          ),
        );
        if (config.hasCiDeploy) {
          w.check(
            guideText(
              config,
              en: 'Open `fastlane/.env.example` and list variables needed for your deploy targets (Play internal, TestFlight, Firebase App Distribution, etc.)',
              id: 'Buka `fastlane/.env.example` — catat variabel untuk target deploy Anda',
            ),
          );
          w.check(
            guideText(
              config,
              en: 'GitLab **Settings → CI/CD → Variables**: add each secret as **masked** (and **protected** if only default branch). Use **File** type for keystores or `.p8` keys; paths in Fastlane must exist on the runner for shell jobs',
              id: '**Settings → CI/CD → Variables**: tambah secret **masked**; **File** untuk keystore / `.p8`',
            ),
          );
          w.check(
            guideText(
              config,
              en: 'On the default branch pipeline: manual jobs (▶) such as `build_android_*`, `build_ios_*`, or `deploy_*` run only after variables and signing are configured — trigger them when ready',
              id: 'Di branch default: job manual `build_*` / `deploy_*` (▶) setelah variabel & signing siap',
            ),
          );
        }
      }
      buffer.writeln();
    }

    w.beginSection(_partTwoSectionTitle(config, 'menjalankan-app'), 'menjalankan-app');
    buffer.writeln(
      guideText(
        config,
        en: 'After env${config.useSecretKey ? ', secret key,' : ''} native (Android/iOS), and codegen are done, test the app with the **development** flavor first. '
            '**`-t`** selects the **`main_*.dart`** file (logic & env); **`--flavor`** (mobile) must match Gradle/Xcode flavor names.',
        id: 'Setelah env${config.useSecretKey ? ', secret key,' : ''} native (Android/iOS), dan codegen selesai, uji app dengan flavor **development** dulu. '
            'Flag **`-t`** menentukan file **`main_*.dart`** (logic & env); flag **`--flavor`** (mobile) harus sama dengan nama flavor Gradle/Xcode.',
      ),
    );
    buffer.writeln();
    w.check(
      guideText(
        config,
        en: 'The command below succeeds in terminal (development flavor example):',
        id: 'Perintah berikut berhasil di terminal (contoh flavor development):',
      ),
    );
    buffer.writeln();
    buffer.writeln('```bash');
    buffer.writeln(
      config.usesMobileFlavors
          ? 'flutter run --flavor development -t lib/main_development.dart'
          : 'flutter run -t lib/main_development.dart',
    );
    buffer.writeln('```');
    buffer.writeln();
    w.check(
      guideText(
        config,
        en: 'App appears on emulator/device without crashing on splash / home',
        id: 'App tampil di emulator/device tanpa crash saat splash / home',
      ),
    );
    w.check(
      guideText(
        config,
        en: 'Or run via VS Code (**Run and Debug** → `[DEV]`, see [${_vscodeSectionTitle(config)}](${part2LinkForSlug(config, 'vscode')}))',
        id: 'Atau jalankan lewat VS Code (**Run and Debug** → `[DEV]`, lihat [${_vscodeSectionTitle(config)}](${part2LinkForSlug(config, 'vscode')}))',
      ),
    );
    buffer.writeln();

    w.beginSection(_vscodeSectionTitle(config), 'vscode');
    vscodeSectionBody(buffer, config);
  }

  static void _iosFlavorChecklistBody(
    StringBuffer buffer,
    ProjectConfig config,
    _Part2ChecklistWriter w,
  ) {
    buffer.writeln(
      guideText(
        config,
        en: 'On iOS, changing Dart alone is **not** enough: Xcode needs **Build Configuration** and **Scheme** '
            'names aligned with flavors. Without this setup, `flutter run --flavor staging` fails even when Android works.',
        id: 'Di iOS, Flutter **tidak** cukup hanya mengubah Dart: Xcode harus punya **Build Configuration** dan **Scheme** '
            'yang namanya selaras dengan flavor. Tanpa setup ini, `flutter run --flavor staging` gagal meskipun Android sudah jalan.',
      ),
    );
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: 'Do this setup **once** on a Mac with Xcode. Flavor names must be exact: **`development`**, **`staging`**, **`production`** '
            '(same as `--flavor` and `ios/config/<flavor>/` when using Firebase).',
        id: 'Setup **sekali** di Mac + Xcode. Nama flavor harus persis: **`development`**, **`staging`**, **`production`** '
            '(sama dengan flag `--flavor` dan folder `ios/config/<flavor>/` jika pakai Firebase).',
      ),
    );
    buffer.writeln();
    buffer.writeln(
      guideText(config, en: '**Xcode checklist:**', id: '**Checklist Xcode:**'),
    );
    buffer.writeln();
    w.check(
      guideText(
        config,
        en: 'Open `ios/Runner.xcworkspace` (**not** `.xcodeproj`)',
        id: 'Buka `ios/Runner.xcworkspace` (**bukan** `.xcodeproj`)',
      ),
    );
    w.check(
      guideText(
        config,
        en: '`pod install` in `ios/` has been run (see [${_partTwoSectionTitle(config, 'langkah-awal')}](${part2LinkForSlug(config, 'langkah-awal')}))',
        id: '`pod install` di folder `ios/` sudah pernah dijalankan (lihat [${_partTwoSectionTitle(config, 'langkah-awal')}](${part2LinkForSlug(config, 'langkah-awal')}))',
      ),
    );
    w.check(
      guideText(
        config,
        en: 'PROJECT **Runner** (blue icon) → **Info** tab → **Configurations**: duplicate Debug/Release/Profile '
            'to 9 configurations; rename to `Debug-development`, …, `Release-production` (see table below)',
        id: 'PROJECT **Runner** (ikon biru) → tab **Info** → **Configurations**: duplikasi Debug/Release/Profile '
            'hingga 9 konfigurasi; rename ke pola `Debug-development`, …, `Release-production` (lihat tabel di bawah)',
      ),
    );
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: '| Type | Configuration name (examples) |',
        id: '| Tipe | Nama konfigurasi (contoh) |',
      ),
    );
    buffer.writeln('| --- | --- |');
    buffer.writeln('| Debug | `Debug-development`, `Debug-staging`, `Debug-production` |');
    buffer.writeln('| Release | `Release-development`, `Release-staging`, `Release-production` |');
    buffer.writeln('| Profile | `Profile-development`, `Profile-staging`, `Profile-production` |');
    buffer.writeln();
    w.check(
      guideText(
        config,
        en: 'TARGET **Runner** → **Build Settings** → filter *Product Bundle Identifier*: set per configuration '
            '`${config.iosBundleIdForEnv('development')}` (development), '
            '`${config.iosBundleIdForEnv('staging')}` (staging), '
            '`${config.iosBundleId}` (production)',
        id: 'TARGET **Runner** → **Build Settings** → filter *Product Bundle Identifier*: isi per konfigurasi '
            '`${config.iosBundleIdForEnv('development')}` (development), '
            '`${config.iosBundleIdForEnv('staging')}` (staging), '
            '`${config.iosBundleId}` (production)',
      ),
    );
    w.check(
      guideText(
        config,
        en: '**Product → Scheme → Manage Schemes…**: create **`development`**, **`staging`**, **`production`** schemes (Shared); '
            'Edit scheme → Run/Archive/Profile → matching **Build Configuration** (e.g. `Debug-development`)',
        id: 'Menu **Product → Scheme → Manage Schemes…**: buat skema **`development`**, **`staging`**, **`production`** (Shared); '
            'Edit skema → Run/Archive/Profile → **Build Configuration** cocok (mis. `Debug-development`)',
      ),
    );
    w.check(
      guideText(
        config,
        en: 'TARGET **Runner** → **Signing & Capabilities**: **Automatically manage signing** + **Team**, no red errors',
        id: 'TARGET **Runner** → **Signing & Capabilities**: **Automatically manage signing** + **Team**, tanpa error merah',
      ),
    );
    w.check(
      guideText(
        config,
        en: 'Verify: `flutter run --flavor development -t lib/main_development.dart` succeeds',
        id: 'Verifikasi: `flutter run --flavor development -t lib/main_development.dart` sukses',
      ),
    );
    buffer.writeln();
  }

  static void _iosFlavorChecklist(StringBuffer buffer, ProjectConfig config) {
    final w = _Part2ChecklistWriter(buffer);
    w.beginSection(_partTwoSectionTitle(config, 'ios-flavor'), 'ios-flavor');
    _iosFlavorChecklistBody(buffer, config, w);
  }

  static void glossary(StringBuffer buffer, ProjectConfig config) {
    buffer.writeln('## ${_glossaryTitle(config)}');
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: '| Term | Short meaning |',
        id: '| Istilah | Arti singkat |',
      ),
    );
    buffer.writeln('| --- | --- |');
    buffer.writeln(
      guideText(
        config,
        en: '| **Flutter** | Google’s UI framework; most of your code lives in `lib/`. |',
        id: '| **Flutter** | Framework UI dari Google; kode Anda sebagian besar di folder `lib/`. |',
      ),
    );
    buffer.writeln(
      guideText(
        config,
        en: '| **Dart** | Programming language used by Flutter. |',
        id: '| **Dart** | Bahasa pemrograman yang dipakai Flutter. |',
      ),
    );
    buffer.writeln(
      guideText(
        config,
        en: '| **`flutter pub get`** | Downloads packages in `pubspec.yaml` (like installing dependencies). |',
        id: '| **`flutter pub get`** | Mengunduh paket di `pubspec.yaml` (seperti install dependency). |',
      ),
    );
    buffer.writeln(
      guideText(
        config,
        en: '| **Flavor** | App variant (development / staging / production) with different IDs and config. |',
        id: '| **Flavor** | Varian app (development / staging / production) dengan ID dan konfigurasi berbeda. |',
      ),
    );
    buffer.writeln(
      guideText(
        config,
        en: '| **Entry point** | `main_*.dart` file run when the app starts. |',
        id: '| **Entry point** | File `main_*.dart` yang dijalankan saat app start. |',
      ),
    );
    buffer.writeln(
      guideText(
        config,
        en: '| **applicationId** | Unique Android app ID (Play Store). |',
        id: '| **applicationId** | ID unik app di Android (Play Store). |',
      ),
    );
    buffer.writeln(
      guideText(
        config,
        en: '| **Bundle ID** | Unique iOS app ID (App Store). |',
        id: '| **Bundle ID** | ID unik app di iOS (App Store). |',
      ),
    );
    buffer.writeln(
      guideText(
        config,
        en: '| **State management** | How data/UI is organized: this project uses **${stateManagementLabel(config)}**. |',
        id: '| **State management** | Cara mengatur data/UI: proyek ini memakai **${stateManagementLabel(config)}**. |',
      ),
    );
    buffer.writeln(
      guideText(
        config,
        en: '| **`.env`** | Text files with configuration (e.g. API URLs), split per environment. |',
        id: '| **`.env`** | File teks berisi konfigurasi (mis. URL API), dipisah per environment. |',
      ),
    );
    if (config.hasCiCd) {
      final provider = config.usesGitHubActions ? 'GitHub Actions' : 'GitLab CI';
      buffer.writeln(
        guideText(
          config,
          en: '| **CI/CD** | Automated pipeline ($provider) for tests and (optional) build/deploy. |',
          id: '| **CI/CD** | Pipeline otomatis ($provider) untuk tes dan (opsional) build/deploy. |',
        ),
      );
    }
    buffer.writeln();
  }

  static void prerequisites(StringBuffer buffer, ProjectConfig config, String Function(String) heading) {
    buffer.writeln(heading(_prerequisitesTitle(config)));
    buffer.writeln();
    buffer.writeln('### ${_whatToInstallTitle(config)}');
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: '1. [Flutter SDK](https://docs.flutter.dev/get-started/install) (**stable** channel).',
        id: '1. [Flutter SDK](https://docs.flutter.dev/get-started/install) (channel **stable**).',
      ),
    );
    buffer.writeln(
      guideText(
        config,
        en: '2. **VS Code** with **Dart** and **Flutter** extensions.',
        id: '2. **VS Code** + ekstensi **Dart** dan **Flutter**.',
      ),
    );
    if (config.targetsAndroid) {
      buffer.writeln(
        guideText(
          config,
          en: '3. **Android Studio** (for SDK & emulator). Enable a Virtual Device in Device Manager.',
          id: '3. **Android Studio** (untuk SDK & emulator). Aktifkan Virtual Device di Device Manager.',
        ),
      );
    }
    if (config.targetsIos) {
      buffer.writeln(
        guideText(
          config,
          en: '4. **Mac + Xcode** (required for iOS build/run). Install CocoaPods: `sudo gem install cocoapods` or via Homebrew.',
          id: '4. **Mac + Xcode** (wajib untuk build/run iOS). Install CocoaPods: `sudo gem install cocoapods` atau via Homebrew.',
        ),
      );
    }
    buffer.writeln();
    buffer.writeln('### ${_verificationTitle(config)}');
    buffer.writeln();
    buffer.writeln(
      guideText(config, en: 'Run in terminal:', id: 'Jalankan di terminal:'),
    );
    buffer.writeln();
    buffer.writeln('```bash');
    buffer.writeln('flutter doctor -v');
    buffer.writeln('```');
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: 'Fix items marked ✗ (e.g. `flutter doctor --android-licenses`, install Xcode Command Line Tools). '
            'Without this, `flutter run` often fails before your code runs.',
        id: 'Perbaiki item yang bertanda ✗ (mis. `flutter doctor --android-licenses`, instal Xcode Command Line Tools). '
            'Tanpa ini, perintah `flutter run` sering gagal sebelum kode Anda dieksekusi.',
      ),
    );
    buffer.writeln();
  }

  static void projectSummary(
    StringBuffer buffer,
    ProjectConfig config,
    String Function(String) heading,
  ) {
    buffer.writeln(heading(_projectSummaryTitle(config)));
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: '| Item | Value |',
        id: '| Item | Nilai |',
      ),
    );
    buffer.writeln('| --- | --- |');
    buffer.writeln(
      guideText(
        config,
        en: '| Display name | ${config.displayName} |',
        id: '| Nama tampilan | ${config.displayName} |',
      ),
    );
    buffer.writeln(
      guideText(
        config,
        en: '| Project name (folder) | `${config.appName}` |',
        id: '| Nama proyek (folder) | `${config.appName}` |',
      ),
    );
    buffer.writeln(
      guideText(
        config,
        en: '| Platform | ${config.platformTargetsLabel()} |',
        id: '| Platform | ${config.platformTargetsLabel()} |',
      ),
    );
    buffer.writeln(
      guideText(
        config,
        en: '| Android package (production) | `${config.androidPackage}` |',
        id: '| Android package (production) | `${config.androidPackage}` |',
      ),
    );
    buffer.writeln(
      guideText(
        config,
        en: '| iOS bundle ID (production) | `${config.iosBundleId}` |',
        id: '| iOS bundle ID (production) | `${config.iosBundleId}` |',
      ),
    );
    buffer.writeln(
      guideText(
        config,
        en: '| State management | ${stateManagementLabel(config)} |',
        id: '| State management | ${stateManagementLabel(config)} |',
      ),
    );
    buffer.writeln(
      guideText(
        config,
        en: '| Firebase | ${guideYesNo(config, config.useFirebase)} |',
        id: '| Firebase | ${guideYesNo(config, config.useFirebase)} |',
      ),
    );
    buffer.writeln(
      guideText(
        config,
        en: '| Secret key (`.env` encryption) | ${guideYesNo(config, config.useSecretKey)} |',
        id: '| Secret key (enkripsi `.env`) | ${guideYesNo(config, config.useSecretKey)} |',
      ),
    );
    buffer.writeln(
      guideText(
        config,
        en: '| CI/CD | ${config.hasCiCd ? '${config.ciCdProvider.name} (${config.ciCdScope.name})' : guideYesNo(config, false)} |',
        id: '| CI/CD | ${config.hasCiCd ? '${config.ciCdProvider.name} (${config.ciCdScope.name})' : guideYesNo(config, false)} |',
      ),
    );
    if (config.gitLabSelfHostedShell) {
      buffer.writeln(
        guideText(
          config,
          en: '| GitLab runner | Self-hosted shell (Mac Mini / local) |',
          id: '| GitLab runner | Self-hosted shell (Mac Mini / lokal) |',
        ),
      );
    }
    buffer.writeln();
    _pendingSetupCommands(buffer, config);
    buffer.writeln(
      guideText(
        config,
        en: 'The project uses **flavors** (development, staging, production) so when you switch environments '
            'you only pick a flavor at run/build time, without changing settings in code each time.',
        id: 'Proyek memakai **flavor** (development, staging, production) agar saat ganti environment '
            'Anda cukup memilih flavor saat run/build, tanpa mengubah setting manual di kode setiap kali.',
      ),
    );
    buffer.writeln();
    buffer.writeln('### ${_identifiersPerFlavorTitle(config)}');
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: '| Flavor | Android applicationId | iOS bundle ID | Entry point |',
        id: '| Flavor | Android applicationId | iOS bundle ID | Entry point |',
      ),
    );
    buffer.writeln('| --- | --- | --- | --- |');
    for (final env in config.environments) {
      buffer.writeln(
        '| $env | `${config.androidPackageForEnv(env)}` | '
        '`${config.iosBundleIdForEnv(env)}` | `lib/main_$env.dart` |',
      );
    }
    buffer.writeln();
  }

  /// Lists setup commands for integrations that were skipped at create time.
  static void _pendingSetupCommands(StringBuffer buffer, ProjectConfig config) {
    final lines = <String>[];
    if (!config.useFirebase) {
      lines.add(
        guideText(
          config,
          en: '- Firebase: `xproject setup firebase`',
          id: '- Firebase: `xproject setup firebase`',
        ),
      );
    }
    if (!config.useSecretKey) {
      lines.add(
        guideText(
          config,
          en: '- Secret key: `xproject setup secret-key`',
          id: '- Secret key: `xproject setup secret-key`',
        ),
      );
    }
    if (!config.hasCiCd) {
      lines.add(
        guideText(
          config,
          en: '- CI/CD: `xproject setup ci`',
          id: '- CI/CD: `xproject setup ci`',
        ),
      );
    }
    lines.add(
      guideText(
        config,
        en: '- Additional platforms: `xproject setup platforms`',
        id: '- Platform tambahan: `xproject setup platforms`',
      ),
    );

    buffer.writeln(
      guideText(
        config,
        en: 'Integrations not selected when creating the project can be added '
            'later from **this project folder** (not the parent folder):',
        id: 'Integrasi yang tidak dipilih saat membuat proyek bisa ditambahkan '
            'nanti dari **folder proyek ini** (bukan dari folder induk):',
      ),
    );
    buffer.writeln();
    for (final line in lines) {
      buffer.writeln(line);
    }
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: 'Run `xproject setup` to see options not yet installed.',
        id: 'Menu untuk melihat opsi yang belum terpasang: `xproject setup`.',
      ),
    );
    buffer.writeln();
  }

  static void folderTour(
    StringBuffer buffer,
    ProjectConfig config,
    String Function(String) heading,
  ) {
    buffer.writeln(heading(_folderStructureTitle(config)));
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: '| Path | Purpose |',
        id: '| Path | Fungsi |',
      ),
    );
    buffer.writeln('| --- | --- |');
    buffer.writeln(
      guideText(
        config,
        en: '| `lib/main_development.dart` (and staging/production) | App entry point per flavor |',
        id: '| `lib/main_development.dart` (dan staging/production) | Titik masuk app per flavor |',
      ),
    );
    buffer.writeln(
      guideText(
        config,
        en: '| `lib/app.dart` | Root application widget |',
        id: '| `lib/app.dart` | Widget root aplikasi |',
      ),
    );
    buffer.writeln(
      guideText(
        config,
        en: '| `lib/core/` | Configuration, networking, theme, utilities |',
        id: '| `lib/core/` | Konfigurasi, jaringan, tema, utilitas |',
      ),
    );
    buffer.writeln(
      guideText(
        config,
        en: '| `lib/features/` | Features (login, home, …); add features: `xproject --feature name` |',
        id: '| `lib/features/` | Fitur (login, home, …); tambah fitur: `xproject --feature nama` |',
      ),
    );
    buffer.writeln(
      guideText(
        config,
        en: '| `.env.development` etc. | Environment configuration (API URLs, etc.) |',
        id: '| `.env.development` dll. | Konfigurasi environment (URL API, dll.) |',
      ),
    );
    buffer.writeln(
      guideText(
        config,
        en: '| `android/`, `ios/` | Native code & flavors (if platforms selected) |',
        id: '| `android/`, `ios/` | Kode native & flavor (jika platform dipilih) |',
      ),
    );
    buffer.writeln(
      guideText(
        config,
        en: '| `.vscode/` | Run/Debug and Tasks configuration in the editor |',
        id: '| `.vscode/` | Konfigurasi Run/Debug dan Tasks di editor |',
      ),
    );
    buffer.writeln(
      guideText(
        config,
        en: '| `GUIDE.md` | This guide |',
        id: '| `GUIDE.md` | Panduan ini |',
      ),
    );
    buffer.writeln();
  }

  static void firstSteps(StringBuffer buffer, ProjectConfig config, String Function(String) heading) {
    buffer.writeln(
      heading(
        guideText(config, en: 'Initial steps', id: 'Langkah awal'),
      ),
    );
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: 'Open a terminal in the **parent** folder where the project was created, then:',
        id: 'Buka terminal di folder **parent** tempat proyek dibuat, lalu:',
      ),
    );
    buffer.writeln();
    buffer.writeln('```bash');
    buffer.writeln('cd ${config.appName}');
    buffer.writeln('flutter pub get');
    buffer.writeln('```');
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: '**Expected result:** the command finishes with no red errors. If you see *version solving failed*, '
            'ensure you are on the latest Flutter stable (`flutter upgrade`) and try again.',
        id: '**Hasil yang diharapkan:** perintah selesai tanpa error merah. Jika ada *version solving failed*, '
            'pastikan Flutter stable terbaru (`flutter upgrade`) lalu ulangi.',
      ),
    );
    if (config.targetsIos) {
      buffer.writeln();
      buffer.writeln(
        guideText(
          config,
          en: 'For iOS (once after clone):',
          id: 'Untuk iOS (sekali setelah clone):',
        ),
      );
      buffer.writeln();
      buffer.writeln('```bash');
      buffer.writeln('cd ios');
      buffer.writeln('pod install');
      buffer.writeln('cd ..');
      buffer.writeln('```');
    }
    buffer.writeln();
  }

  static void envSection(StringBuffer buffer, ProjectConfig config, String Function(String) heading) {
    buffer.writeln(heading(_partTwoSectionTitle(config, 'file-env')));
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: 'Three files live at the project **root**. Example content `BASE_URL=https://api.example.com` (one `key=value` per line):',
        id: 'Tiga file ada di **root** proyek. Isi contoh `BASE_URL=https://api.example.com` (satu `key=value` per baris):',
      ),
    );
    buffer.writeln();
    buffer.writeln('- `.env.development`');
    buffer.writeln('- `.env.staging`');
    buffer.writeln('- `.env.production`');
    buffer.writeln();
    if (config.useSecretKey) {
      buffer.writeln(
        guideText(
          config,
          en: '> **Secret key enabled:** values must be encrypted per the `secure_compressor` flow before build. '
              'See the Secret key section.',
          id: '> **Secret key aktif:** nilai harus di-enkripsi sesuai alur `secure_compressor` sebelum di-build. '
              'Lihat bagian Secret key.',
        ),
      );
    } else {
      buffer.writeln(
        guideText(
          config,
          en: 'Without a secret key, files contain **plain text**. `.env*` files are in **`.gitignore`**; do not commit them. Keep a local copy per developer.',
          id: 'Tanpa secret key, file berisi **teks biasa**. File `.env*` sudah ada di **`.gitignore`**; jangan di-commit. Buat salinan lokal per developer.',
        ),
      );
    }
    buffer.writeln();
  }

  static void secretKey(
    StringBuffer buffer,
    ProjectConfig config,
    String Function(String) heading,
  ) {
    buffer.writeln(heading(_partTwoSectionTitle(config, 'secret-key')));
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: '1. Generate `secretkey.dart` with [secret_key_scrypt_generator](https://pub.dev/packages/secret_key_scrypt_generator).',
        id: '1. Generate `secretkey.dart` dengan [secret_key_scrypt_generator](https://pub.dev/packages/secret_key_scrypt_generator).',
      ),
    );
    buffer.writeln(
      guideText(
        config,
        en: '2. Save it at **`lib/core/config/secretkey.dart`**.',
        id: '2. Simpan di **`lib/core/config/secretkey.dart`**.',
      ),
    );
    buffer.writeln(
      guideText(
        config,
        en: '3. Encrypt `.env.*` per `get_env.dart` / `cryptic.dart`.',
        id: '3. Enkripsi `.env.*` sesuai `get_env.dart` / `cryptic.dart`.',
      ),
    );
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: '> Without this file, the app fails to load environment.',
        id: '> Tanpa file ini, app gagal memuat environment.',
      ),
    );
    buffer.writeln();
  }

  static void codegen(
    StringBuffer buffer,
    ProjectConfig config,
    String Function(String) heading,
  ) {
    final needsCodegen = config.needsCodegen;
    buffer.writeln(heading(_partTwoSectionTitle(config, 'build-runner')));
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: 'The project uses **freezed** for data models.'
            '${needsCodegen ? ' **${stateManagementLabel(config)}** also needs a generator for `*.g.dart`.' : ''}',
        id: 'Proyek memakai **freezed** untuk model data.'
            '${needsCodegen ? ' **${stateManagementLabel(config)}** juga butuh generator untuk `*.g.dart`.' : ''}',
      ),
    );
    buffer.writeln();
    buffer.writeln('```bash');
    buffer.writeln('dart run build_runner build --delete-conflicting-outputs');
    buffer.writeln('```');
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: 'Re-run after changing annotated models/providers. A *part doesn\'t exist* error '
            'usually means this step was skipped.',
        id: 'Jalankan ulang setelah mengubah model/provider yang ber-annotation. Error *part doesn\'t exist* '
            'biasanya berarti langkah ini belum dijalankan.',
      ),
    );
    buffer.writeln();
  }

  static void androidFlavor(StringBuffer buffer, ProjectConfig config) {
    buffer.writeln(
      '### ${guideText(config, en: 'Android flavor', id: 'Android flavor')}',
    );
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: 'Flavors **development**, **staging**, **production** are already in `android/app/build.gradle` (or `.kts`).',
        id: 'Flavor **development**, **staging**, **production** sudah di `android/app/build.gradle` (atau `.kts`).',
      ),
    );
    buffer.writeln();
    buffer.writeln('```bash');
    buffer.writeln('flutter devices');
    buffer.writeln(
      'flutter run --flavor development -t lib/main_development.dart',
    );
    buffer.writeln('```');
    buffer.writeln();
    if (config.useFirebase) {
      buffer.writeln(
        guideText(
          config,
          en: 'Placeholder `google-services.json` per flavor in `android/app/src/<flavor>/`.',
          id: 'Placeholder `google-services.json` per flavor di `android/app/src/<flavor>/`.',
        ),
      );
      buffer.writeln();
    }
  }

  static void iosFlavor(StringBuffer buffer, ProjectConfig config, String Function(String) heading) {
    buffer.writeln(
      heading(
        guideText(
          config,
          en: 'iOS: flavor setup (required for `--flavor`)',
          id: 'iOS: setup flavor (wajib untuk `--flavor`)',
        ),
      ),
    );
    buffer.writeln();
    _iosFlavorChecklist(buffer, config);
  }

  static void firebase(
    StringBuffer buffer,
    ProjectConfig config,
    String Function(String) heading,
  ) {
    buffer.writeln(heading(_partTwoSectionTitle(config, 'firebase')));
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: 'Replace Android/iOS placeholders and **`lib/firebase_options.dart`** with values from [Firebase Console](https://console.firebase.google.com/). '
            'On **web**, also update **`web/firebase-messaging-sw.js`** or run **`flutterfire configure`**. ',
        id: 'Ganti placeholder Android/iOS dan **`lib/firebase_options.dart`** dari [Firebase Console](https://console.firebase.google.com/). '
            'Di **web**, update juga **`web/firebase-messaging-sw.js`** atau **`flutterfire configure`.',
      ),
    );
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: 'iOS plist per flavor: `ios/config/<flavor>/GoogleService-Info.plist`.',
        id: 'iOS plist per flavor: `ios/config/<flavor>/GoogleService-Info.plist`.',
      ),
    );
    buffer.writeln();
    if (config.targetsWeb) {
      buffer.writeln(
        guideText(
          config,
          en: '**Web:** one Firebase **Web app** in Console → fill **`lib/firebase_options.dart`** (`web` constants) and **`web/firebase-messaging-sw.js`**. '
              'Easiest path: `dart pub global activate flutterfire_cli` then **`flutterfire configure`** from the project root.',
          id: '**Web:** app **Web** di Console → isi **`firebase_options.dart`** dan **`firebase-messaging-sw.js`**, atau **`flutterfire configure`**.',
        ),
      );
      buffer.writeln();
    }
    buffer.writeln(
      guideText(
        config,
        en: 'Add **Run Script** `ios/firebase.sh` in Xcode (**Runner** → **Build Phases**, before **Copy Bundle Resources**).',
        id: 'Tambahkan **Run Script** `ios/firebase.sh` di Xcode (**Runner** → **Build Phases**, sebelum **Copy Bundle Resources**).',
      ),
    );
    buffer.writeln();
  }

  static void vscodeSectionBody(StringBuffer buffer, ProjectConfig config) {
    buffer.writeln(
      guideText(
        config,
        en: 'At generate time, XProject adds **`.vscode/`** with **`launch.json`** (Run/Debug per flavor) '
            'and **`tasks.json`** (build APK/AAB/IPA, `build_runner`, etc.). This section is **not required** to finish '
            'env, flavor, or Firebase checklists; running/building via **terminal** (`flutter run`, `flutter build`) remains valid. '
            'Use VS Code if you want **breakpoint debugging (F5)**, picking a device from the UI, or running build tasks from the editor menu.',
        id: 'Saat generate, XProject menambahkan folder **`.vscode/`** berisi **`launch.json`** (Run/Debug per flavor) '
            'dan **`tasks.json`** (build APK/AAB/IPA, `build_runner`, dll.). Bagian ini **bukan syarat** menyelesaikan '
            'checklist env, flavor, atau Firebase; run/build lewat **terminal** (`flutter run`, `flutter build`) tetap valid. '
            'Gunakan VS Code jika ingin **debug dengan breakpoint (F5)**, memilih device dari UI, atau menjalankan task build dari menu editor.',
      ),
    );
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: '**Prerequisites:** [VS Code](https://code.visualstudio.com/) with **Dart** and **Flutter** extensions '
            '(see [${_prerequisitesTitle(config)}](${_partOneSectionAnchor(config, 1, _prerequisitesTitle)})). Steps below assume VS Code because the generator included **`.vscode/`**.',
        id: '**Prasyarat:** [VS Code](https://code.visualstudio.com/) dengan ekstensi **Dart** dan **Flutter** '
            '(lihat [${_prerequisitesTitle(config)}](${_partOneSectionAnchor(config, 1, _prerequisitesTitle)})). Langkah di bawah memakai VS Code karena folder **`.vscode/`** '
            'sudah disertakan generator.',
      ),
    );
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: '#### A. Run and Debug (recommended for daily work)',
        id: '#### A. Run and Debug (disarankan untuk sehari-hari)',
      ),
    );
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: '1. **File → Open Folder** → select the **project root** (folder containing `pubspec.yaml`, not only `lib/`).',
        id: '1. **File → Open Folder** → pilih **root proyek** (folder yang berisi `pubspec.yaml`, bukan hanya `lib/`).',
      ),
    );
    buffer.writeln(
      guideText(
        config,
        en: '2. Left sidebar → **Run and Debug** icon (play with bug) → top dropdown → choose:',
        id: '2. Sidebar kiri → ikon **Run and Debug** (play dengan bug) → dropdown di atas → pilih:',
      ),
    );
    buffer.writeln(
      guideText(
        config,
        en: '   - **`[DEV] …`**: **development** flavor (`lib/main_development.dart`)',
        id: '   - **`[DEV] …`**: flavor **development** (`lib/main_development.dart`)',
      ),
    );
    buffer.writeln(
      guideText(
        config,
        en: '   - **`[STG] …`**: **staging** flavor',
        id: '   - **`[STG] …`**: flavor **staging**',
      ),
    );
    buffer.writeln(
      guideText(
        config,
        en: '   - **App name**: **production** flavor',
        id: '   - **Nama app**: flavor **production**',
      ),
    );
    buffer.writeln(
      guideText(
        config,
        en: '3. Bottom status bar → pick **device/emulator** (Chrome, Android, iOS simulator, …).',
        id: '3. Status bar bawah → pilih **device/emulator** (Chrome, Android, iOS simulator, …).',
      ),
    );
    buffer.writeln(
      guideText(
        config,
        en: '4. **F5** (*Start Debugging*) or the green play button.',
        id: '4. **F5** (*Start Debugging*) atau tombol play hijau.',
      ),
    );
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: 'Configurations live in **`.vscode/launch.json`**, equivalent to `flutter run --flavor … -t lib/main_….dart`.',
        id: 'Konfigurasi tersimpan di **`.vscode/launch.json`**, setara dengan perintah `flutter run --flavor … -t lib/main_….dart`.',
      ),
    );
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: '#### B. Tasks (build & codegen without a debug session)',
        id: '#### B. Tasks (build & codegen tanpa sesi debug)',
      ),
    );
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: '| Task | When to use |',
        id: '| Task | Kapan dipakai |',
      ),
    );
    buffer.writeln('| --- | --- |');
    buffer.writeln(
      guideText(
        config,
        en: '| Run Development / Staging / Production | Run the app in terminal from the editor |',
        id: '| Run Development / Staging / Production | Jalankan app di terminal dari editor |',
      ),
    );
    if (config.targetsAndroid) {
      buffer.writeln(
        guideText(
          config,
          en: '| Build APK - *flavor* | APK file to share |',
          id: '| Build APK - *flavor* | File APK untuk dibagikan |',
        ),
      );
      buffer.writeln(
        guideText(
          config,
          en: '| Build AppBundle - *flavor* | Upload to Play Store |',
          id: '| Build AppBundle - *flavor* | Upload ke Play Store |',
        ),
      );
    }
    if (config.targetsIos) {
      buffer.writeln(
        guideText(
          config,
          en: '| Build IPA - Staging/Production | iOS archive (requires Mac) |',
          id: '| Build IPA - Staging/Production | iOS archive (butuh Mac) |',
        ),
      );
    }
    buffer.writeln(
      guideText(
        config,
        en: '| Synchronize Build Runners | After changing models/codegen |',
        id: '| Synchronize Build Runners | Setelah ubah model/codegen |',
      ),
    );
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: 'Open tasks: **Terminal → Run Task…**, or **Cmd/Ctrl+Shift+P** → **Tasks: Run Task**.',
        id: 'Buka daftar task: menu **Terminal → Run Task…**, atau **Cmd/Ctrl+Shift+P** → ketik **Tasks: Run Task**.',
      ),
    );
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: 'Task definitions are in **`.vscode/tasks.json`**.',
        id: 'Definisi task ada di **`.vscode/tasks.json`**.',
      ),
    );
    buffer.writeln();
    if (config.targetsAndroid || config.targetsIos) {
      final parts = <String>[
        if (config.targetsAndroid)
          guideText(
            config,
            en: 'APK/AAB under `build/app/outputs/`',
            id: 'APK/AAB di `build/app/outputs/`',
          ),
        if (config.targetsIos)
          guideText(
            config,
            en: 'IPA requires Mac (`flutter build ipa` or **Build IPA** task)',
            id: 'IPA butuh Mac (`flutter build ipa` atau task **Build IPA**)',
          ),
      ];
      buffer.writeln(
        guideText(
          config,
          en: '**Release build:** ${parts.join('; ')}.',
          id: '**Build release:** ${parts.join('; ')}.',
        ),
      );
      buffer.writeln();
    }
  }

  static void runningApp(StringBuffer buffer, ProjectConfig config, String Function(String) heading) {
    buffer.writeln(heading(_partTwoSectionTitle(config, 'menjalankan-app')));
    buffer.writeln();
    buffer.writeln('```bash');
    buffer.writeln('flutter run --flavor development -t lib/main_development.dart');
    buffer.writeln('flutter run --flavor staging -t lib/main_staging.dart');
    buffer.writeln('flutter run --flavor production -t lib/main_production.dart');
    buffer.writeln('```');
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: '**`--flavor`** must match flavor names in Android/Xcode. **`-t`** selects the correct `main` file.',
        id: 'Flag **`--flavor`** harus sama dengan nama flavor di Android/Xcode. Flag **`-t`** menunjuk file `main` yang benar.',
      ),
    );
    buffer.writeln();
  }

  static void releaseBuild(StringBuffer buffer, ProjectConfig config) {
    buffer.writeln(
      '### ${guideText(config, en: 'Release build', id: 'Build release')}',
    );
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: '**Run** = development (hot reload). **Build** = release artifacts (APK/AAB/IPA).',
        id: '**Run** = untuk development (hot reload). **Build** = artefak rilis (APK/AAB/IPA).',
      ),
    );
    buffer.writeln();
    if (config.targetsAndroid) {
      buffer.writeln(
        guideText(
          config,
          en: 'APK is usually under `build/app/outputs/flutter-apk/`. App Bundle under `build/app/outputs/bundle/`.',
          id: 'APK biasanya di `build/app/outputs/flutter-apk/`. App Bundle di `build/app/outputs/bundle/`.',
        ),
      );
    }
    if (config.targetsIos) {
      buffer.writeln(
        guideText(
          config,
          en: 'IPA requires Mac + signing; use **Build IPA** task or `flutter build ipa`.',
          id: 'IPA membutuhkan Mac + signing; gunakan task **Build IPA** atau `flutter build ipa`.',
        ),
      );
    }
    buffer.writeln();
  }

  static void otherPlatforms(StringBuffer buffer, ProjectConfig config) {
    final extras = config.platformTargets.where(
      (p) =>
          p == PlatformTarget.web ||
          p == PlatformTarget.windows ||
          p == PlatformTarget.macos ||
          p == PlatformTarget.linux,
    );
    if (extras.isEmpty) return;
    buffer.writeln(
      '### ${guideText(config, en: 'Additional platforms', id: 'Platform tambahan')}',
    );
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: 'Mobile flavors do not always apply on web/desktop. Try `flutter run -d chrome` or `flutter run -d macos` after `flutter pub get`.',
        id: 'Flavor mobile tidak selalu berlaku di web/desktop. Coba `flutter run -d chrome` atau `flutter run -d macos` setelah `flutter pub get`.',
      ),
    );
    buffer.writeln();
  }

  static void ciCd(StringBuffer buffer, ProjectConfig config, String Function(String) heading) {
    if (config.usesGitHubActions) {
      _ciCdGitHub(buffer, config, heading);
    } else {
      _ciCdGitLab(buffer, config, heading);
    }
  }

  static void _ciCdGitHub(
    StringBuffer buffer,
    ProjectConfig config,
    String Function(String) heading,
  ) {
    buffer.writeln(heading(_partTwoSectionTitle(config, 'cicd-github')));
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: 'Workflow **`.github/workflows/flutter_ci.yml`** runs `flutter analyze` and `flutter test` '
            'on every push/PR. Build/deploy jobs (if selected) run manually via **Actions → Flutter CI → Run workflow**.',
        id: 'Workflow **`.github/workflows/flutter_ci.yml`** menjalankan `flutter analyze` dan `flutter test` '
            'pada setiap push/PR. Job build/deploy (jika dipilih) dijalankan manual lewat tab **Actions → Flutter CI → Run workflow**.',
      ),
    );
    buffer.writeln();
    if (config.hasCiDeploy) {
      buffer.writeln(
        guideText(
          config,
          en: '### Deploy secrets (GitHub Actions)',
          id: '### Rahasia deploy (GitHub Actions)',
        ),
      );
      buffer.writeln();
      buffer.writeln(
        guideText(
          config,
          en: '1. Open **`fastlane/.env.example`** in the project root — each commented line is a variable Fastlane or the workflow may read.',
          id: '1. Buka **`fastlane/.env.example`** — setiap baris komentar adalah variabel yang dibutuhkan.',
        ),
      );
      buffer.writeln(
        guideText(
          config,
          en: '2. In GitHub: **Settings → Secrets and variables → Actions → New repository secret** — create one secret per variable (same name as in the example file, without `#`).',
          id: '2. Di GitHub: **Settings → Secrets and variables → Actions** — buat secret per variabel.',
        ),
      );
      buffer.writeln(
        guideText(
          config,
          en: '3. Never commit keystores, `.p8` keys, or JSON service accounts; upload them via secrets or store on the runner only.',
          id: '3. Jangan commit keystore, `.p8`, atau JSON service account.',
        ),
      );
      buffer.writeln();
    }
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: 'iOS builds use the `macos-latest` runner on GitHub-hosted; you do not need your own Mac Mini unless you want a self-hosted GitHub runner.',
        id: 'Build iOS memakai runner `macos-latest` di GitHub-hosted; tidak perlu Mac Mini sendiri kecuali Anda ingin self-hosted runner GitHub.',
      ),
    );
    buffer.writeln();
  }

  static void _ciCdGitLab(
    StringBuffer buffer,
    ProjectConfig config,
    String Function(String) heading,
  ) {
    buffer.writeln(heading(_partTwoSectionTitle(config, 'cicd-gitlab')));
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: 'File **`.gitlab-ci.yml`** defines the GitLab pipeline (push/MR).',
        id: 'File **`.gitlab-ci.yml`** mendefinisikan pipeline GitLab (push/MR).',
      ),
    );
    buffer.writeln();
    if (config.gitLabSelfHostedShell) {
      buffer.writeln(
        guideText(
          config,
          en: '### Self-hosted runner (Mac Mini / local machine)',
          id: '### Runner self-hosted (Mac Mini / komputer lokal)',
        ),
      );
      buffer.writeln();
      buffer.writeln(
        guideText(
          config,
          en: '### Step-by-step (self-hosted shell)',
          id: '### Langkah demi langkah (shell self-hosted)',
        ),
      );
      buffer.writeln();
      buffer.writeln(
        guideText(
          config,
          en: '1. On the build Mac/PC: install Flutter; run `flutter doctor` as the user that will run the runner service.',
          id: '1. Di Mac/PC build: install Flutter; `flutter doctor` sebagai user runner.',
        ),
      );
      buffer.writeln(
        guideText(
          config,
          en: '2. Install GitLab Runner (`ci/GITLAB_RUNNER_SETUP.md` §2) and start the service.',
          id: '2. Install GitLab Runner dan jalankan servicenya.',
        ),
      );
      buffer.writeln(
        guideText(
          config,
          en: '3. GitLab → **Settings → CI/CD → Runners → New project runner** → copy token.',
          id: '3. GitLab → **Settings → CI/CD → Runners** → salin token.',
        ),
      );
      buffer.writeln(
        guideText(
          config,
          en: '4. `gitlab-runner register` with **shell** executor and tags **`self-hosted`**, **`flutter`**${config.targetsIos ? ', **`macos`**' : ''}.',
          id: '4. `gitlab-runner register` dengan executor **shell** dan tag yang cocok.',
        ),
      );
      buffer.writeln(
        guideText(
          config,
          en: '5. Push code; open **Build → Pipelines**. Jobs **`analyze`** and **`unit_test`** should run on your machine (not stay pending).',
          id: '5. Push; buka **Build → Pipelines**. Job **`analyze`** dan **`unit_test`** harus jalan.',
        ),
      );
      buffer.writeln();
      buffer.writeln(
        guideText(
          config,
          en: 'You chose the **shell executor**: jobs run directly on the team machine, not in a GitLab.com container. '
              'Full commands and register example: **`ci/GITLAB_RUNNER_SETUP.md`**.',
          id: 'Anda memilih **shell executor**: job berjalan di mesin tim. Detail: **`ci/GITLAB_RUNNER_SETUP.md`**.',
        ),
      );
      buffer.writeln();
      if (config.targetsIos) {
        buffer.writeln(
          guideText(
            config,
            en: 'For iOS, use a **Mac** as the runner and add the **`macos`** tag (already set on the iOS job).',
            id: 'Untuk iOS, gunakan **Mac** sebagai runner dan tambahkan tag **`macos`** (sudah diset di job iOS).',
          ),
        );
        buffer.writeln();
      }
    } else if (config.gitlabRunnerMode == GitLabRunnerMode.dockerfile) {
      buffer.writeln(
        guideText(
          config,
          en: 'Self-hosted **Docker** runner: build image `ci/Dockerfile`, push to the project registry, adjust `\$CI_REGISTRY_IMAGE` in YAML.',
          id: 'Runner **Docker** self-hosted: build image `ci/Dockerfile`, push ke registry proyek, sesuaikan `\$CI_REGISTRY_IMAGE` di YAML.',
        ),
      );
      buffer.writeln();
    } else {
      buffer.writeln(
        guideText(
          config,
          en: '**GitLab.com shared runner** mode uses image `ghcr.io/cirruslabs/flutter:stable`.',
          id: 'Mode **GitLab.com shared runner** memakai image `ghcr.io/cirruslabs/flutter:stable`.',
        ),
      );
      buffer.writeln();
    }
    if (config.ciCdScope == CiCdScope.ciOnly) {
      buffer.writeln(
        guideText(
          config,
          en: '**CI only:** `analyze` and `unit_test` jobs.',
          id: '**CI saja:** job `analyze` dan `unit_test`.',
        ),
      );
    } else {
      buffer.writeln(
        guideText(
          config,
          en: '**CI + deployment:** manual build/deploy jobs on the default branch; Fastlane when configured.',
          id: '**CI + deployment:** job build/deploy manual di branch default; Fastlane jika dikonfigurasi.',
        ),
      );
      buffer.writeln();
      buffer.writeln(
        guideText(
          config,
          en: '### Deploy secrets (GitLab CI/CD Variables)',
          id: '### Rahasia deploy (GitLab CI/CD Variables)',
        ),
      );
      buffer.writeln();
      buffer.writeln(
        guideText(
          config,
          en: '1. Read **`fastlane/.env.example`** — enable only variables for deploy targets you selected at generate time.',
          id: '1. Baca **`fastlane/.env.example`**.',
        ),
      );
      buffer.writeln(
        guideText(
          config,
          en: '2. **Settings → CI/CD → Variables → Add variable** — key = name from the example; value = secret; enable **Mask variable**.',
          id: '2. **Settings → CI/CD → Variables** — tambah variabel **masked**.',
        ),
      );
      buffer.writeln(
        guideText(
          config,
          en: '3. File-type secrets (keystore, AuthKey `.p8`): use **File** variable or place files on the runner and point env vars to those paths (shell executor).',
          id: '3. Keystore / `.p8`: variabel **File** atau path di runner.',
        ),
      );
      buffer.writeln(
        guideText(
          config,
          en: '4. Manual **build** / **deploy** jobs on the default branch need signing ready before you click ▶ in the pipeline.',
          id: '4. Job **build** / **deploy** manual butuh signing sebelum ▶.',
        ),
      );
    }
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: '**Self-managed** GitLab (your own server) uses the same runner steps; only the GitLab URL differs when running `gitlab-runner register`.',
        id: 'GitLab **self-managed** (server sendiri) memakai langkah runner yang sama; hanya URL GitLab yang berbeda saat `gitlab-runner register`.',
      ),
    );
    buffer.writeln();
  }

  static void troubleshooting(StringBuffer buffer, ProjectConfig config) {
    buffer.writeln('## ${_troubleshootingTitle(config)}');
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: '| Symptom | Likely cause | Fix |',
        id: '| Gejala | Kemungkinan penyebab | Solusi |',
      ),
    );
    buffer.writeln('| --- | --- | --- |');
    buffer.writeln(
      guideText(
        config,
        en: '| Gradle / build fails | SDK or JDK | `flutter doctor`; `flutter clean`; open the project in Android Studio once |',
        id: '| Gradle / build gagal | SDK atau JDK | `flutter doctor`; `flutter clean`; buka project di Android Studio sekali |',
      ),
    );
    buffer.writeln(
      guideText(
        config,
        en: '| Flavor not found | Wrong flavor name / iOS not set up | Match `--flavor` with Android & Xcode schemes |',
        id: '| Flavor tidak ditemukan | Nama flavor salah / iOS belum disetup | Cocokkan `--flavor` dengan Android & skema Xcode |',
      ),
    );
    buffer.writeln(
      guideText(
        config,
        en: '| Bundle ID mismatch | Flavor identifier differs from Firebase/Xcode | See identifier table above |',
        id: '| Bundle ID tidak cocok | Identifier flavor beda dengan Firebase/Xcode | Lihat tabel identifier di atas |',
      ),
    );
    if (config.useFirebase) {
      buffer.writeln(
        guideText(
          config,
          en: '| Firebase error | Placeholder config files | Replace `google-services.json` / `GoogleService-Info.plist` / `lib/firebase_options.dart` (and `web/firebase-messaging-sw.js` on web) |',
          id: '| Firebase error | File config placeholder | Ganti `google-services.json` / plist / `firebase_options` / SW web |',
        ),
      );
    }
    if (config.hasCiCd && !config.usesGitHubActions) {
      buffer.writeln(
        guideText(
          config,
          en: '| GitLab job stuck **pending** | No runner online or wrong **tags** / executor | Register runner per **`ci/GITLAB_RUNNER_SETUP.md`**; tags must include `self-hosted` and `flutter`${config.targetsIos ? ' (iOS jobs need `macos`)' : ''} |',
          id: '| Job GitLab **pending** | Runner offline atau tag salah | Register runner; tag harus cocok dengan `.gitlab-ci.yml` |',
        ),
      );
    }
    buffer.writeln(
      guideText(
        config,
        en: '| Odd hot reload | State / native change | Stop the app and Run again (full restart) |',
        id: '| Hot reload aneh | State / native change | Stop app lalu Run lagi (full restart) |',
      ),
    );
    buffer.writeln();
  }

  static void learnMore(StringBuffer buffer, ProjectConfig config) {
    buffer.writeln('## ${_learnMoreTitle(config)}');
    buffer.writeln();
    buffer.writeln(
      guideText(
        config,
        en: '- [Flutter documentation](https://docs.flutter.dev)',
        id: '- [Dokumentasi Flutter](https://docs.flutter.dev)',
      ),
    );
    buffer.writeln('- [Dart language tour](https://dart.dev/language)');
    buffer.writeln('- [XProject Generator](https://pub.dev/packages/xproject_generator)');
    buffer.writeln();
  }
}
