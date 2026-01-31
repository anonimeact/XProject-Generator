import 'dart:io';

import 'package:path/path.dart' as path;

import '../core/configs/project_config.dart';
import '../core/path.dart';
import 'templates/common_templates.dart';
import 'templates/getx/getx_feature_template.dart';
import 'templates/getx/getx_templates.dart';
import 'templates/riverpod/riverpod_feature_template.dart';
import 'templates/riverpod/riverpod_templates.dart';

/// XProject Generator - File Generator
///
/// Provides static methods to generate project files and feature templates for both GetX and Riverpod state management.
/// Handles writing, overwriting, and deleting files as needed for a new or existing Flutter project.
///
/// See README.md for more details.
class FileGenerator {
  /// Write [content] to a file at [filePath], creating directories as needed.
  static Future<void> _writeFile(String filePath, String content) async {
    final file = File(filePath);
    await file.create(recursive: true);
    await file.writeAsString(content);
  }

  /// Generate main entry files (main_development.dart, main_staging.dart, main_production.dart) in [libPath] for each environment.
  static Future<void> _generateMainFiles(
    String libPath,
    ProjectConfig config,
  ) async {
    for (final env in ['development', 'staging', 'production']) {
      await _writeFile(
        path.join(libPath, 'main_$env.dart'),
        CommonTemplates.mainFile(config, env),
      );
    }
  }

  /// Generate all project files for the given [config].
  ///
  /// This includes state management-specific files, common files, and environment-specific main files.
  static Future<void> generate(ProjectConfig config) async {
    final libPath = path.join(config.projectPath, 'lib');
    final testPath = path.join(config.projectPath, 'test');

    if (config.stateManagement == StateManagement.getx) {
      await _generateGetXFiles(libPath, config);
    } else {
      await _generateRiverpodFiles(libPath, config);
    }

    // Generate common files
    await _generateCommonFiles(libPath, config);

    // Generate main files for each environment
    await _generateMainFiles(libPath, config);

    final defaultMain = File(path.join(libPath, 'main.dart'));
    if (defaultMain.existsSync()) {
      await defaultMain.delete();
    }
    final defaultTest = File(path.join(testPath, 'widget_test.dart'));
    if (defaultTest.existsSync()) {
      await defaultTest.delete();
    }
  }

  /// Generate a new feature template for the given [stateManagement] and [featureName].
  static Future<void> generateFeature({
    required StateManagement stateManagement,
    required String featureName,
  }) async {
    final name = featureName.toLowerCase();

    switch (stateManagement) {
      case StateManagement.getx:
        await _generateGetXFeature(name);
        break;
      case StateManagement.riverpod:
        await _generateRiverpodFeature(name);
        break;
    }
  }

  /// Generate GetX feature files for [feature].
  static Future<void> _generateGetXFeature(String feature) async {
    final rootDir = findProjectRoot();
    final basePath = path.join(rootDir.path, 'lib', 'features', feature);

    final files = {
      '$feature/bindings/${feature}_binding.dart':
          GetxFeatureTemplate.generalBinding(feature),
      '$feature/controllers/${feature}_controller.dart':
          GetxFeatureTemplate.generalController(feature),
      '$feature/views/${feature}_view.dart': GetxFeatureTemplate.generalView(
        feature,
      ),
      '$feature/providers/${feature}_provider.dart':
          GetxFeatureTemplate.generalProvider(feature),
      '$feature/models/${feature}_model.dart': CommonTemplates.freezedModel(
        feature,
      ),
    };

    for (final entry in files.entries) {
      final file = File(path.join(basePath, entry.key));
      file.createSync(recursive: true);
      await file.writeAsString(entry.value);
    }
  }

  /// Generate Riverpod feature files for [feature].
  static Future<void> _generateRiverpodFeature(String feature) async {
    final rootDir = findProjectRoot();
    final basePath = path.join(rootDir.path, 'lib', 'features');

    final files = {
      '$feature/data/datasources/${feature}_datasources.dart':
          RiverpodFeatureTemplate.generalDataSource(feature),
      '$feature/data/models/${feature}_model.dart':
          CommonTemplates.freezedModel(feature),
      '$feature/presentation/providers/${feature}_provider.dart':
          RiverpodFeatureTemplate.generalProvider(feature),
      '$feature/presentation/views/${feature}_view.dart':
          RiverpodFeatureTemplate.generalView(feature),
    };

    for (final entry in files.entries) {
      final file = File(path.join(basePath, entry.key));
      file.createSync(recursive: true);
      await file.writeAsString(entry.value);
    }
  }

