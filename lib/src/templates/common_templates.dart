import '../../core/configs/app_icon_config.dart';
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

  /// `flutter_launcher_icons` block appended to generated [pubspec.yaml].
  static String flutterLauncherIconsBlock() {
    return '''

# Launcher icon — replace [image_path] with your PNG (1024×1024 recommended), then run:
#   dart run flutter_launcher_icons
flutter_launcher_icons:
  android: true
  ios: true
  image_path: ${AppIconConfig.projectAssetPath}
''';
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
import '${libPrefix}sessions/user_session.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({
    super.key,
    required this.onToggleTheme,
    required this.onToggleLanguage,
    required this.onLogout,
  });

  final VoidCallback onToggleTheme;
  final VoidCallback onToggleLanguage;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final savedPhone = UserSessions.getPhone();
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
                        IconButton(
                          onPressed: onLogout,
                          tooltip: R.string.homeExit,
                          icon: const Icon(Icons.logout_rounded, color: Colors.white),
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
                      savedPhone != null && savedPhone.isNotEmpty
                          ? savedPhone
                          : R.string.homeSubtitle,
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
import 'package:dio_extended/diox_chucker.dart';
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
import 'package:dio_extended/diox_chucker.dart';
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
import 'package:dio_extended/diox_chucker.dart';
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

  /// Returns the Dart code for the main App widget for Provider projects.
  static String appWidgetProvider(ProjectConfig config) {
    return '''
import 'package:dio_extended/diox.dart';
import 'package:dio_extended/diox_chucker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:secure_compressor/secure_compressor.dart';
import 'core/l10n/string_resources.dart';
import 'core/config/env_config.dart';
import 'core/l10n/generated/app_localizations.dart';
import 'core/services/base_connection.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';
${config.useSecretKey ? "import 'core/config/secretkey.dart';" : ''}

enum Environment { development, staging, production }

/// App-wide theme mode + locale for Provider-based projects.
class AppNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void toggleLanguage() {
    _locale = _locale.languageCode == 'en'
        ? const Locale('id')
        : const Locale('en');
    notifyListeners();
  }
}

class App extends StatelessWidget {
  const App({super.key, required this.env});

  final Environment env;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        /// One connection for the whole app, so the auth headers / token
        /// refresh state are shared. Read it with context.read<BaseConnection>().
        Provider<BaseConnection>(create: (_) => BaseConnection()),
        ChangeNotifierProvider<AppNotifier>(create: (_) => AppNotifier()),
      ],
      child: Consumer<AppNotifier>(
        builder: (context, appNotifier, _) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: '${config.appDisplayName}',
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: appNotifier.themeMode,
            routerConfig: appRouter,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            locale: appNotifier.locale,
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
  ///
  /// GetX: one permanent instance registered in `initApp` (`Get.put(..., permanent: true)`),
  /// reached with `Get.find<BaseConnection>()` / `BaseConnection.to`.
  static String baseConnectionGetX() {
    return _baseConnectionSource(
      packageImports: [
        "import 'package:flutter/material.dart';",
        "import 'package:get/get.dart';",
        "import '../../routes/app_routes.dart';",
      ],
      redirectToLogin: _redirectToLoginMethod('''
Get.offAllNamed(Routes.login);'''),
      construction: '''
  BaseConnection()
    : super(
        baseUrl: EnvConfig.apiBaseUrl,
        headers: _buildAuthHeaders(),
        tokenExpiredCode: 402,
        /// If your token source is async (e.g. fetched from a remote call),
        /// replace [headers] with [headersAsync] and make _buildAuthHeaders async:
        // headersAsync: _buildAuthHeadersAsync(),
      );

  /// The single app-wide instance registered in `initApp`.
  static BaseConnection get to => Get.find<BaseConnection>();
''',
    );
  }

  /// Riverpod: one `keepAlive` provider, so the same connection (and its auth
  /// headers) lives for the whole app. Read it with `ref.read(baseConnectionProvider)`.
  static String baseConnectionRiverpod() {
    return _baseConnectionSource(
      packageImports: [
        "import 'package:flutter/material.dart';",
        "import 'package:go_router/go_router.dart';",
        "import 'package:riverpod_annotation/riverpod_annotation.dart';",
        "import 'package:xwidgets_pack/xwidgets.dart';",
        "import '../../routes/routes.dart';",
      ],
      redirectToLogin: _redirectToLoginMethod(_goRouterSessionExpiredNavigation()),
      beforeClass: '''
part 'base_connection.g.dart';

/// keepAlive: must NOT be auto-disposed. A disposed connection would be rebuilt
/// with whatever token was stored at that moment and drop in-flight refreshes.
@Riverpod(keepAlive: true)
BaseConnection baseConnection(Ref ref) => BaseConnection();
''',
      construction: '''
  BaseConnection()
    : super(
        baseUrl: EnvConfig.apiBaseUrl,
        headers: _buildAuthHeaders(),
        tokenExpiredCode: 402,
        /// If your token source is async (e.g. fetched from a remote call),
        /// replace [headers] with [headersAsync] and make _buildAuthHeaders async:
        // headersAsync: _buildAuthHeadersAsync(),
      );
''',
    );
  }

  /// Bloc: no DI container in the dependencies, so the connection is a lazy
  /// singleton. Datasources can call `BaseConnection()` and always get the same
  /// instance, which keeps auth headers consistent app-wide.
  static String baseConnectionBloc() {
    return _baseConnectionSource(
      packageImports: [
        "import 'package:flutter/material.dart';",
        "import 'package:go_router/go_router.dart';",
        "import 'package:xwidgets_pack/xwidgets.dart';",
        "import '../../routes/routes.dart';",
      ],
      redirectToLogin: _redirectToLoginMethod(_goRouterSessionExpiredNavigation()),
      construction: '''
  BaseConnection._internal()
    : super(
        baseUrl: EnvConfig.apiBaseUrl,
        headers: _buildAuthHeaders(),
        tokenExpiredCode: 402,
        /// If your token source is async (e.g. fetched from a remote call),
        /// replace [headers] with [headersAsync] and make _buildAuthHeaders async:
        // headersAsync: _buildAuthHeadersAsync(),
      );

  static final BaseConnection _instance = BaseConnection._internal();

  /// Always returns the same instance. Never recreate it to "reset" the token:
  /// use [saveSession] / [clearSession] so every holder sees the new headers.
  factory BaseConnection() => _instance;
''',
    );
  }

  /// Provider: the connection is created once by a `Provider<BaseConnection>` at
  /// the app root (see `app.dart`) and injected with `context.read<BaseConnection>()`.
  static String baseConnectionProvider() {
    return _baseConnectionSource(
      packageImports: [
        "import 'package:flutter/material.dart';",
        "import 'package:go_router/go_router.dart';",
        "import 'package:xwidgets_pack/xwidgets.dart';",
        "import '../../routes/routes.dart';",
      ],
      redirectToLogin: _redirectToLoginMethod(_goRouterSessionExpiredNavigation()),
      construction: '''
  BaseConnection()
    : super(
        baseUrl: EnvConfig.apiBaseUrl,
        headers: _buildAuthHeaders(),
        tokenExpiredCode: 402,
        /// If your token source is async (e.g. fetched from a remote call),
        /// replace [headers] with [headersAsync] and make _buildAuthHeaders async:
        // headersAsync: _buildAuthHeadersAsync(),
      );
''',
    );
  }

  /// Builds a `BaseConnection` source file. Only how the instance is created /
  /// shared ([construction], [beforeClass], [packageImports]) differs per state
  /// management; token + refresh handling is identical (see
  /// [_baseConnectionAuthMembers]).
  static String _baseConnectionSource({
    required String construction,
    required String redirectToLogin,
    List<String> packageImports = const [],
    String beforeClass = '',
  }) {
    final packages = packageImports.isEmpty
        ? ''
        : '${packageImports.join('\n')}\n';
    final before = beforeClass.isEmpty ? '' : '$beforeClass\n';
    return '''
import 'package:dio_extended/diox.dart';
$packages
import '../../sessions/user_session.dart';
import '../config/env_config.dart';
import '../models/global_api_response.dart';

${before}class BaseConnection extends DioExtended {
$construction
$redirectToLogin
${_baseConnectionAuthMembers()}}
''';
  }

  /// Clears the session, then opens login on the next frame.
  ///
  /// [navigation] is state-management specific (GetX vs go_router) and is
  /// inserted outside the shared refresh section so that section stays identical.
  static String _redirectToLoginMethod(String navigation) {
    return '''
  var _redirectingToLogin = false;

  /// Drops the stored session and opens login. Repeated calls in the same
  /// frame (queued requests after one failed refresh) navigate only once.
  void _redirectToLogin() {
    if (_redirectingToLogin) return;
    _redirectingToLogin = true;
    try {
      clearSession();
    } catch (e) {
      debugPrint('Session cleanup failed: \$e');
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        $navigation
      } catch (e) {
        debugPrint('Redirect to login failed: \$e');
      } finally {
        _redirectingToLogin = false;
      }
    });
  }
