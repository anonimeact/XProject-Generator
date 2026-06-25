import '../../core/configs/project_config.dart';

/// XProject Generator - Common Templates
///
/// Provides static methods to generate common Dart code templates for themes, environment, localization,
/// app widgets, Firebase, user sessions, and more. Used by both GetX and Riverpod project structures.
///
/// See README.md for more details.
class CommonTemplates {
  static String additionalFontSetting() {
    return '''
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.otf
        - asset: assets/fonts/Inter-Medium.otf
          weight: 500
        - asset: assets/fonts/Inter-SemiBold.otf
          weight: 600
        - asset: assets/fonts/Inter-Bold.otf
          weight: 700''';
  }

  /// Color list
  static String appColors() {
    return '''
import 'package:flutter/material.dart';

class AppColor {
  static const primary = Color(0xFF007FFF);
  static const primaryLight = Color(0xFFE3F2FD);
  static const primaryDark = Color(0xFF005BB5);
  
  static const secondary = Color(0xFF00B7EB);
  static const accent = Color(0xFFFF7F50);
  
  static const bgLight = Color(0xFFF8FBFF);
  static const bgDark = Color(0xFF0A192F);
  static const surface = Color(0xFFFFFFFF);
  
  static const title = Color(0xFF1A202C);
  static const body = Color(0xFF4A5568);
  static const subtitle = Color(0xFF718096);
  
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  
  static const border = Color(0xFFE2E8F0);
  static const inactive = Color(0xFFCBD5E0);
  static const divider = Color(0xFFEDF2F7);

  static const inputFill = Color(0xFFF1F5F9);
  static const onPrimary = Color(0xFFFFFFFF);
}
''';
  }

  /// Returns the Dart code for the AppTheme class (light and dark themes).
  static String appTheme() {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_color.dart';

class AppTheme {
  static const _lightScheme = ColorScheme.light(
    primary: AppColor.primary,
    onPrimary: AppColor.onPrimary,
    secondary: AppColor.secondary,
    onSecondary: AppColor.onPrimary,
    surface: AppColor.surface,
    onSurface: AppColor.title,
    error: AppColor.error,
    onError: AppColor.onPrimary,
  );

  static const _darkScheme = ColorScheme.dark(
    primary: AppColor.primary,
    onPrimary: AppColor.onPrimary,
    secondary: AppColor.secondary,
    surface: Color(0xFF1E293B),
    onSurface: Color(0xFFF1F5F9),
    error: AppColor.error,
    onError: AppColor.onPrimary,
  );

  static InputDecorationTheme _inputTheme({required bool isDark}) {
    return InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF334155) : AppColor.inputFill,
      hintStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : AppColor.subtitle),
      labelStyle: TextStyle(color: isDark ? const Color(0xFFCBD5E1) : AppColor.body, fontSize: 13),
      prefixIconColor: AppColor.primary,
      suffixIconColor: isDark ? const Color(0xFF94A3B8) : AppColor.subtitle,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: isDark ? const Color(0xFF475569) : AppColor.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColor.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColor.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColor.error, width: 1.5),
      ),
    );
  }

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _lightScheme,
      scaffoldBackgroundColor: AppColor.bgLight,
      inputDecorationTheme: _inputTheme(isDark: false),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColor.primary,
        selectionColor: AppColor.primaryLight,
        selectionHandleColor: AppColor.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primary,
          foregroundColor: AppColor.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textTheme: const TextTheme(
        labelLarge: TextStyle(
          color: AppColor.title,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter'
        ),
        titleLarge: TextStyle(
          color: AppColor.title,
          fontSize: 14,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600
        ),
        titleMedium: TextStyle(
          color: AppColor.title,
          fontSize: 14,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500
        ),
        titleSmall: TextStyle(
          color: AppColor.title,
          fontSize: 12,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400
        )
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: AppColor.bgLight,
        foregroundColor: AppColor.title,
        scrolledUnderElevation: 0,
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColor.title,
          fontSize: 16,
          fontFamily: 'Inter',
        ),
        iconTheme: const IconThemeData(color: AppColor.title),
        elevation: 0,
        actionsIconTheme: const IconThemeData(color: AppColor.title),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: AppColor.primary,
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _darkScheme,
      scaffoldBackgroundColor: AppColor.bgDark,
      inputDecorationTheme: _inputTheme(isDark: true),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColor.primary,
        selectionColor: AppColor.primaryDark,
        selectionHandleColor: AppColor.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primary,
          foregroundColor: AppColor.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textTheme: const TextTheme(
        labelLarge: TextStyle(
          color: Color(0xFFE2E8F0),
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter',
        ),
        titleLarge: TextStyle(
          color: Color(0xFFF1F5F9),
          fontSize: 14,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: Color(0xFFE2E8F0),
          fontSize: 14,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: Color(0xFFCBD5E1),
          fontSize: 12,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: AppColor.bgDark,
        foregroundColor: Color(0xFFF1F5F9),
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFFF1F5F9),
          fontSize: 16,
          fontFamily: 'Inter',
        ),
        iconTheme: IconThemeData(color: Color(0xFFF1F5F9)),
        elevation: 0,
        actionsIconTheme: IconThemeData(color: Color(0xFFF1F5F9)),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        indicatorColor: AppColor.primary,
      ),
    );
  }
}
''';
  }

  /// Shared auth page shell — light layout with wave header and card form.
  ///
  /// [libPrefix] is the relative path from the widget's folder back to `lib/`
  /// (e.g. `../../../` for GetX, `../../../../` for Riverpod/Bloc).
  static String authScaffold(String libPrefix) {
    return '''