  /// Generate all GetX-specific files for a new project in [libPath] using [config].
  static Future<void> _generateGetXFiles(
    String libPath,
    ProjectConfig config,
  ) async {
    // App routes
    await _writeFile(
      path.join(libPath, 'routes/app_routes.dart'),
      GetXTemplates.appRoutes(),
    );

    await _writeFile(
      path.join(libPath, 'routes/app_pages.dart'),
      GetXTemplates.appPages(),
    );

    // Features - Splash
    await _writeFile(
      path.join(libPath, 'features/splash/views/splash_view.dart'),
      GetxFeatureTemplate.splashView(),
    );

    await _writeFile(
      path.join(libPath, 'features/splash/controllers/splash_controller.dart'),
      GetxFeatureTemplate.splashController(config),
    );

    await _writeFile(
      path.join(libPath, 'features/splash/bindings/splash_binding.dart'),
      GetxFeatureTemplate.splashBinding(),
    );

    // Home Feature
    await _writeFile(
      path.join(libPath, 'features/home/bindings/home_binding.dart'),
      GetxFeatureTemplate.homeBinding(),
    );

    await _writeFile(
      path.join(libPath, 'features/home/controllers/home_controller.dart'),
      GetxFeatureTemplate.homeController(),
    );

    await _writeFile(
      path.join(libPath, 'features/home/views/home_view.dart'),
      GetxFeatureTemplate.homeView(),
    );

    await _writeFile(
      path.join(libPath, 'features/home/providers/home_provider.dart'),
      GetxFeatureTemplate.generalProvider('home'),
    );

    // Features - Login
    await _writeFile(
      path.join(libPath, 'features/login/controllers/login_controller.dart'),
      GetxFeatureTemplate.loginController(),
    );

    await _writeFile(
      path.join(libPath, 'features/login/providers/login_provider.dart'),
      GetxFeatureTemplate.loginProvider(),
    );

    await _writeFile(
      path.join(libPath, 'features/login/views/login_view.dart'),
      GetxFeatureTemplate.loginView(),
    );

    await _writeFile(
      path.join(libPath, 'features/login/bindings/login_binding.dart'),
      GetxFeatureTemplate.loginBinding(),
    );

    // Models
    await _writeFile(
      path.join(libPath, 'features/login/models/user_model.dart'),
      CommonTemplates.userModel(),
    );

    await _writeFile(
      path.join(libPath, 'sessions/user_session.dart'),
      CommonTemplates.userSessionsGetx(),
    );

    await _writeFile(
      path.join(libPath, 'theme/text_style.dart'),
      CommonTemplates.textStyleHelperGetx(),
    );
  }

