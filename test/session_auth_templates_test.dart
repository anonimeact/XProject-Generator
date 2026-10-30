import 'package:test/test.dart';
import 'package:xproject_generator/core/configs/project_config.dart';
import 'package:xproject_generator/src/templates/bloc/bloc_feature_template.dart';
import 'package:xproject_generator/src/templates/common_templates.dart';
import 'package:xproject_generator/src/templates/getx/getx_feature_template.dart';
import 'package:xproject_generator/src/templates/provider/provider_feature_template.dart';
import 'package:xproject_generator/src/templates/riverpod/riverpod_feature_template.dart';

void main() {
  group('session auth templates', () {
    test('all stacks persist session and route splash by hasActiveSession', () {
      for (final source in [
        GetxFeatureTemplate.splashController(
          ProjectConfig(
            appName: 'a',
            displayName: 'A',
            androidPackage: 'com.example.a',
            iosBundleId: 'com.example.a',
            stateManagement: StateManagement.getx,
            useFirebase: false,
            useSecretKey: false,
          ),
        ),
        ProviderFeatureTemplate.splashView(),
        BlocFeatureTemplate.splashView(),
        RiverpodFeatureTemplate.splashView(),
      ]) {
        expect(source, contains('UserSessions.hasActiveSession()'));
        expect(source, contains('Routes.home'));
        expect(source, contains('Routes.login'));
      }
    });

    test('all stacks call openSession on login', () {
      expect(
        GetxFeatureTemplate.loginController(),
        contains('UserSessions.openSession'),
      );
      expect(
        BlocFeatureTemplate.loginBlocSimple(),
        contains('UserSessions.openSession'),
      );
      expect(
        ProviderFeatureTemplate.loginNotifier(),
        contains('UserSessions.openSession'),
      );
      expect(
        RiverpodFeatureTemplate.loginProvider(),
        contains('UserSessions.openSession'),
      );
    });

    test('provider splash routes only once', () {
      final splash = ProviderFeatureTemplate.splashView();
      expect(splash, contains('_didRoute'));
      expect(splash, contains('State<SplashView>'));
    });

    test('riverpod splash routes only once', () {
      final splash = RiverpodFeatureTemplate.splashView();
      expect(splash, contains('_didRoute'));
      expect(splash, contains('ConsumerState<SplashView>'));
    });

    test('getx splash avoids duplicate navigation', () {
      final controller = GetxFeatureTemplate.splashController(
        ProjectConfig(
          appName: 'a',
          displayName: 'A',
          androidPackage: 'com.example.a',
          iosBundleId: 'com.example.a',
          stateManagement: StateManagement.getx,
          useFirebase: false,
          useSecretKey: false,
        ),
      );
      expect(controller, contains('_didNavigate'));
    });

    test('bloc splash listener fires only on finish transition', () {
      final splash = BlocFeatureTemplate.splashView();
      expect(splash, contains('!previous.isFinished && current.isFinished'));
    });

    test('persist login validates phone in all stacks', () {
      final block = CommonTemplates.persistLoginSessionBlock(
        phoneExpression: 'phone',
        connectionExpression: 'connection',
      );
      expect(block, contains('sessionPhone.isEmpty'));
      expect(block, contains("StateError('Phone number is required.')"));
    });

    test('demo login bypass documents API setup for generated apps', () {
      final demo = CommonTemplates.demoLoginBypassBlock(
        phoneExpression: 'phone',
        connectionExpression: 'connection',
      );
      expect(demo, contains('DEMO LOGIN (no HTTP)'));
      expect(demo, contains('EnvConfig.apiBaseUrl'));
      expect(demo, contains('placeholder'));
      expect(demo, contains('REAL API'));
    });

    test('riverpod login avoids duplicate navigation', () {
      final login = RiverpodFeatureTemplate.loginView();
      expect(login, contains('_handledSuccess'));
    });

    test('provider login avoids duplicate navigation', () {
      final login = ProviderFeatureTemplate.loginView();
      expect(login, contains('_handledSuccess'));
      expect(login, contains('_lastErrorMessage'));
    });

    test('bloc simple login listener uses listenWhen', () {
      expect(
        BlocFeatureTemplate.loginViewSimple(),
        contains('listenWhen:'),
      );
    });

    test('logout clears session and uses login route', () {
      expect(
        GetxFeatureTemplate.homeController(),
        contains('Get.offAllNamed(Routes.login)'),
      );
      expect(
        CommonTemplates.goRouterLogoutBody(
          connectionExpression: 'BaseConnection()',
        ),
        contains('UserSessions.clearSession()'),
      );
      expect(
        CommonTemplates.goRouterLogoutBody(
          connectionExpression: 'BaseConnection()',
        ),
        contains('context.go(Routes.login)'),
      );
    });

    test('UserSessions uses string session flag and init guard', () {
      final body = CommonTemplates.userSessionsBloc();
      expect(body, contains("value: '1'"));
      expect(body, contains('StorageHelper.isInitialized()'));
      expect(body, contains('catch (_)'));
    });

    test('home shell uses logout icon and callback', () {
      final shell = CommonTemplates.homeShell('../../../../');
      expect(shell, contains('onLogout'));
      expect(shell, contains('Icons.logout_rounded'));
    });
  });
}
