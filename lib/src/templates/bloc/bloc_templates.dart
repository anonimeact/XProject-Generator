/// XProject Generator - Bloc Templates
///
/// Provides static methods to generate Dart code templates for Bloc routes and router configuration.
/// Used by the file and structure generators for Bloc-based projects.
class BlocTemplates {
  static String routes() {
    return '''
abstract class Routes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
}
''';
  }

  static String appRouter() {
    return '''
import 'package:dio_extended/diox.dart';
import 'package:go_router/go_router.dart';
import 'package:xwidgets_pack/xwidgets.dart';

import '../features/home/presentation/views/home_view.dart';
import '../features/login/presentation/views/login_view.dart';
import '../features/splash/presentation/views/splash_view.dart';
import 'routes.dart';

final GoRouter appRouter = GoRouter(
  navigatorKey: XSnackbar.navigatorKey,
  initialLocation: Routes.splash,
  observers: [
    ShakeChuckerConfigs.navigatorObserver,
  ],
  routes: [
    GoRoute(
      path: Routes.splash,
      builder: (_, __) => const SplashView(),
    ),
    GoRoute(
      path: Routes.login,
      builder: (_, __) => const LoginView(),
    ),
    GoRoute(
      path: Routes.home,
      builder: (_, __) => const HomeView(),
    ),
  ],
);
''';
  }
}