''';
  }

  static String _goRouterSessionExpiredNavigation() {
    return '''
final context = XSnackbar.navigatorKey.currentContext;
        if (context != null && context.mounted) {
          final router = GoRouter.of(context);
          while (router.canPop()) {
            router.pop();
          }
          context.go(Routes.login);
        }''';
  }

  /// Token + refresh handling shared by every BaseConnection variant.
  ///
  /// How DioExtended works (so this stays bug-free):
  /// - Headers passed to the constructor are applied ONCE. To change the token
  ///   later, mutate `dio.options.headers` on the same instance
  ///   ([updateAuthHeaders]); never swap the instance.
  /// - On `tokenExpiredCode`, DioExtended calls [handleTokenExpired], merges the
  ///   returned headers into `dio.options.headers` and retries the request once.
  ///   Concurrent 4xx responses wait for the same refresh (single-flight).
  /// - Requests made INSIDE [handleTokenExpired] never trigger another refresh,
  ///   so the refresh call can safely use this same connection.
  /// - Throwing from [handleTokenExpired] fails the original (and queued) requests.
  /// - A failed refresh also clears the session and opens login ([_redirectToLogin]).
  static String _baseConnectionAuthMembers() {
    return '''
  static const String _authHeaderKey = 'token';

  /// Saves the tokens and applies them to this live connection.
  ///
  /// Call it right after a successful login, e.g.
  /// `connection.saveSession(token: ..., refreshToken: ...)`.
  void saveSession({required String token, String? refreshToken}) {
    UserSessions.saveToken(token);
    if (refreshToken != null) UserSessions.saveRefreshToken(refreshToken);
    updateAuthHeaders();
  }

  /// Clears the stored session and the auth headers. Call it on logout.
  void clearSession() {
    UserSessions.clearSession();
    clearAuthHeaders();
  }

  /// Re-applies the token stored in [UserSessions] to this connection.
  void updateAuthHeaders() {
    dio.options.headers.remove(_authHeaderKey);
    dio.options.headers.addAll(_buildAuthHeaders());
  }

  /// Removes the auth header from this connection.
  void clearAuthHeaders() {
    dio.options.headers.remove(_authHeaderKey);
  }

  /// Called by DioExtended when the server answers with `tokenExpiredCode`.
  ///
  /// Exchange the stored refresh token for a new token, save it and return the
  /// auth headers (auth only, never `Content-Type`). DioExtended then retries
  /// the failed request with them.
  @override
  Future<Map<String, dynamic>> handleTokenExpired() async {
    try {
      final refreshToken = UserSessions.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw StateError('Session expired: no refresh token available.');
      }

      // TODO: adjust the endpoint, body and response keys to your API.
      final result = await callApiRequest<GlobalApiResponse>(
        request: () => post(
          '/api/refresh-token',
          body: {'refreshToken': refreshToken},
        ),
        parseData: (data) => GlobalApiResponse.fromJson(data),
      );

      final payload = result.data?.data;
      final tokens = payload is Map ? payload : null;
      final newToken = tokens?['token'] as String?;
      if (!result.isSuccess || newToken == null || newToken.isEmpty) {
        throw StateError(result.message ?? 'Failed to refresh token.');
      }

      saveSession(
        token: newToken,
        refreshToken: tokens?['refreshToken'] as String? ?? refreshToken,
      );
      return _buildAuthHeaders();
    } catch (error) {
      _redirectToLogin();
      if (error is StateError) rethrow;
      throw StateError('Failed to refresh token.');
    }
  }

  /// Empty when there is no token, so no bogus `Bearer ` header is sent
  /// before login.
  static Map<String, String> _buildAuthHeaders() {
    final token = UserSessions.getToken();
    if (token == null || token.isEmpty) return {};
    return {_authHeaderKey: 'Bearer \$token'};
  }
