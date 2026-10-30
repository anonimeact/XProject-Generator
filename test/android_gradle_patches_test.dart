import 'package:test/test.dart';
import 'package:xproject_generator/src/android_gradle_patches.dart';

void main() {
  const flutter347AppGradle = '''
plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
''';

  const legacyAppGradle = '''
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }
}

flutter {
    source = "../.."
}
''';

  group('ensureAndroidResValuesEnabled', () {
    test('injects buildFeatures for Kotlin DSL', () {
      final result = ensureAndroidResValuesEnabled(
        flutter347AppGradle,
        isKotlinDsl: true,
      );

      expect(result, contains('buildFeatures'));
      expect(result, contains('resValues = true'));
    });

    test('is idempotent for Kotlin DSL', () {
      final once = ensureAndroidResValuesEnabled(
        flutter347AppGradle,
        isKotlinDsl: true,
      );
      final twice = ensureAndroidResValuesEnabled(once, isKotlinDsl: true);

      expect(
        'resValues = true'.allMatches(twice).length,
        1,
      );
    });

    test('adds resValues to existing buildFeatures block', () {
      const withBlock = '''
android {
    buildFeatures {
        buildConfig = true
    }
}
''';
      final result = ensureAndroidResValuesEnabled(
        withBlock,
        isKotlinDsl: true,
      );

      expect(result, contains('resValues = true'));
      expect(result, contains('buildConfig = true'));
    });
  });

  group('ensureBuiltInKotlinAppGradle', () {
    test('keeps Flutter 3.47 template unchanged', () {
      final result = ensureBuiltInKotlinAppGradle(
        flutter347AppGradle,
        isKotlinDsl: true,
      );

      expect(result, isNot(contains('kotlin-android')));
      expect(result, contains('kotlin {'));
      expect(result, contains('compilerOptions'));
    });

    test('migrates legacy kotlin-android template', () {
      final result = ensureBuiltInKotlinAppGradle(
        legacyAppGradle,
        isKotlinDsl: true,
      );

      expect(result, isNot(contains('kotlin-android')));
      expect(result, isNot(contains('kotlinOptions')));
      expect(result, contains('kotlin {'));
      expect(result, contains('JvmTarget.JVM_17'));
    });
  });

  group('patchAndroidDesugaring', () {
    test('enables desugaring without lowering Java version', () {
      final result = patchAndroidDesugaring(
        flutter347AppGradle,
        isKotlinDsl: true,
      );

      expect(result, contains('isCoreLibraryDesugaringEnabled = true'));
      expect(result, contains('VERSION_17'));
      expect(result, isNot(contains('VERSION_1_8')));
      expect(result, contains('desugar_jdk_libs'));
    });
  });

  group('ensureGradlePropertiesFlags', () {
    test('appends missing Flutter AGP flags', () {
      const input = 'org.gradle.jvmargs=-Xmx4G\n';
      final result = ensureGradlePropertiesFlags(input);

      expect(result, contains('android.newDsl=false'));
      expect(result, contains('android.builtInKotlin=false'));
    });

    test('does not duplicate flags', () {
      const input = '''
android.newDsl=false
android.builtInKotlin=false
''';
      final result = ensureGradlePropertiesFlags(input);

      expect('android.newDsl=false'.allMatches(result).length, 1);
      expect('android.builtInKotlin=false'.allMatches(result).length, 1);
    });
  });

  group('patchAndroidManifestAppLabel', () {
    test('replaces application label with app_name resource', () {
      const manifest = '''
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application android:label="my_app" android:icon="@mipmap/ic_launcher">
    </application>
</manifest>
''';

      final result = patchAndroidManifestAppLabel(manifest);
      expect(result, contains('android:label="@string/app_name"'));
    });
  });
}
