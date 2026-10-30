/// Pure helpers for patching Flutter Android Gradle files (AGP 8+/9, built-in Kotlin).
library;

/// Enables [resValues] in `buildFeatures` when product flavors use `resValue()`.
String ensureAndroidResValuesEnabled(
  String content, {
  required bool isKotlinDsl,
}) {
  if (_resValuesAlreadyEnabled(content, isKotlinDsl)) {
    return content;
  }

  final buildFeaturesRegex = RegExp(
    r'buildFeatures\s*\{([\s\S]*?)\}',
    multiLine: true,
  );

  if (buildFeaturesRegex.hasMatch(content)) {
    return content.replaceFirstMapped(buildFeaturesRegex, (match) {
      final body = match.group(1) ?? '';
      if (_resValuesAlreadyEnabled(body, isKotlinDsl)) {
        return match.group(0)!;
      }
      final line = isKotlinDsl ? '        resValues = true\n' : '        resValues true\n';
      return 'buildFeatures {$body$line    }';
    });
  }

  final block = isKotlinDsl
      ? '''
    buildFeatures {
        resValues = true
    }
'''
      : '''
    buildFeatures {
        resValues true
    }
''';

  if (content.contains('ndkVersion = flutter.ndkVersion')) {
    return content.replaceFirst(
      'ndkVersion = flutter.ndkVersion',
      'ndkVersion = flutter.ndkVersion\n$block',
    );
  }

  return content.replaceFirst('android {', 'android {$block');
}

bool _resValuesAlreadyEnabled(String content, bool isKotlinDsl) {
  if (isKotlinDsl) {
    return RegExp(r'resValues\s*=\s*true').hasMatch(content);
  }
  return RegExp(r'resValues\s+true').hasMatch(content);
}

/// Normalizes app-module Gradle to Flutter built-in Kotlin (no KGP plugin on :app).
String ensureBuiltInKotlinAppGradle(
  String content, {
  required bool isKotlinDsl,
}) {
  var result = content;

  result = _removeAppKotlinGradlePlugin(result, isKotlinDsl: isKotlinDsl);
  result = _migrateKotlinOptionsToCompilerOptions(result, isKotlinDsl: isKotlinDsl);

  return result;
}

String _removeAppKotlinGradlePlugin(String content, {required bool isKotlinDsl}) {
  if (isKotlinDsl) {
    var result = content;
    result = result.replaceAll(
      RegExp(r'\s*id\("kotlin-android"\)\s*\n'),
      '\n',
    );
    result = result.replaceAll(
      RegExp(r'\s*id\("org\.jetbrains\.kotlin\.android"\)\s*\n'),
      '\n',
    );
    return result;
  }

  var result = content;
  result = result.replaceAll(
    RegExp(r"\s*apply plugin:\s*'kotlin-android'\s*\n"),
    '\n',
  );
  result = result.replaceAll(
    RegExp(r'\s*apply plugin:\s*"kotlin-android"\s*\n'),
    '\n',
  );
  return result;
}

String _migrateKotlinOptionsToCompilerOptions(
  String content, {
  required bool isKotlinDsl,
}) {
  final kotlinOptionsRegex = RegExp(
    r'\s*kotlinOptions\s*\{[\s\S]*?\}\s*\n',
    multiLine: true,
  );

  if (!kotlinOptionsRegex.hasMatch(content)) {
    return _ensureKotlinCompilerOptionsBlock(content, isKotlinDsl: isKotlinDsl);
  }

  var jvmTarget = 'JVM_17';
  final match = kotlinOptionsRegex.firstMatch(content);
  if (match != null) {
    final block = match.group(0) ?? '';
    final jvmMatch = RegExp(
      r'jvmTarget\s*=\s*(?:JavaVersion\.VERSION_(\d+)(?:\.toString\(\))?|org\.jetbrains\.kotlin\.gradle\.dsl\.JvmTarget\.JVM_(\d+))',
    ).firstMatch(block);
    if (jvmMatch != null) {
      jvmTarget = 'JVM_${jvmMatch.group(1) ?? jvmMatch.group(2) ?? '17'}';
    }
  }

  var result = content.replaceFirst(kotlinOptionsRegex, '\n');
  result = _ensureKotlinCompilerOptionsBlock(
    result,
    isKotlinDsl: isKotlinDsl,
    jvmTarget: jvmTarget,
  );
  return result;
}

String _ensureKotlinCompilerOptionsBlock(
  String content, {
  required bool isKotlinDsl,
  String jvmTarget = 'JVM_17',
}) {
  if (content.contains('compilerOptions') &&
      content.contains('kotlin {') &&
      content.contains('jvmTarget')) {
    return content;
  }

  final kotlinBlock = isKotlinDsl
      ? '''
kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.$jvmTarget
    }
}
'''
      : '''
kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.$jvmTarget
    }
}
''';

  if (content.contains('flutter {')) {
    return content.replaceFirst('flutter {', '$kotlinBlock\nflutter {');
  }

  return '$content\n$kotlinBlock';
}

