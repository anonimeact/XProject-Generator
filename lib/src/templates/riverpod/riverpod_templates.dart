/// XProject Generator - Riverpod Templates
///
/// Provides static methods to generate Dart code templates for Riverpod theme, locale, routes, and router configuration.
/// Used by the file and structure generators for Riverpod-based projects.
///
/// See README.md for more details.
class RiverpodTemplates {
  static String themeProvider() {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  void set(ThemeMode mode) {
    state = mode;
  }
}

final themeModeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);
''';
  }

  static String localeProvider() {
    return '''
      /// Returns the Dart code for the localeProvider.
import 'dart:ui';
import 'package:flutter_riverpod/legacy.dart';

final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));
''';
  }

  static String routes() {
    return '''
      /// Returns the Dart code for the Routes class (route names).
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
    ShakeChuckerConfigs.navigatorObserver
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