import 'package:flutter/material.dart';

import '${libPrefix}theme/app_color.dart';
import '${libPrefix}theme/app_theme.dart';

class AuthWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 48);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height + 16,
      size.width,
      size.height - 48,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Light auth layout with gradient wave header and floating form card.
/// Always uses [AppTheme.lightTheme] so fields stay readable regardless of device theme.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.hint,
  });

  final String title;
  final String subtitle;
  final String? hint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme(),
      child: Scaffold(
        backgroundColor: AppColor.bgLight,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              children: [
                ClipPath(
                  clipper: AuthWaveClipper(),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColor.primary, AppColor.secondary],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_outline_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -28),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                      decoration: BoxDecoration(
                        color: AppColor.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.primary.withValues(alpha: 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: AppColor.title,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 36,
                            height: 3,
                            decoration: BoxDecoration(
                              color: AppColor.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          if (hint != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              hint!,
                              style: const TextStyle(
                                color: AppColor.subtitle,
                                fontSize: 14,
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          child,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AuthDecorations {
  static InputDecoration field({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      suffixIcon: suffixIcon,
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
      ),
    );
  }
}
''';
  }

  /// Shared home page shell with gradient header and quick-action cards.
  ///
  /// [libPrefix] is the relative path from the widget's folder back to `lib/`
  /// (e.g. `../../../` for GetX, `../../../../` for Riverpod/Bloc).
  static String homeShell(String libPrefix) {
    return '''
import 'package:flutter/material.dart';

import '${libPrefix}theme/app_color.dart';
import '${libPrefix}core/l10n/string_resources.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({
    super.key,
    required this.onToggleTheme,
    required this.onToggleLanguage,
  });

  final VoidCallback onToggleTheme;
  final VoidCallback onToggleLanguage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding: const EdgeInsets.fromLTRB(20, 20, 12, 28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColor.primary, AppColor.secondary],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primary.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            R.string.homeView,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: onToggleTheme,
                          icon: const Icon(Icons.brightness_6_outlined, color: Colors.white),
                        ),
                        IconButton(
                          onPressed: onToggleLanguage,
                          icon: const Icon(Icons.language_outlined, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      R.string.homeWelcome,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      R.string.homeSubtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.15,
                ),
                delegate: SliverChildListDelegate([
                  _HomeActionCard(
                    icon: Icons.explore_outlined,
                    label: R.string.homeExplore,
                    color: AppColor.primary,
                  ),
                  _HomeActionCard(
                    icon: Icons.notifications_outlined,
                    label: R.string.homeNotifications,
                    color: AppColor.secondary,
                  ),
                  _HomeActionCard(
                    icon: Icons.person_outline_rounded,
                    label: R.string.homeProfile,
                    color: AppColor.accent,
                  ),
                  _HomeActionCard(
                    icon: Icons.settings_outlined,
                    label: R.string.homeSettings,
                    color: AppColor.primaryDark,
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  const _HomeActionCard({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
''';
  }

  /// Returns the Dart code for the GetEnv class, which handles environment variable decryption and loading.
  static String getEnv() {
    return '''
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:secure_compressor/secure_compressor.dart';

import 'cryptic.dart';

/// Create this class manually to store your secret keys
/// use secret_key_scrypt_generator to generate the class
import 'secretkey.dart';

class GetEnv {
  static String _directoryPath = '';

  static Future<void> initialize(String env) async {
    final keys = Cryptic.generateKeys();

    final encryptedAsset = await rootBundle.loadString('.env.\$env');

    /// Decrypt with env key
    /// Use the unix key from SecretKey to decrypt the encrypted asset
    /// You can change this line / logic if needed
    final envKey = SecretKey.unixKey();

    final decrypted = SecureCompressor.decrypt(encryptedAsset, envKey.substring(0, 32));

    final rebuilt = decrypted.replaceAll('\\n', '##');

    final encData = SecureCompressor.encrypt(rebuilt, keys.key, ivString: keys.ivKey);

    final dir = await getApplicationDocumentsDirectory();
    _directoryPath = dir.path;

    await SecureCompressor.saveDataToLocal('.env.\$env', encData);
  }

  static String get(String key, String env) {
    final keys = Cryptic.generateKeys();
    final file = File('\$_directoryPath/.env.\$env');

    if (!file.existsSync()) return '';

    final decrypted = SecureCompressor.decrypt(file.readAsStringSync(), keys.key, ivString: keys.ivKey);

    final json = jsonDecode(_toJson(decrypted.split('##')));

    return json[key] ?? '';
  }

  static String _toJson(List<String> lines) {
    final Map<String, dynamic> map = {};

    for (final line in lines) {
      final parts = line.split('=');
      if (parts.length != 2) continue;

      final key = parts[0].trim();
      final value = parts[1].trim();

      map[key] = value.toLowerCase() == 'true'
          ? true
          : value.toLowerCase() == 'false'
          ? false
          : value;
    }

    return jsonEncode(map);
  }
}
''';
  }

  /// Returns the Dart code for a simplified GetEnv class (no secret key / no encryption).
  /// Used when the project is created without the secret_key_scrypt_generator package.
  static String getEnvSimple() {
    return '''
import 'package:flutter/services.dart';

class GetEnv {
  static final Map<String, Map<String, dynamic>> _cache = {};

  static Future<void> initialize(String env) async {
    final content = await rootBundle.loadString('.env.\$env');
    _cache[env] = _parse(content);
  }

  static String get(String key, String env) {
    return _cache[env]?[key]?.toString() ?? '';
  }

  static Map<String, dynamic> _parse(String content) {
    final Map<String, dynamic> map = {};
    for (final line in content.split('\\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      final index = trimmed.indexOf('=');
      if (index == -1) continue;
      final key = trimmed.substring(0, index).trim();
      final value = trimmed.substring(index + 1).trim();
      map[key] = value.toLowerCase() == 'true'
          ? true
          : value.toLowerCase() == 'false'
          ? false
          : value;
    }
    return map;
  }
}
''';
  }

  /// Returns the Dart code for the EnvConfig class, which loads and provides environment variables.
  static String envConfig() {
    return '''
import 'get_env.dart';

class EnvConfig {
  static late String _env;

  static Future<void> load(String env) async {
    _env = env;
    await GetEnv.initialize(env);
  }

  /// Modify bellow getters to add your own environment variables
  static String get apiBaseUrl =>
      GetEnv.get('BASE_URL', _env);
}
''';
  }

  /// Returns the Dart code for the Cryptic class, which generates encryption keys for secure storage.
  static String cryptic() {
    return '''
import 'package:secure_compressor/secure_compressor.dart';

import 'secretkey.dart';

class Cryptic {
  static ({String key, String ivKey}) generateKeys({String? unixKey, String? appSeed}) {
    
    /// Decrypt with env key
    /// Use the unix key from SecretKey to decrypt the encrypted asset
    /// You can change this line / logic if needed
    final resolvedUnixKey = (unixKey ?? SecretKey.unixKey()).trim();
    final resolvedSeed = (appSeed ?? SecretKey.unixKey()).trim();

    final base =
        ('\$resolvedUnixKey\$resolvedSeed'
                '\${resolvedUnixKey.hashCode}'
                '\${resolvedSeed.hashCode}')
            .padRight(64, '0');

    // Final 32 chars key
    final key = SecureCompressor.encrypt(resolvedSeed, base.substring(0, 32)).substring(0, 32);

    final ivKey = key.split('').reversed.join('').substring(0, 16);

    return (key: key, ivKey: ivKey);
  }
}

''';
  }

  /// Returns the Dart code for the main App widget for GetX projects.
  static String appWidgetGetX(ProjectConfig config) {
    return '''
import 'package:dio_extended/diox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:secure_compressor/secure_compressor.dart';
import 'package:xwidgets_pack/xwidgets.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';
import 'core/l10n/string_resources.dart';
import 'core/l10n/generated/app_localizations.dart';
import 'core/config/env_config.dart';
import 'core/services/base_connection.dart';
${config.useSecretKey ? "import 'core/config/secretkey.dart';" : ''}

enum Environment { development, staging, production }

/// Permanent controller that owns app-wide state: theme + locale.
/// Uses Get.changeThemeMode / Get.updateLocale so GetMaterialController
/// (which is the source of truth for GetMaterialApp) is always updated.
class AppController extends GetxController {
  static AppController get to => Get.find<AppController>();

  bool _isDark = false;

  void toggleTheme() {
    _isDark = !_isDark;
    Get.changeThemeMode(_isDark ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleLanguage() {
    final next = Get.locale?.languageCode == 'en'
        ? const Locale('id')
        : const Locale('en');
    Get.updateLocale(next);
  }
}

class App extends StatelessWidget {
  const App({super.key, required this.env});

  final Environment env;

  @override
  Widget build(BuildContext context) {
    return ShakeForChucker(
      forceHideChucker: env.name == 'production',
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: '${config.appDisplayName}',
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.light,
        navigatorKey: XSnackbar.navigatorKey,
        initialRoute: Routes.splash,
        getPages: AppPages.routes,
        navigatorObservers: [ShakeChuckerConfigs.navigatorObserver],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: const Locale('en'),
        fallbackLocale: const Locale('en'),
        supportedLocales: const [Locale('en'), Locale('id')],
        builder: (context, child) {
          R.init(context);
          return child!;
        },
      ),
    );
  }
}

/// Call this method during app initialization in each main_*.dart file
/// to setup base services like StorageHelper, etc.
/// For other initializations, please do that inside
/// splash screen or relevant places
/// to avoid blank screen on app start in iOS
Future<void> initApp(Environment env) async {
  /// Initialized main base services here
  /// For other initializations, please do that inside
  /// splash screen or relevant places
  /// to avoid blank screen on app start in iOS
  
  ShakeChuckerConfigs.initialize(showOnRelease: env != .production, showNotification: false);

  /// Initialize secure storage first — required before any StorageHelper usage
  await StorageHelper.initialize('${config.appName}', isEncryptKeyAndValue: ${config.useSecretKey});

  /// Load environment configuration
  await EnvConfig.load(env.name);

  /// Register app-wide state controller (theme + locale) permanently
  Get.put<AppController>(AppController(), permanent: true);

  /// Register shared API connection (single instance for the app lifecycle)
  Get.put<BaseConnection>(BaseConnection(), permanent: true);
}
''';
  }

  /// Returns the Dart code for the main App widget for Riverpod projects.
  static String appWidgetRiverpod(ProjectConfig config) {
    return '''
import 'package:dio_extended/diox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:secure_compressor/secure_compressor.dart';
import 'core/l10n/string_resources.dart';
import 'core/config/env_config.dart';
import 'core/l10n/generated/app_localizations.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'core/l10n/locale_provider.dart';
${config.useSecretKey ? "import 'core/config/secretkey.dart';" : ''}

enum Environment { development, staging, production }

class App extends ConsumerWidget {
  const App({super.key, required this.env});

  final Environment env;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: '${config.appDisplayName}',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode,
      routerConfig: appRouter,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('id')],
      builder: (context, child) {
        R.init(context);
        return child!;
      },
    );
  }
}

/// Call this method during app initialization in each main_*.dart file
/// to setup base services like StorageHelper, etc.
/// For other initializations, please do that inside
/// splash screen or relevant places
/// to avoid blank screen on app start in iOS
Future<void> initApp(Environment env) async {
  /// Initialized main base services here
  /// For other initializations, please do that inside
  /// splash screen or relevant places
  /// to avoid blank screen on app start in iOS
  
  ShakeChuckerConfigs.initialize(showOnRelease: env != .production, showNotification: false);

  /// Initialize secure storage first — required before any StorageHelper usage
  await StorageHelper.initialize('${config.appName}', isEncryptKeyAndValue: ${config.useSecretKey});

  /// Load environment configuration
  await EnvConfig.load(env.name);
}
''';
  }

  /// Returns the Dart code for the main App widget for Bloc projects.
  static String appWidgetBloc(ProjectConfig config) {
    return '''
import 'package:dio_extended/diox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:secure_compressor/secure_compressor.dart';
import 'core/l10n/string_resources.dart';
import 'core/config/env_config.dart';
import 'core/l10n/generated/app_localizations.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';
${config.useSecretKey ? "import 'core/config/secretkey.dart';" : ''}

enum Environment { development, staging, production }

/// App-wide state: theme mode + locale.
class AppState {
  const AppState({required this.themeMode, required this.locale});

  final ThemeMode themeMode;
  final Locale locale;

  AppState copyWith({ThemeMode? themeMode, Locale? locale}) {
    return AppState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}

/// Owns app-wide theme + locale so any page can toggle them via
/// context.read<AppCubit>().
class AppCubit extends Cubit<AppState> {
  AppCubit()
      : super(const AppState(themeMode: ThemeMode.light, locale: Locale('en')));

  void toggleTheme() {
    emit(state.copyWith(
      themeMode:
          state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    ));
  }

  void toggleLanguage() {
    emit(state.copyWith(
      locale: state.locale.languageCode == 'en'
          ? const Locale('id')
          : const Locale('en'),
    ));
  }
}

class App extends StatelessWidget {
  const App({super.key, required this.env});

  final Environment env;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppCubit(),
      child: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: '${config.appDisplayName}',
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: state.themeMode,
            routerConfig: appRouter,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            locale: state.locale,
            supportedLocales: const [Locale('en'), Locale('id')],
            builder: (context, child) {
              R.init(context);
              return child!;
            },
          );
        },
      ),
    );
  }
}

/// Call this method during app initialization in each main_*.dart file
/// to setup base services like StorageHelper, etc.
/// For other initializations, please do that inside
/// splash screen or relevant places
/// to avoid blank screen on app start in iOS
Future<void> initApp(Environment env) async {
  /// Initialized main base services here
  /// For other initializations, please do that inside
  /// splash screen or relevant places
  /// to avoid blank screen on app start in iOS
  
  ShakeChuckerConfigs.initialize(showOnRelease: env != .production, showNotification: false);

  /// Initialize secure storage first — required before any StorageHelper usage
  await StorageHelper.initialize('${config.appName}', isEncryptKeyAndValue: ${config.useSecretKey});

  /// Load environment configuration
  await EnvConfig.load(env.name);
}
''';
  }

  /// Returns the Dart code for the main entry file (main_*.dart) for a given [environment].
  static String mainFile(ProjectConfig config, String environment) {
    final isRiverpod = config.stateManagement == StateManagement.riverpod;

    return '''
import 'package:flutter/material.dart';
${isRiverpod ? "import 'package:flutter_riverpod/flutter_riverpod.dart';" : ''}
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final env = Environment.$environment;
  // Load environment configuration
  await initApp(env);

  runApp(${isRiverpod ? 'ProviderScope(child: App(env: env))' : 'App(env: env)'});
}
''';
  }

  /// Returns the content for the ios/firebase.sh script for Firebase flavor support.
  static String firebaseSh() {
    return '''
environment="default"

# Regex to extract the scheme name from the Build Configuration
# We have named our Build Configurations as Debug-dev, Debug-prod etc.
# Here, dev and prod are the scheme names. This kind of naming is required by Flutter for flavors to work.
# We are using the \$CONFIGURATION variable available in the XCode build environment to extract 
# the environment (or flavor)
# For eg.
# If CONFIGURATION="Debug-prod", then environment will get set to "prod".
if [[ \$CONFIGURATION =~ -([^-]*\$ ]]; then
environment=\${BASH_REMATCH[1]}
fi

echo \$environment

# Name and path of the resource we're copying
GOOGLESERVICE_INFO_PLIST=GoogleService-Info.plist
GOOGLESERVICE_INFO_FILE=\${PROJECT_DIR}/config/\${environment}/\${GOOGLESERVICE_INFO_PLIST}

# Make sure GoogleService-Info.plist exists
echo "Looking for \${GOOGLESERVICE_INFO_PLIST} in \${GOOGLESERVICE_INFO_FILE}"
if [ ! -f \$GOOGLESERVICE_INFO_FILE ]
then
echo "No GoogleService-Info.plist found. Please ensure it's in the proper directory."
exit 1
fi

# Get a reference to the destination location for the GoogleService-Info.plist
# This is the default location where Firebase init code expects to find GoogleServices-Info.plist file
PLIST_DESTINATION=\${BUILT_PRODUCTS_DIR}/\${PRODUCT_NAME}.app
echo "Will copy \${GOOGLESERVICE_INFO_PLIST} to final destination: \${PLIST_DESTINATION}"

# Copy over the prod GoogleService-Info.plist for Release builds
cp "\${GOOGLESERVICE_INFO_FILE}" "\${PLIST_DESTINATION}"
''';
  }

  /// Returns the Dart code for the BaseConnection class, which extends DioExtended for API calls.
  static String baseConnectionGetX() {
    return '''
import 'package:dio_extended/diox.dart';
import 'package:get/get.dart';

import '../../sessions/user_session.dart';
import '../config/env_config.dart';

class BaseConnection extends DioExtended {
  BaseConnection()
    : super(
        baseUrl: EnvConfig.apiBaseUrl,
        headers: _buildAuthHeaders(),
        tokenExpiredCode: 402,
        /// If your token source is async (e.g. fetched from a remote call),
        /// replace [headers] with [headersAsync] and make _buildAuthHeaders async:
        // headersAsync: _buildAuthHeaders(),
      );

  @override
  Future<dynamic> handleTokenExpired() async {
    /// TODO: call refresh endpoint, save new token to UserSessions
    final newHeaders = _buildAuthHeaders();
    if (Get.isRegistered<BaseConnection>()) {
      Get.delete<BaseConnection>(force: true);
      Get.put<BaseConnection>(BaseConnection(), permanent: true);
    }
    return newHeaders;
  }

  static Map<String, String> _buildAuthHeaders() {
    final token = UserSessions.getToken() ?? '';
    return {'token': 'Bearer \$token'};
  }
}
''';
  }

  static String baseConnectionRiverpod() {
    return '''
import 'package:dio_extended/diox.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../sessions/user_session.dart';
import '../config/env_config.dart';

part 'base_connection.g.dart';

@riverpod
BaseConnection baseConnection(Ref ref) {
  return BaseConnection.create();
}

class BaseConnection extends DioExtended {
  BaseConnection._internal(Map<String, String> headers)
    : super(
        baseUrl: EnvConfig.apiBaseUrl,
        headers: headers,
        tokenExpiredCode: 402,
        /// If your token source is async (e.g. fetched from a remote call),
        /// replace [headers] with [headersAsync] and make _buildAuthHeaders async:
        // headersAsync: _buildAuthHeadersAsync(),
      );

  static BaseConnection create() {
    return BaseConnection._internal(_buildAuthHeaders());
  }

  /// Called automatically by DioExtended when the server returns tokenExpiredCode (402).
  /// Fetch and save the new token here, then return the updated auth headers.
  /// DioExtended will retry the original request with these new headers.
  @override
  Future<dynamic> handleTokenExpired() async {
    /// TODO: call your refresh-token endpoint and save the result to UserSessions
    return _buildAuthHeaders();
  }

  static Map<String, String> _buildAuthHeaders() {
    final token = UserSessions.getToken() ?? '';
    return {'token': 'Bearer \$token'};
  }
}
''';
  }

  static String baseConnectionBloc() {
    return '''
import 'package:dio_extended/diox.dart';

import '../../sessions/user_session.dart';
import '../config/env_config.dart';

class BaseConnection extends DioExtended {
  BaseConnection._internal()
    : super(
        baseUrl: EnvConfig.apiBaseUrl,
        headers: _buildAuthHeaders(),
        tokenExpiredCode: 402,
        /// If your token source is async (e.g. fetched from a remote call),
        /// replace [headers] with [headersAsync] and make _buildAuthHeaders async:
        // headersAsync: _buildAuthHeadersAsync(),
      );

  static BaseConnection? _instance;
  factory BaseConnection() => _instance ??= BaseConnection._internal();

  /// Call this after an external token refresh to force a new instance
  /// for the next consumer (e.g. after login, after token rotation).
  static void reset() => _instance = null;

  @override
  Future<dynamic> handleTokenExpired() async {
    /// TODO: call refresh endpoint, save new token to UserSessions
    reset();
    return _buildAuthHeaders();
  }

  static Map<String, String> _buildAuthHeaders() {
    final token = UserSessions.getToken() ?? '';
    return {'token': 'Bearer \$token'};
  }
}
''';
  }

  /// Returns the Dart code for the UserSessions class for GetX projects.
  static String userSessionsGetx() {
    return '''
import 'dart:convert';

import 'package:secure_compressor/secure_compressor.dart';

import '../features/login/models/user_model.dart';

class UserSessions {
  // Singleton instance
  static final UserSessions _instance = UserSessions._internal();

  // Private constructor
  UserSessions._internal();

  // Factory constructor to return the singleton instance
  factory UserSessions() => _instance;

  static const String dataUserKey = 'dataUserKey';
  static const String dataTokenKey = 'dataTokenKey';

  static void saveUserData({UserModel? userData, dynamic userDataMap}) {
    if (userData == null && userDataMap == null) return;
    final dataUserString = userData != null ? jsonEncode(userData.toJson()) : userDataMap.toString();
    StorageHelper.saveString(key: dataUserKey, value: dataUserString);
  }

  static UserModel? getUserData() {
    final dataUserString = StorageHelper.getString(key: dataUserKey);
    if (dataUserString == null) {
      return null;
    }
    return UserModel.fromJson(jsonDecode(dataUserString));
  }

  static void saveToken(String token) {
    StorageHelper.saveString(key: dataTokenKey, value: token);
  }
  static String? getToken() {
    return StorageHelper.getString(key: dataTokenKey);
  }
  
  static void deletUserData(){
    StorageHelper.clear();
  }
}

''';
  }

  /// Returns the Dart code for the UserSessions class for Riverpod projects.
  static String userSessionsRiverpod() {
    return '''
import 'dart:convert';

import 'package:secure_compressor/secure_compressor.dart';

import '../../features/login/data/models/user_model.dart';

class UserSessions {
  // Singleton instance
  static final UserSessions _instance = UserSessions._internal();

  // Private constructor
  UserSessions._internal();

  // Factory constructor to return the singleton instance
  factory UserSessions() => _instance;

  static const String dataUserKey = 'dataUserKey';
  static const String dataTokenKey = 'dataTokenKey';

  static void saveUserData({UserModel? userData, dynamic userDataMap}) {
    if (userData == null && userDataMap == null) return;
    final dataUserString = userData != null ? jsonEncode(userData.toJson()) : userDataMap.toString();
    StorageHelper.saveString(key: dataUserKey, value: dataUserString);
  }

  static UserModel? getUserData() {
    final dataUserString = StorageHelper.getString(key: dataUserKey);
    if (dataUserString == null) {
      return null;
    }
    return UserModel.fromJson(jsonDecode(dataUserString));
  }

  static void saveToken(String token) {
    StorageHelper.saveString(key: dataTokenKey, value: token);
  }
  static String? getToken() {
    return StorageHelper.getString(key: dataTokenKey);
  }
  

  static void deletUserData(){
    StorageHelper.clear();
  }
}
''';
  }

  /// Returns the Dart code for the UserSessions class for Bloc projects.
  static String userSessionsBloc() {
    return '''
import 'dart:convert';

import 'package:secure_compressor/secure_compressor.dart';

import '../features/login/data/models/user_model.dart';

class UserSessions {
  // Singleton instance
  static final UserSessions _instance = UserSessions._internal();

  // Private constructor
  UserSessions._internal();

  // Factory constructor to return the singleton instance
  factory UserSessions() => _instance;

  static const String dataUserKey = 'dataUserKey';
  static const String dataTokenKey = 'dataTokenKey';

  static void saveUserData({UserModel? userData, dynamic userDataMap}) {
    if (userData == null && userDataMap == null) return;
    final dataUserString = userData != null ? jsonEncode(userData.toJson()) : userDataMap.toString();
    StorageHelper.saveString(key: dataUserKey, value: dataUserString);
  }

  static UserModel? getUserData() {
    final dataUserString = StorageHelper.getString(key: dataUserKey);
    if (dataUserString == null) {
      return null;
    }
    return UserModel.fromJson(jsonDecode(dataUserString));
  }

  static void saveToken(String token) {
    StorageHelper.saveString(key: dataTokenKey, value: token);
  }
  static String? getToken() {
    return StorageHelper.getString(key: dataTokenKey);
  }

  static void deletUserData(){
    StorageHelper.clear();
  }
}
''';
  }

  /// TextStyle helper
  static String textStyleHelperGetx() {
    return '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_color.dart';

TextStyle styleLarge({double? size = 14, Color? color, FontWeight? weight}) {
  return Theme.of(Get.context!).textTheme.titleLarge!.copyWith(
      fontSize: Get.width > 500 ? size! * 1.4 : size,
      fontWeight: weight ?? FontWeight.bold,
      color:
          color ?? (Get.isDarkMode ? AppColor.bgLight : AppColor.title));
}

TextStyle styleMedium({double? size = 14, Color? color, FontWeight? weight}) {
  return Theme.of(Get.context!).textTheme.titleMedium!.copyWith(
      fontSize: Get.width > 500 ? size! * 1.4 : size,
      fontWeight: weight ?? FontWeight.w600,
      color:
          color ?? (Get.isDarkMode ? AppColor.bgLight : AppColor.title));
}

TextStyle styleSmall({double? size = 14, Color? color, FontWeight? weight}) {
  return Theme.of(Get.context!).textTheme.titleSmall!.copyWith(
      fontSize: Get.width > 500 ? size! * 1.3 : size,
      fontWeight: weight ?? FontWeight.normal,
      color:
          color ?? (Get.isDarkMode ? AppColor.bgLight : AppColor.title));
}
''';
  }

  static String textStyleHelperRiverpod() {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'app_color.dart';

// Providers for isDarkMode dan width
// Width wil adjust other text sized
final isDarkModeProvider = StateProvider<bool>((ref) => false);
final widthProvider = StateProvider<double>((ref) => 0);

TextStyle styleLarge(WidgetRef ref, {double? size = 14, Color? color, FontWeight? weight}) {
  final isDarkMode = ref.watch(isDarkModeProvider);
  final width = ref.watch(widthProvider);

  return TextStyle(
    fontSize: width > 500 ? size! * 1.4 : size,
    fontWeight: weight ?? FontWeight.bold,
    color: color ?? (isDarkMode ? AppColor.bgLight : AppColor.title),
  );
}

TextStyle styleMedium(WidgetRef ref, {double? size = 14, Color? color, FontWeight? weight}) {
  final isDarkMode = ref.watch(isDarkModeProvider);
  final width = ref.watch(widthProvider);

  return TextStyle(
    fontSize: width > 500 ? size! * 1.4 : size,
    fontWeight: weight ?? FontWeight.w600,
    color: color ?? (isDarkMode ? AppColor.bgLight : AppColor.title),
  );
}

TextStyle styleSmall(WidgetRef ref, {double? size = 14, Color? color, FontWeight? weight}) {
  final isDarkMode = ref.watch(isDarkModeProvider);
  final width = ref.watch(widthProvider);

  return TextStyle(
    fontSize: width > 500 ? size! * 1.3 : size,
    fontWeight: weight ?? FontWeight.normal,
    color: color ?? (isDarkMode ? AppColor.bgLight : AppColor.title),
  );
}
''';
  }

  static String textStyleHelperBloc() {
    return '''
import 'package:flutter/material.dart';

import 'app_color.dart';

TextStyle styleLarge(BuildContext context, {double? size = 14, Color? color, FontWeight? weight}) {
  final width = MediaQuery.of(context).size.width;
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return TextStyle(
    fontSize: width > 500 ? size! * 1.4 : size,
    fontWeight: weight ?? FontWeight.bold,
    color: color ?? (isDarkMode ? AppColor.bgLight : AppColor.title),
  );
}

TextStyle styleMedium(BuildContext context, {double? size = 14, Color? color, FontWeight? weight}) {
  final width = MediaQuery.of(context).size.width;
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return TextStyle(
    fontSize: width > 500 ? size! * 1.4 : size,
    fontWeight: weight ?? FontWeight.w600,
    color: color ?? (isDarkMode ? AppColor.bgLight : AppColor.title),
  );
}

TextStyle styleSmall(BuildContext context, {double? size = 14, Color? color, FontWeight? weight}) {
  final width = MediaQuery.of(context).size.width;
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return TextStyle(
    fontSize: width > 500 ? size! * 1.3 : size,
    fontWeight: weight ?? FontWeight.normal,
    color: color ?? (isDarkMode ? AppColor.bgLight : AppColor.title),
  );
}
''';
  }

  /// Returns the Dart code for a Freezed UserModel class.
  static String userModel() {
    return '''
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _\$UserModel {
  
  const factory UserModel({
    required String id,
    required String name,
    required String email,
    String? phone,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _\$UserModelFromJson(json);
}

''';
  }

  /// Returns the Dart code for the R localization helper class.
  static String localizationRClass() {
    return '''
import 'package:flutter/material.dart';

import 'generated/app_localizations.dart';

class R {
  static late BuildContext _context;

  static void init(BuildContext context) => _context = context;

  static AppLocalizations get string => AppLocalizations.of(_context)!;
}
''';
  }

  /// Returns the Dart code for a Freezed model class for a given [featureName].
  static String freezedModel(String featureName) {
    final pascal = pascalCase(featureName);
    final snake = featureName.toLowerCase();

    return '''
import 'package:freezed_annotation/freezed_annotation.dart';

part '${snake}_model.freezed.dart';
part '${snake}_model.g.dart';

@freezed
abstract class ${pascal}Model with _\$${pascal}Model {
  const factory ${pascal}Model({
    int? id
  }) = _${pascal}Model;

  factory ${pascal}Model.fromJson(Map<String, dynamic> json) =>
      _\$${pascal}ModelFromJson(json);
}
''';
  }

  /// Converts a string [input] to PascalCase.
  static String pascalCase(String input) {
    final words = input
        .trim()
        .split(RegExp(r'[^a-zA-Z0-9]+'))
        .where((w) => w.isNotEmpty)
        .toList();

    if (words.isEmpty) return '';

    return words
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join();
  }

  /// Returns the content for l10n.yaml localization config file.
  static String l10nYaml() {
    return '''
arb-dir: lib/core/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
output-dir: lib/core/l10n/generated
preferred-supported-locales:
  - en
  - id
''';
  }

  /// Returns the content for English ARB localization file.
  static String l10nArbEn() {
    return '''
{
  "@@locale": "en",
  "login": "Login",
  "phone": "Phone Number",
  "password": "Password",
  "loginTitle": "Login Account",
  "loginSubTitle": "Please enter phone number and password",
  "homeView": "Home View",
  "homeWelcome": "Welcome back!",
  "homeSubtitle": "Here's what's happening today",
  "homeExplore": "Explore",
  "homeNotifications": "Notifications",
  "homeProfile": "Profile",
  "homeSettings": "Settings"
}
''';
  }

  /// Returns the content for Indonesian ARB localization file.
  static String l10nArbId() {
    return '''
{
  "@@locale": "id",
  "login": "Masuk",
  "phone": "No. Hp",
  "password": "Sandi",
  "loginTitle": "Masuk Aplikasi",
  "loginSubTitle": "Silakan masukkan No. Hp dan Sandi",
  "homeView": "Beranda",
  "homeWelcome": "Selamat datang kembali!",
  "homeSubtitle": "Berikut ringkasan aktivitas hari ini",
  "homeExplore": "Jelajahi",
  "homeNotifications": "Notifikasi",
  "homeProfile": "Profil",
  "homeSettings": "Pengaturan"
}
''';
  }

  /// Firebase
  /// Returns the Dart code for the FirebaseService class.
  static String firebaseService() {
    return '''
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'notification_service.dart';

typedef FirebaseTokenCallback = void Function(String token);

class FirebaseService {
  static Future<void> init({
    FirebaseTokenCallback? onToken,
  }) async {
    await Firebase.initializeApp();

    // Analytics
    FirebaseAnalytics.instance;

    // Crashlytics - capture Flutter errors
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    // Push notification + local notification
    await NotificationService.init();

    final messaging = FirebaseMessaging.instance;

    // Request permission (iOS)
    if (!kIsWeb && Platform.isIOS) {
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
    }

    // Get token
    final token = await messaging.getToken();
    if (token != null && token.isNotEmpty) {
      onToken?.call(token);
    }

    // Foreground: show local notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      NotificationService.showRemoteMessage(message);
    });

    // Token refresh
    messaging.onTokenRefresh.listen((newToken) {
      if (newToken.isNotEmpty) {
        onToken?.call(newToken);
      }
    });
  }
}
''';
  }

  /// Returns the Dart code for the NotificationService class.
  static String notificationService() {
    return '''
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);

    // Android channel
    const channel = AndroidNotificationChannel(
      'default_channel',
      'Default Notifications',
      description: 'Default notification channel',
      importance: Importance.max,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> showRemoteMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      notification.title ?? '',
      notification.body ?? '',
      details,
    );
  }
}
''';
  }

  static String globalApiResponse() {
    return '''
import 'package:freezed_annotation/freezed_annotation.dart';

part 'global_api_response.freezed.dart';
part 'global_api_response.g.dart';

@freezed
abstract class GlobalApiResponse with _\$GlobalApiResponse {
  const factory GlobalApiResponse({
    int? statusCode,
    String? message,
    dynamic data,
  }) = _GlobalApiResponse;

  factory GlobalApiResponse.fromJson(Map<String, dynamic> json) =>
      _\$GlobalApiResponseFromJson(json);
}
''';
  }
}