/// Patches or appends desugaring with Java 17-compatible compile options.
String patchAndroidDesugaring(
  String content, {
  required bool isKotlinDsl,
}) {
  var result = ensureBuiltInKotlinAppGradle(
    content,
    isKotlinDsl: isKotlinDsl,
  );

  final compileOptionsRegex = RegExp(
    r'compileOptions\s*\{([\s\S]*?)\}',
    multiLine: true,
  );

  if (compileOptionsRegex.hasMatch(result)) {
    result = result.replaceFirstMapped(compileOptionsRegex, (match) {
      final blockBody = match.group(1) ?? '';

      if (blockBody.contains('isCoreLibraryDesugaringEnabled')) {
        return match.group(0)!;
      }

      final updatedBody =
          '$blockBody'
          '\n        isCoreLibraryDesugaringEnabled = true\n';

      return 'compileOptions {$updatedBody    }';
    });
  } else {
    final desugarCompileOptions = isKotlinDsl
        ? '''
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }
'''
        : '''
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
        coreLibraryDesugaringEnabled true
    }
''';

    if (result.contains('ndkVersion = flutter.ndkVersion')) {
      result = result.replaceFirst(
        'ndkVersion = flutter.ndkVersion',
        'ndkVersion = flutter.ndkVersion\n$desugarCompileOptions',
      );
    } else {
      result = result.replaceFirst(
        'android {',
        'android {$desugarCompileOptions',
      );
    }
  }

  return injectDesugarDependency(result, isKotlinDsl: isKotlinDsl);
}

String injectDesugarDependency(String content, {required bool isKotlinDsl}) {
  if (content.contains('desugar_jdk_libs')) return content;

  final depLine = isKotlinDsl
      ? '    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")'
      : "    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.5'";

  final depBlockRegex = RegExp(r'dependencies\s*\{', multiLine: true);

  if (!depBlockRegex.hasMatch(content)) {
    return '''$content
dependencies {
$depLine
}
''';
  }

  return content.replaceFirstMapped(depBlockRegex, (match) {
    return '${match.group(0)}\n$depLine';
  });
}

/// Ensures Flutter AGP transition flags exist in android/gradle.properties.
String ensureGradlePropertiesFlags(String content) {
  var result = content;
  if (!result.contains('android.newDsl=')) {
    result = result.endsWith('\n') ? result : '$result\n';
    result += 'android.newDsl=false\n';
  }
  if (!result.contains('android.builtInKotlin=')) {
    result = result.endsWith('\n') ? result : '$result\n';
    result += 'android.builtInKotlin=false\n';
  }
  return result;
}

/// Google Services Gradle plugin id applied for `google-services.json`.
const String googleServicesPluginId = 'com.google.gms.google-services';

/// Crashlytics Gradle plugin id. Required by `firebase_crashlytics`.
const String firebaseCrashlyticsPluginId = 'com.google.firebase.crashlytics';

/// Plugin version used in `android/settings.gradle` (apply false).
const String googleServicesPluginVersion = '4.4.2';

/// Plugin version used in `android/settings.gradle` (apply false).
const String firebaseCrashlyticsPluginVersion = '3.0.3';

/// Adds the Google Services and Crashlytics Gradle plugins when they are missing.
///
/// [isSettingsFile] inserts `version "…" apply false` (or the Kotlin DSL
/// equivalent) inside the root `plugins` block. The app module gets the ids
/// without a version so it uses the version declared in settings.
///
/// The function is idempotent: a second call returns [content] unchanged.
/// Throws [FormatException] when there is no `plugins { }` block to edit.
String ensureFirebaseGradlePlugins(
  String content, {
  required bool isKotlinDsl,
  required bool isSettingsFile,
}) {
  final missing = <String>[
    if (!content.contains(googleServicesPluginId)) googleServicesPluginId,
    if (!content.contains(firebaseCrashlyticsPluginId))
      firebaseCrashlyticsPluginId,
  ];
  if (missing.isEmpty) {
    return content;
  }

  final pluginsOpen = RegExp(r'plugins\s*\{');
  final openMatch = pluginsOpen.firstMatch(content);
  if (openMatch == null) {
    throw const FormatException(
      'No plugins { } block found. Add the Google Services Gradle plugin '
      'manually before building with Firebase.',
    );
  }

  final rest = content.substring(openMatch.end);
  final close = RegExp(r'\n\}').firstMatch(rest);
  if (close == null) {
    throw const FormatException(
      'The plugins { } block does not close, so Firebase plugins were not added.',
    );
  }

  final lines = missing
      .map(
        (id) => _firebasePluginLine(
          id,
          isKotlinDsl: isKotlinDsl,
          isSettingsFile: isSettingsFile,
        ),
      )
      .join('\n');

  final insertAt = openMatch.end + close.start;
  return content.replaceRange(insertAt, insertAt, '\n$lines');
}

String _firebasePluginLine(
  String id, {
  required bool isKotlinDsl,
  required bool isSettingsFile,
}) {
  final version = id == googleServicesPluginId
      ? googleServicesPluginVersion
      : firebaseCrashlyticsPluginVersion;

  if (isKotlinDsl) {
    if (isSettingsFile) {
      return '    id("$id") version "$version" apply false';
    }
    return '    id("$id")';
  }

  if (isSettingsFile) {
    return '    id "$id" version "$version" apply false';
  }
  return '    id "$id"';
}

/// Sets launcher label to flavor-driven @string/app_name.
String patchAndroidManifestAppLabel(String manifestContent) {
  if (manifestContent.contains('android:label="@string/app_name"')) {
    return manifestContent;
  }

  final labelRegex = RegExp(r'android:label="[^"]*"');
  if (!labelRegex.hasMatch(manifestContent)) {
    return manifestContent;
  }

  return manifestContent.replaceFirst(
    labelRegex,
    'android:label="@string/app_name"',
  );
}
