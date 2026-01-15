/// XProject Generator - GetX Templates
///
/// Provides static methods to generate Dart code templates for GetX routing and page configuration.
/// Used by the file and structure generators for GetX-based projects.
///
/// See README.md for more details.
class GetXTemplates {
  static String appRoutes() {
    return '''
abstract class Routes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
}
''';
  }

  /// Returns the Dart code for the AppPages class (GetX route configuration).
  static String appPages() {
    return '''
import 'package:get/get.dart';

import '../features/login/bindings/login_binding.dart';
import '../features/login/views/login_view.dart';
import '../features/home/bindings/home_binding.dart';
import '../features/home/views/home_view.dart';
import '../features/splash/views/splash_view.dart';
import '../features/splash/bindings/splash_binding.dart';

import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
  ];
}
''';
  }
}