''';
  }

  /// Generated `lib/core/config/session_storage_keys.dart` (unique per project).
  static String sessionStorageKeysFile(SessionStorageKeys keys) {
    return '''
/// Local storage keys for [StorageHelper]. Generated once for this project.
abstract final class SessionStorageKeys {
  static const userData = '${keys.userData}';
  static const accessToken = '${keys.accessToken}';
  static const refreshToken = '${keys.refreshToken}';
  static const phone = '${keys.phone}';
  static const sessionActive = '${keys.sessionActive}';
}
''';
  }

  /// Clears session + auth headers, then navigates to login with a clean stack.
  static String goRouterLogoutBody({
    required String connectionExpression,
  }) {
    return '''
    try {
      $connectionExpression.clearSession();
    } catch (e) {
      debugPrint('Logout cleanup failed: \$e');
      try {
        UserSessions.clearSession();
      } catch (_) {}
    }
    if (!context.mounted) return;
    final router = GoRouter.of(context);
    while (router.canPop()) {
      router.pop();
    }
    context.go(Routes.login);
''';
  }

  /// Persists phone + user session locally after a successful login.
  static String persistLoginSessionBlock({
    required String phoneExpression,
    required String connectionExpression,
  }) {
    return '''
    final sessionPhone = ($phoneExpression).toString().trim();
    if (sessionPhone.isEmpty) {
      throw StateError('Phone number is required.');
    }
    UserSessions.openSession(
      phone: sessionPhone,
      user: UserModel(
        id: 'local',
        name: sessionPhone,
        email: '',
        phone: sessionPhone,
      ),
      accessToken: 'local-access-token',
    );
    $connectionExpression.saveSession(token: 'local-access-token');
