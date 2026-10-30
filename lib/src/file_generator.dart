import 'dart:io';

import 'package:path/path.dart' as path;

import '../core/configs/project_config.dart';
import '../core/path.dart';
import 'ci_cd_generator.dart';
import 'integrations/guide_writer.dart';
import 'project_config_file.dart';
import 'project_gitignore.dart';
import 'templates/bloc/bloc_feature_template.dart';
import 'templates/bloc/bloc_templates.dart';
import 'templates/common_templates.dart';
import 'templates/getx/getx_feature_template.dart';
import 'templates/getx/getx_templates.dart';
import 'templates/project_readme_template.dart';
import 'templates/provider/provider_feature_template.dart';
import 'templates/provider/provider_templates.dart';
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
    } else if (config.stateManagement == StateManagement.riverpod) {
      if (config.riverpodArchitecture == StateManagementArchitecture.clean) {
        await _generateRiverpodCleanFiles(libPath, config);
      } else {
        await _generateRiverpodFiles(libPath, config);
      }
    } else if (config.stateManagement == StateManagement.provider) {
      await _generateProviderFiles(libPath, config);
    } else {
      if (config.blocArchitecture == StateManagementArchitecture.clean) {
        await _generateBlocCleanFiles(libPath, config);
      } else {
        await _generateBlocFiles(libPath, config);
      }
    }

    // Generate common files
    await _generateCommonFiles(libPath, config);

    // Generate main files for each environment
    await _generateMainFiles(libPath, config);

    await GuideWriter.writeAll(config);
    await XProjectConfigFile.write(config);

    await _writeFile(
      path.join(config.projectPath, 'README.md'),
      ProjectReadmeTemplate.content(config),
    );

    await CiCdGenerator.generate(config);
    await ProjectGitignore.append(config);

    final defaultMain = File(path.join(libPath, 'main.dart'));
    if (defaultMain.existsSync()) {
      await defaultMain.delete();
    }
    // Default widget_test imports main.dart, which this generator replaces
    // with flavor entry points. CI writes test/smoke_test.dart instead.
    final defaultTest = File(path.join(testPath, 'widget_test.dart'));
    if (defaultTest.existsSync()) {
      await defaultTest.delete();
    }
  }

  /// Generate a new feature template for the given [stateManagement] and [featureName].
  static Future<void> generateFeature({
    required StateManagement stateManagement,
    required String featureName,
    StateManagementArchitecture? architecture,
  }) async {
    final name = featureName.toLowerCase();

    switch (stateManagement) {
      case StateManagement.getx:
        await _generateGetXFeature(name);
        break;
      case StateManagement.riverpod:
        final resolvedArchitecture =
            architecture ?? _detectArchitectureFromProject();
        if (resolvedArchitecture == StateManagementArchitecture.clean) {
          await _generateRiverpodFeatureClean(name);
        } else {
          await _generateRiverpodFeature(name);
        }
        break;
      case StateManagement.bloc:
        final resolvedArchitecture =
            architecture ?? _detectArchitectureFromProject();
        if (resolvedArchitecture == StateManagementArchitecture.clean) {
          await _generateBlocFeatureClean(name);
        } else {
          await _generateBlocFeature(name);
        }
        break;
      case StateManagement.provider:
        await _generateProviderFeature(name);
        break;
    }
  }

  static StateManagementArchitecture _detectArchitectureFromProject() {
    final rootDir = findProjectRoot();
    final featuresDir = Directory(path.join(rootDir.path, 'lib', 'features'));
    if (!featuresDir.existsSync()) return StateManagementArchitecture.simple;

    final entries = featuresDir.listSync();
    for (final entry in entries) {
      if (entry is Directory) {
        final domainDir = Directory(path.join(entry.path, 'domain'));
        if (domainDir.existsSync()) {
          return StateManagementArchitecture.clean;
        }

        final dataRepositories = Directory(
          path.join(entry.path, 'data', 'repositories'),
        );
        if (dataRepositories.existsSync()) {
          return StateManagementArchitecture.clean;
        }
      }
    }
    return StateManagementArchitecture.simple;
  }

  /// Generate GetX feature files for [feature].
  static Future<void> _generateGetXFeature(String feature) async {
    final rootDir = findProjectRoot();
    final basePath = path.join(rootDir.path, 'lib', 'features');

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

  static Future<void> _generateRiverpodFeatureClean(String feature) async {
    final rootDir = findProjectRoot();
    final basePath = path.join(rootDir.path, 'lib', 'features');

    final files = {
      '$feature/data/datasources/${feature}_datasources.dart':
          RiverpodFeatureTemplate.generalDataSource(feature),
      '$feature/data/models/${feature}_model.dart':
          CommonTemplates.freezedModel(feature),
      '$feature/data/repositories/${feature}_repository_impl.dart':
          RiverpodFeatureTemplate.generalRepositoryImpl(feature),
      '$feature/domain/entities/${feature}_entity.dart':
          RiverpodFeatureTemplate.generalEntity(feature),
      '$feature/domain/repositories/${feature}_repository.dart':
          RiverpodFeatureTemplate.generalRepository(feature),
      '$feature/domain/usecases/get_${feature}.dart':
          RiverpodFeatureTemplate.generalUsecase(feature),
      '$feature/presentation/providers/${feature}_provider.dart':
          RiverpodFeatureTemplate.generalProviderClean(feature),
      '$feature/presentation/views/${feature}_view.dart':
          RiverpodFeatureTemplate.generalViewClean(feature),
    };

    for (final entry in files.entries) {
      final file = File(path.join(basePath, entry.key));
      file.createSync(recursive: true);
      await file.writeAsString(entry.value);
    }
  }

  /// Generate Provider feature files for [feature].
  static Future<void> _generateProviderFeature(String feature) async {
    final rootDir = findProjectRoot();
    final basePath = path.join(rootDir.path, 'lib', 'features');

    final files = {
      '$feature/data/datasources/${feature}_remote_datasource.dart':
          ProviderFeatureTemplate.generalRemoteDatasource(feature),
      '$feature/data/models/${feature}_model.dart':
          CommonTemplates.freezedModel(feature),
      '$feature/presentation/notifiers/${feature}_notifier.dart':
          ProviderFeatureTemplate.generalNotifier(feature),
      '$feature/presentation/notifiers/${feature}_state.dart':
          ProviderFeatureTemplate.generalState(feature),
      '$feature/presentation/views/${feature}_view.dart':
          ProviderFeatureTemplate.generalView(feature),
    };

    for (final entry in files.entries) {
      final file = File(path.join(basePath, entry.key));
      file.createSync(recursive: true);
      await file.writeAsString(entry.value);
    }
  }

  /// Generate Bloc feature files for [feature].
  static Future<void> _generateBlocFeature(String feature) async {
    final rootDir = findProjectRoot();
    final basePath = path.join(rootDir.path, 'lib', 'features');

    final files = {
      '$feature/data/datasources/${feature}_remote_datasource.dart':
          BlocFeatureTemplate.generalRemoteDatasource(feature),
      '$feature/data/models/${feature}_model.dart':
          CommonTemplates.freezedModel(feature),
      '$feature/presentation/bloc/${feature}_bloc.dart':
          BlocFeatureTemplate.generalBlocSimple(feature),
      '$feature/presentation/bloc/${feature}_event.dart':
          BlocFeatureTemplate.generalEvent(feature),
      '$feature/presentation/bloc/${feature}_state.dart':
          BlocFeatureTemplate.generalState(feature),
      '$feature/presentation/views/${feature}_view.dart':
          BlocFeatureTemplate.generalViewSimple(feature),
    };

    for (final entry in files.entries) {
      final file = File(path.join(basePath, entry.key));
      file.createSync(recursive: true);
      await file.writeAsString(entry.value);
    }
  }

  /// Generate Bloc Clean Code feature files for [feature].
  static Future<void> _generateBlocFeatureClean(String feature) async {
    final rootDir = findProjectRoot();
    final basePath = path.join(rootDir.path, 'lib', 'features');

    final files = {
      '$feature/data/datasources/${feature}_remote_datasource.dart':
          BlocFeatureTemplate.generalRemoteDatasource(feature),
      '$feature/data/models/${feature}_model.dart':
          CommonTemplates.freezedModel(feature),
      '$feature/data/repositories/${feature}_repository_impl.dart':
          BlocFeatureTemplate.generalRepositoryImpl(feature),
      '$feature/domain/entities/${feature}_entity.dart':
          BlocFeatureTemplate.generalEntity(feature),
      '$feature/domain/repositories/${feature}_repository.dart':
          BlocFeatureTemplate.generalRepository(feature),
      '$feature/domain/usecases/get_${feature}.dart':
          BlocFeatureTemplate.generalUsecase(feature),
      '$feature/presentation/bloc/${feature}_bloc.dart':
          BlocFeatureTemplate.generalBloc(feature),
      '$feature/presentation/bloc/${feature}_event.dart':
          BlocFeatureTemplate.generalEvent(feature),
      '$feature/presentation/bloc/${feature}_state.dart':
          BlocFeatureTemplate.generalState(feature),
      '$feature/presentation/views/${feature}_view.dart':
          BlocFeatureTemplate.generalView(feature),
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
      path.join(libPath, 'features/home/widgets/home_shell.dart'),
      CommonTemplates.homeShell('../../../'),
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
      path.join(libPath, 'features/login/widgets/auth_scaffold.dart'),
      CommonTemplates.authScaffold('../../../'),
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
        'features/login/presentation/widgets/auth_scaffold.dart',
      ),
      CommonTemplates.authScaffold('../../../../'),
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
        'features/home/presentation/widgets/home_shell.dart',
      ),
      CommonTemplates.homeShell('../../../../'),
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

  /// Generate all Riverpod Clean Code files for a new project in [libPath] using [config].
  static Future<void> _generateRiverpodCleanFiles(
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
        'features/login/domain/repositories/login_repository.dart',
      ),
      RiverpodFeatureTemplate.loginRepository(),
    );

    await _writeFile(
      path.join(
        libPath,
        'features/login/data/repositories/login_repository_impl.dart',
      ),
      RiverpodFeatureTemplate.loginRepositoryImpl(),
    );

    await _writeFile(
      path.join(libPath, 'features/login/domain/usecases/login_user.dart'),
      RiverpodFeatureTemplate.loginUsecase(),
    );

    await _writeFile(
      path.join(
        libPath,
        'features/login/presentation/providers/login_provider.dart',
      ),
      RiverpodFeatureTemplate.loginProviderClean(),
    );

    await _writeFile(
      path.join(libPath, 'features/login/presentation/views/login_view.dart'),
      RiverpodFeatureTemplate.loginViewClean(),
    );

    await _writeFile(
      path.join(
        libPath,
        'features/login/presentation/widgets/auth_scaffold.dart',
      ),
      CommonTemplates.authScaffold('../../../../'),
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
        'features/home/presentation/widgets/home_shell.dart',
      ),
      CommonTemplates.homeShell('../../../../'),
    );
    await _writeFile(
      path.join(
        libPath,
        'features/home/presentation/providers/home_provider.dart',
      ),
      RiverpodFeatureTemplate.generalProviderClean('home'),
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
      path.join(
        libPath,
        'features/home/domain/repositories/home_repository.dart',
      ),
      RiverpodFeatureTemplate.generalRepository('home'),
    );
    await _writeFile(
      path.join(
        libPath,
        'features/home/data/repositories/home_repository_impl.dart',
      ),
      RiverpodFeatureTemplate.generalRepositoryImpl('home'),
    );
    await _writeFile(
      path.join(libPath, 'features/home/domain/usecases/get_home.dart'),
      RiverpodFeatureTemplate.generalUsecase('home'),
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

  /// Generate all Bloc-specific files for a new project in [libPath] using [config].
  static Future<void> _generateProviderFiles(
    String libPath,
    ProjectConfig config,
  ) async {
    await _writeFile(
      path.join(libPath, 'routes/app_router.dart'),
      ProviderTemplates.appRouter(),
    );
    await _writeFile(
      path.join(libPath, 'routes/routes.dart'),
      ProviderTemplates.routes(),
    );

    await _writeFile(
      path.join(
        libPath,
        'features/splash/presentation/notifiers/splash_notifier.dart',
      ),
      ProviderFeatureTemplate.splashNotifier(config),
    );
    await _writeFile(
      path.join(libPath, 'features/splash/presentation/views/splash_view.dart'),
      ProviderFeatureTemplate.splashView(),
    );

    await _writeFile(
      path.join(libPath, 'features/login/data/models/user_model.dart'),
      CommonTemplates.userModel(),
    );
    await _writeFile(
      path.join(
        libPath,
        'features/login/data/datasources/login_remote_datasource.dart',
      ),
      ProviderFeatureTemplate.loginRemoteDatasource(),
    );
    await _writeFile(
      path.join(
        libPath,
        'features/login/presentation/notifiers/login_state.dart',
      ),
      ProviderFeatureTemplate.loginState(),
    );
    await _writeFile(
      path.join(
        libPath,
        'features/login/presentation/notifiers/login_notifier.dart',
      ),
      ProviderFeatureTemplate.loginNotifier(),
    );
    await _writeFile(
      path.join(libPath, 'features/login/presentation/views/login_view.dart'),
      ProviderFeatureTemplate.loginView(),
    );
    await _writeFile(
      path.join(
        libPath,
        'features/login/presentation/widgets/auth_scaffold.dart',
      ),
      CommonTemplates.authScaffold('../../../../'),
    );

    await _writeFile(
      path.join(libPath, 'features/home/data/models/home_model.dart'),
      CommonTemplates.freezedModel('home'),
    );
    await _writeFile(
      path.join(
        libPath,
        'features/home/data/datasources/home_remote_datasource.dart',
      ),
      ProviderFeatureTemplate.generalRemoteDatasource('home'),
    );
    await _writeFile(
      path.join(
        libPath,
        'features/home/presentation/notifiers/home_state.dart',
      ),
      ProviderFeatureTemplate.generalState('home'),
    );
    await _writeFile(
      path.join(
        libPath,
        'features/home/presentation/notifiers/home_notifier.dart',
      ),
      ProviderFeatureTemplate.generalNotifier('home'),
    );
    await _writeFile(
      path.join(libPath, 'features/home/presentation/views/home_view.dart'),
      ProviderFeatureTemplate.homeView(),
    );
    await _writeFile(
      path.join(
        libPath,
        'features/home/presentation/widgets/home_shell.dart',
      ),
      CommonTemplates.homeShell('../../../../'),
    );

    await _writeFile(
      path.join(libPath, 'sessions/user_session.dart'),
      CommonTemplates.userSessionsBloc(),
    );
    await _writeFile(
      path.join(libPath, 'theme/text_style.dart'),
      CommonTemplates.textStyleHelperBloc(),
    );
  }

  static Future<void> _generateBlocFiles(
    String libPath,
    ProjectConfig config,
  ) async {
    // App router
    await _writeFile(
      path.join(libPath, 'routes/app_router.dart'),
      BlocTemplates.appRouter(),
    );
    await _writeFile(
      path.join(libPath, 'routes/routes.dart'),
      BlocTemplates.routes(),
    );

    // Features - Splash
    await _writeFile(
      path.join(libPath, 'features/splash/presentation/bloc/splash_event.dart'),
      BlocFeatureTemplate.splashEvent(),
    );
    await _writeFile(
      path.join(libPath, 'features/splash/presentation/bloc/splash_state.dart'),
      BlocFeatureTemplate.splashState(),
    );
    await _writeFile(
      path.join(libPath, 'features/splash/presentation/bloc/splash_bloc.dart'),
      BlocFeatureTemplate.splashBloc(config),
    );
    await _writeFile(
      path.join(libPath, 'features/splash/presentation/views/splash_view.dart'),
      BlocFeatureTemplate.splashView(),
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
      BlocFeatureTemplate.loginRemoteDatasource(),
    );
    await _writeFile(
      path.join(libPath, 'features/login/presentation/bloc/login_event.dart'),
      BlocFeatureTemplate.loginEvent(),
    );
    await _writeFile(
      path.join(libPath, 'features/login/presentation/bloc/login_state.dart'),
      BlocFeatureTemplate.loginState(),
    );
    await _writeFile(
      path.join(libPath, 'features/login/presentation/bloc/login_bloc.dart'),
      BlocFeatureTemplate.loginBlocSimple(),
    );
    await _writeFile(
      path.join(libPath, 'features/login/presentation/views/login_view.dart'),
      BlocFeatureTemplate.loginViewSimple(),
    );
    await _writeFile(
      path.join(
        libPath,
        'features/login/presentation/widgets/auth_scaffold.dart',
      ),
      CommonTemplates.authScaffold('../../../../'),
    );

    // Home Feature
    await _writeFile(
      path.join(libPath, 'features/home/data/models/home_model.dart'),
      CommonTemplates.freezedModel('home'),
    );
    await _writeFile(
      path.join(
        libPath,
        'features/home/data/datasources/home_remote_datasource.dart',
      ),
      BlocFeatureTemplate.generalRemoteDatasource('home'),
    );
    await _writeFile(
      path.join(libPath, 'features/home/presentation/bloc/home_event.dart'),
      BlocFeatureTemplate.generalEvent('home'),
    );
    await _writeFile(
      path.join(libPath, 'features/home/presentation/bloc/home_state.dart'),
      BlocFeatureTemplate.generalState('home'),
    );
    await _writeFile(
      path.join(libPath, 'features/home/presentation/bloc/home_bloc.dart'),
      BlocFeatureTemplate.generalBlocSimple('home'),
    );
    await _writeFile(
      path.join(libPath, 'features/home/presentation/views/home_view.dart'),
      BlocFeatureTemplate.homeView(),
    );
    await _writeFile(
      path.join(
        libPath,
        'features/home/presentation/widgets/home_shell.dart',
      ),
      CommonTemplates.homeShell('../../../../'),
    );

    await _writeFile(
      path.join(libPath, 'sessions/user_session.dart'),
      CommonTemplates.userSessionsBloc(),
    );
    await _writeFile(
      path.join(libPath, 'theme/text_style.dart'),
      CommonTemplates.textStyleHelperBloc(),
    );
  }

  static Future<void> _generateBlocCleanFiles(
    String libPath,
    ProjectConfig config,
  ) async {
    // App router
    await _writeFile(
      path.join(libPath, 'routes/app_router.dart'),
      BlocTemplates.appRouter(),
    );
    await _writeFile(
      path.join(libPath, 'routes/routes.dart'),
      BlocTemplates.routes(),
    );

    // Features - Splash
    await _writeFile(
      path.join(libPath, 'features/splash/presentation/bloc/splash_event.dart'),
      BlocFeatureTemplate.splashEvent(),
    );
    await _writeFile(
      path.join(libPath, 'features/splash/presentation/bloc/splash_state.dart'),
      BlocFeatureTemplate.splashState(),
    );
    await _writeFile(
      path.join(libPath, 'features/splash/presentation/bloc/splash_bloc.dart'),
      BlocFeatureTemplate.splashBloc(config),
    );
    await _writeFile(
      path.join(libPath, 'features/splash/presentation/views/splash_view.dart'),
      BlocFeatureTemplate.splashView(),
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
      BlocFeatureTemplate.loginRemoteDatasource(),
    );
    await _writeFile(
      path.join(
        libPath,
        'features/login/domain/repositories/login_repository.dart',
      ),
      BlocFeatureTemplate.loginRepository(),
    );
    await _writeFile(
      path.join(
        libPath,
        'features/login/data/repositories/login_repository_impl.dart',
      ),
      BlocFeatureTemplate.loginRepositoryImpl(),
    );
    await _writeFile(
      path.join(libPath, 'features/login/domain/usecases/login_user.dart'),
      BlocFeatureTemplate.loginUsecase(),
    );
    await _writeFile(
      path.join(libPath, 'features/login/presentation/bloc/login_event.dart'),
      BlocFeatureTemplate.loginEvent(),
    );
    await _writeFile(
      path.join(libPath, 'features/login/presentation/bloc/login_state.dart'),
      BlocFeatureTemplate.loginState(),
    );
    await _writeFile(
      path.join(libPath, 'features/login/presentation/bloc/login_bloc.dart'),
      BlocFeatureTemplate.loginBloc(),
    );
    await _writeFile(
      path.join(libPath, 'features/login/presentation/views/login_view.dart'),
      BlocFeatureTemplate.loginView(),
    );
    await _writeFile(
      path.join(
        libPath,
        'features/login/presentation/widgets/auth_scaffold.dart',
      ),
      CommonTemplates.authScaffold('../../../../'),
    );

    // Home Feature
    await _writeFile(
      path.join(libPath, 'features/home/data/models/home_model.dart'),
      CommonTemplates.freezedModel('home'),
    );
    await _writeFile(
      path.join(
        libPath,
        'features/home/data/datasources/home_remote_datasource.dart',
      ),
      BlocFeatureTemplate.generalRemoteDatasource('home'),
    );
    await _writeFile(
      path.join(
        libPath,
        'features/home/domain/repositories/home_repository.dart',
      ),
      BlocFeatureTemplate.generalRepository('home'),
    );
    await _writeFile(
      path.join(
        libPath,
        'features/home/data/repositories/home_repository_impl.dart',
      ),
      BlocFeatureTemplate.generalRepositoryImpl('home'),
    );
    await _writeFile(
      path.join(libPath, 'features/home/domain/usecases/get_home.dart'),
      BlocFeatureTemplate.generalUsecase('home'),
    );
    await _writeFile(
      path.join(libPath, 'features/home/presentation/bloc/home_event.dart'),
      BlocFeatureTemplate.generalEvent('home'),
    );
    await _writeFile(
      path.join(libPath, 'features/home/presentation/bloc/home_state.dart'),
      BlocFeatureTemplate.generalState('home'),
    );
    await _writeFile(
      path.join(libPath, 'features/home/presentation/bloc/home_bloc.dart'),
      BlocFeatureTemplate.generalBloc('home'),
    );
    await _writeFile(
      path.join(libPath, 'features/home/presentation/views/home_view.dart'),
      BlocFeatureTemplate.homeView(),
    );
    await _writeFile(
      path.join(
        libPath,
        'features/home/presentation/widgets/home_shell.dart',
      ),
      CommonTemplates.homeShell('../../../../'),
    );

    await _writeFile(
      path.join(libPath, 'sessions/user_session.dart'),
      CommonTemplates.userSessionsBloc(),
    );
    await _writeFile(
      path.join(libPath, 'theme/text_style.dart'),
      CommonTemplates.textStyleHelperBloc(),
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
      switch (config.stateManagement) {
        StateManagement.getx => CommonTemplates.baseConnectionGetX(),
        StateManagement.riverpod => CommonTemplates.baseConnectionRiverpod(),
        StateManagement.provider => CommonTemplates.baseConnectionProvider(),
        StateManagement.bloc => CommonTemplates.baseConnectionBloc(),
      },
    );

    // Config
    await _writeFile(
      path.join(libPath, 'core/config/env_config.dart'),
      CommonTemplates.envConfig(),
    );

    await _writeFile(
      path.join(libPath, 'core/config/session_storage_keys.dart'),
      CommonTemplates.sessionStorageKeysFile(config.sessionStorageKeys),
    );

    if (config.useSecretKey) {
      await _writeFile(
        path.join(libPath, 'core/config/get_env.dart'),
        CommonTemplates.getEnv(),
      );
      await _writeFile(
        path.join(libPath, 'core/config/cryptic.dart'),
        CommonTemplates.cryptic(),
      );
    } else {
      await _writeFile(
        path.join(libPath, 'core/config/get_env.dart'),
        CommonTemplates.getEnvSimple(),
      );
    }

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
      switch (config.stateManagement) {
        StateManagement.getx => CommonTemplates.appWidgetGetX(config),
        StateManagement.riverpod => CommonTemplates.appWidgetRiverpod(config),
        StateManagement.provider => CommonTemplates.appWidgetProvider(config),
        StateManagement.bloc => CommonTemplates.appWidgetBloc(config),
      },
    );
  }
}