  /// Generate all Riverpod-specific files for a new project in [libPath] using [config].
  static Future<void> _generateRiverpodFiles(
    String libPath,
    ProjectConfig config,
  ) async {
    /// Theme
    await _writeFile(
      path.join(libPath, 'theme/theme_provider.dart'),
      RiverpodTemplates.themeProvider(),
    );

    /// Locale
    await _writeFile(
      path.join(libPath, 'core/l10n/locale_provider.dart'),
      RiverpodTemplates.localeProvider(),
    );
    // App router
    await _writeFile(
      path.join(libPath, 'routes/app_router.dart'),
      RiverpodTemplates.appRouter(),
    );
    await _writeFile(
      path.join(libPath, 'routes/routes.dart'),
      RiverpodTemplates.routes(),
    );

    // Extensions
    await _writeFile(
      path.join(libPath, 'core/extensions/datasource_refx.dart'),
      RiverpodFeatureTemplate.datasourceRefxExt(),
    );

    // Features - Splash
    await _writeFile(
      path.join(
        libPath,
        'features/splash/presentation/providers/splash_provider.dart',
      ),
      RiverpodFeatureTemplate.splashProvider(config),
    );
    await _writeFile(
      path.join(libPath, 'features/splash/presentation/views/splash_view.dart'),
      RiverpodFeatureTemplate.splashView(),
    );

    // Features - Login
    await _writeFile(
      path.join(libPath, 'features/login/data/models/user_model.dart'),
      CommonTemplates.userModel(),
    );

    await _writeFile(
      path.join(
        libPath,
        'features/login/data/datasources/login_remote_datasource.dart',
      ),
      RiverpodFeatureTemplate.loginRemoteDatasource(),
    );

    await _writeFile(
      path.join(
        libPath,
        'features/login/presentation/providers/login_provider.dart',
      ),
      RiverpodFeatureTemplate.loginProvider(),
    );

    await _writeFile(
      path.join(libPath, 'features/login/presentation/views/login_view.dart'),
      RiverpodFeatureTemplate.loginView(),
    );

    await _writeFile(
      path.join(
        libPath,
        'features/login/presentation/views/login_form_fields.dart',
      ),
      RiverpodFeatureTemplate.loginFormField(),
    );

    await _writeFile(
      path.join(
        libPath,
        'features/login/presentation/providers/login_form_provider.dart',
      ),
      RiverpodFeatureTemplate.loginFormProvider(),
    );

    // Home Feature
    await _writeFile(
      path.join(libPath, 'features/home/presentation/views/home_view.dart'),
      RiverpodFeatureTemplate.homeView(),
    );
    await _writeFile(
      path.join(
        libPath,
        'features/home/presentation/providers/home_provider.dart',
      ),
      RiverpodFeatureTemplate.generalProvider('home'),
    );
    await _writeFile(
      path.join(libPath, 'features/home/data/models/home_model.dart'),
      CommonTemplates.freezedModel('home'),
    );

    await _writeFile(
      path.join(
        libPath,
        'features/home/data/datasources/home_datasources.dart',
      ),
      RiverpodFeatureTemplate.generalDataSource('home'),
    );

    await _writeFile(
      path.join(libPath, 'sessions/user_session.dart'),
      CommonTemplates.userSessionsRiverpod(),
    );
    await _writeFile(
      path.join(libPath, 'theme/text_style.dart'),
      CommonTemplates.textStyleHelperRiverpod(),
    );
  }

  /// Generate common files (theme, localization, config, firebase, etc.) for the project.
  static Future<void> _generateCommonFiles(
    String libPath,
    ProjectConfig config,
  ) async {
    // Theme
    await _writeFile(
      path.join(libPath, 'theme/app_theme.dart'),
      CommonTemplates.appTheme(),
    );

    await _writeFile(
      path.join(libPath, 'theme/app_color.dart'),
      CommonTemplates.appColors(),
    );

    await _writeFile(
      path.join(libPath, 'core/l10n/string_resources.dart'),
      CommonTemplates.localizationRClass(),
    );

    await _writeFile(
      path.join(libPath, 'core/services/base_connection.dart'),
      config.stateManagement == .getx
          ? CommonTemplates.baseConnectionGetX()
          : CommonTemplates.baseConnectionRiverpod(),
    );

    // Config
    await _writeFile(
      path.join(libPath, 'core/config/env_config.dart'),
      CommonTemplates.envConfig(),
    );

    await _writeFile(
      path.join(libPath, 'core/config/get_env.dart'),
      CommonTemplates.getEnv(),
    );

    await _writeFile(
      path.join(libPath, 'core/config/cryptic.dart'),
      CommonTemplates.cryptic(),
    );

    /// Firebase
    if (config.useFirebase) {
      await _writeFile(
        path.join(libPath, 'core/services/firebase/firebase_service.dart'),
        CommonTemplates.firebaseService(),
      );

      await _writeFile(
        path.join(libPath, 'core/services/firebase/notification_service.dart'),
        CommonTemplates.notificationService(),
      );
    }

    // Localization
    await _writeFile(
      path.join(config.projectPath, 'l10n.yaml'),
      CommonTemplates.l10nYaml(),
    );

    await _writeFile(
      path.join(libPath, 'core/l10n/app_en.arb'),
      CommonTemplates.l10nArbEn(),
    );

    await _writeFile(
      path.join(libPath, 'core/l10n/app_id.arb'),
      CommonTemplates.l10nArbId(),
    );

    /// General model
    await _writeFile(
      path.join(libPath, 'core/models/global_api_response.dart'),
      CommonTemplates.globalApiResponse(),
    );

    // App widget
    await _writeFile(
      path.join(libPath, 'app.dart'),
      config.stateManagement == StateManagement.getx
          ? CommonTemplates.appWidgetGetX(config)
          : CommonTemplates.appWidgetRiverpod(config),
    );
  }
}