''';
  }

  /// Demo login: skips HTTP so generated apps work before the backend is ready.
  ///
  /// [trailingLines] optional code after [persistLoginSessionBlock] (e.g. `return`
  /// for clean-architecture notifiers). [realApiSnippet] overrides the default
  /// commented example for calling the real endpoint.
  static String demoLoginBypassBlock({
    required String phoneExpression,
    required String connectionExpression,
    String trailingLines = '',
    String? realApiSnippet,
  }) {
    final trailing =
        trailingLines.isEmpty ? '' : '$trailingLines\n';
    final realApi = realApiSnippet ?? _demoLoginRealApiCommentDefault();
    return '''
    // --- DEMO LOGIN (no HTTP) ------------------------------------------------
    // Lets you test splash, session, home, and logout without a working API.
    // Before production:
    //   1. Set [EnvConfig.apiBaseUrl] to a reachable host (not a placeholder
    //      like `development` — that causes "Failed host lookup" in Dio).
    //   2. Replace this DEMO block with the REAL API snippet below (or the
    //      matching block in [LoginRemoteDatasource] / login listener).
    //   3. In login_view, uncomment listener handling for API errors and
    //      failed [ApiResult.isSuccess] (search for "REAL API" in that file).
    await Future.delayed(const Duration(milliseconds: 300));
${persistLoginSessionBlock(
  phoneExpression: phoneExpression,
  connectionExpression: connectionExpression,
)}
$trailing// --- REAL API (uncomment; remove DEMO block above when ready) --------
$realApi
''';
  }

  static String _demoLoginRealApiCommentDefault() {
    return '''
    // final result = await remoteDatasource.login(
    //   emailOrPhone: emailOrPhone,
    //   password: password,
    // );
    // if (!result.isSuccess) {
    //   throw StateError(result.message ?? 'Login failed');
    // }
    // Map access/refresh tokens from result.data, then:
    // UserSessions.openSession(...); connection.saveSession(...);
''';
  }

  /// Comment block for generated [login_remote_datasource.dart] files.
  static String loginRemoteDatasourceFileHeader() {
    return '''
/// HTTP login lives here. The generated login flow uses the DEMO LOGIN block
/// in the notifier/bloc/controller until you wire the real API.
///
/// When enabling the API:
/// - Fix [EnvConfig.apiBaseUrl] (valid scheme + host, e.g. https://api.example.com).
/// - Align [login] path and JSON field names with your backend.
/// - Parse tokens from the response and call [UserSessions.openSession] /
///   [BaseConnection.saveSession] after a successful login.
''';
  }

  static String userSessionsGetx() =>
      userSessions(userModelImport: "import '../features/login/models/user_model.dart';");

  static String userSessionsRiverpod() => userSessions(
        userModelImport:
            "import '../features/login/data/models/user_model.dart';",
      );

  static String userSessionsBloc() => userSessions(
        userModelImport:
            "import '../features/login/data/models/user_model.dart';",
      );

  /// Local session + user profile via [StorageHelper] (secure_compressor).
  static String userSessions({required String userModelImport}) {
    return '''
import 'dart:convert';

import 'package:secure_compressor/secure_compressor.dart';

import '../core/config/session_storage_keys.dart';
$userModelImport

class UserSessions {
  static final UserSessions _instance = UserSessions._internal();

  UserSessions._internal();

  factory UserSessions() => _instance;

  static void saveUserData({UserModel? userData, dynamic userDataMap}) {
    if (userData == null && userDataMap == null) return;
    final dataUserString = userData != null
        ? jsonEncode(userData.toJson())
        : userDataMap.toString();
    StorageHelper.saveString(
      key: SessionStorageKeys.userData,
      value: dataUserString,
    );
  }

  static UserModel? getUserData() {
    final dataUserString =
        StorageHelper.getString(key: SessionStorageKeys.userData);
    if (dataUserString == null) {
      return null;
    }
    return UserModel.fromJson(jsonDecode(dataUserString));
  }

  static void savePhone(String phone) {
    StorageHelper.saveString(key: SessionStorageKeys.phone, value: phone);
  }

  static String? getPhone() {
    return StorageHelper.getString(key: SessionStorageKeys.phone);
  }

  static void saveToken(String token) {
    StorageHelper.saveString(key: SessionStorageKeys.accessToken, value: token);
  }

  static String? getToken() {
    return StorageHelper.getString(key: SessionStorageKeys.accessToken);
  }

  static void saveRefreshToken(String token) {
    StorageHelper.saveString(
      key: SessionStorageKeys.refreshToken,
      value: token,
    );
  }

  static String? getRefreshToken() {
    return StorageHelper.getString(key: SessionStorageKeys.refreshToken);
  }

  static void markSessionActive() {
    StorageHelper.saveString(
      key: SessionStorageKeys.sessionActive,
      value: '1',
    );
  }

  static void markSessionInactive() {
    StorageHelper.saveString(
      key: SessionStorageKeys.sessionActive,
      value: '0',
    );
  }

  /// True when the user logged in before (survives app restarts).
  static bool hasActiveSession() {
    if (!StorageHelper.isInitialized()) {
      return false;
    }
    if (StorageHelper.getString(key: SessionStorageKeys.sessionActive) != '1') {
      return false;
    }
    final phone = getPhone();
    return phone != null && phone.trim().isNotEmpty;
  }

  /// Call after login: stores phone, user profile, optional tokens, session flag.
  static void openSession({
    required String phone,
    UserModel? user,
    String? accessToken,
    String? refreshToken,
  }) {
    final normalizedPhone = phone.trim();
    if (normalizedPhone.isEmpty) {
      return;
    }
    savePhone(normalizedPhone);
    markSessionActive();
    try {
      saveUserData(
        userData: user ??
            UserModel(
              id: 'local',
              name: normalizedPhone,
              email: '',
              phone: normalizedPhone,
            ),
      );
    } catch (_) {
      // Phone + session flag are enough for auto-login; profile JSON is optional.
    }
    if (accessToken != null && accessToken.isNotEmpty) {
      saveToken(accessToken);
    }
    if (refreshToken != null && refreshToken.isNotEmpty) {
      saveRefreshToken(refreshToken);
    }
  }

  /// Clears session keys only (keeps other [StorageHelper] entries if any).
  static void clearSession() {
    markSessionInactive();
    StorageHelper.saveString(key: SessionStorageKeys.phone, value: '');
    StorageHelper.saveString(key: SessionStorageKeys.accessToken, value: '');
    StorageHelper.saveString(key: SessionStorageKeys.refreshToken, value: '');
    StorageHelper.saveString(key: SessionStorageKeys.userData, value: '');
  }

  static void deletUserData() {
    clearSession();
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
  "homeSettings": "Settings",
  "homeExit": "Log out"
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
  "homeSettings": "Pengaturan",
  "homeExit": "Keluar"
}
''';
  }

  /// Firebase
  /// Returns the Dart code for the FirebaseService class.
  static String firebaseService() {
    return '''
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../../firebase_options.dart';
import 'notification_service.dart';

typedef FirebaseTokenCallback = void Function(String token);

class FirebaseService {
  static Future<void> init({
    FirebaseTokenCallback? onToken,
  }) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Analytics (all platforms)
    FirebaseAnalytics.instance;

    // Crashlytics — not supported on web the same way as mobile
    if (!kIsWeb) {
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;

      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }

    final messaging = FirebaseMessaging.instance;

    if (!kIsWeb) {
      await NotificationService.init();

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        NotificationService.showRemoteMessage(message);
      });
    }

    final token = await messaging.getToken();
    if (token != null && token.isNotEmpty) {
      onToken?.call(token);
    }

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
    await _plugin.initialize(settings: settings);

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
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: notification.title,
      body: notification.body,
      notificationDetails: details,
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
