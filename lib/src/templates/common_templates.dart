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
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
        scrolledUnderElevation: 0,
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColor.title,
          fontSize: 16,
          fontFamily: 'Inter'
        ),
        iconTheme: IconThemeData(color: AppColor.bgLight),
        elevation: 0,
        actionsIconTheme: IconThemeData(color: AppColor.bgLight),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: AppColor.bgLight,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: AppColor.bgDark,
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
        scrolledUnderElevation: 0,
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColor.title,
          fontSize: 16,
          fontFamily: 'Inter'
        ),
        iconTheme: IconThemeData(color: AppColor.bgLight),
        elevation: 0,
        actionsIconTheme: IconThemeData(color: AppColor.bgLight),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: AppColor.bgLight,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: AppColor.bgDark,
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

enum Environment { development, staging, production }

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
        themeMode: ThemeMode.system,
        navigatorKey: XSnackbar.navigatorKey,
        initialRoute: Routes.splash,
        getPages: AppPages.routes,
        navigatorObservers: [
          ShakeChuckerConfigs.navigatorObserver
        ],
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

  /// Load environment configuration
  await EnvConfig.load(env.name);

  /// Initialize secure storage
  await StorageHelper.initialize('${config.appName}', isEncryptKeyAndValue: true);
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

  /// Load environment configuration
  await EnvConfig.load(env.name);

  /// Initialize secure storage
  await StorageHelper.initialize('${config.appName}', isEncryptKeyAndValue: true);
}
''';
  }

  /// Returns the Dart code for the main App widget for Bloc projects.
  static String appWidgetBloc(ProjectConfig config) {
    return '''
import 'package:dio_extended/diox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:secure_compressor/secure_compressor.dart';
import 'core/l10n/string_resources.dart';
import 'core/config/env_config.dart';
import 'core/l10n/generated/app_localizations.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';

enum Environment { development, staging, production }

class App extends StatelessWidget {
  const App({super.key, required this.env});

  final Environment env;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: '${config.appDisplayName}',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale('en'),
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

  /// Load environment configuration
  await EnvConfig.load(env.name);

  /// Initialize secure storage
  await StorageHelper.initialize('${config.appName}', isEncryptKeyAndValue: true);
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

import '../../sessions/user_session.dart';
import '../config/env_config.dart';

class BaseConnection extends DioExtended {

  BaseConnection._internal()
    : super(baseUrl: EnvConfig.apiBaseUrl, headers: _buildAuthHeaders(), tokenExpiredCode: 402);

  static final BaseConnection _instance = BaseConnection._internal();
  factory BaseConnection() => _instance;

  @override
  Future<dynamic> handleTokenExpired() async {
    /// Fetch your new token here
    /// .........
    return _buildAuthHeaders();
  }

  static Map<String, String> _buildAuthHeaders() {
    final token = UserSessions.getToken();
    if (token == null) return {};
    return {'token': token};
  }

  /// If fetch async headers
  // static Future<Map<String, String>> _buildAuthHeaders() async {
  //   String token = UserSessions.getToken() ?? '';
  //   return {
  //     'token': 'Bearer \${token.toString()}',
  //   };
  // }
}
''';
  }

  static String baseConnectionRiverpod() {
    return '''
import 'package:dio_extended/diox.dart';

import '../../sessions/user_session.dart';
import '../config/env_config.dart';

class BaseConnection extends DioExtended {

  BaseConnection._internal()
    : super(baseUrl: EnvConfig.apiBaseUrl, headers: _buildAuthHeaders(), tokenExpiredCode: 402);

  static final BaseConnection _instance = BaseConnection._internal();
  factory BaseConnection() => _instance;

  @override
  Future<dynamic> handleTokenExpired() async {
    /// Fetch your new token here
    /// .........
    return _buildAuthHeaders();
  }

  static Map<String, String> _buildAuthHeaders() {
    final token = UserSessions.getToken();
    if (token == null) return {};
    return {'token': token};
  }
}

  /// If fetch async headers
  /// Using this code to provide connection provider
  /// NOTE: You can uncomment DatasourceRefX in core/extensions/datasource_refx.dart
  /// to use this async headers version
  
// import 'package:dio_extended/diox.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';

// import '../../sessions/user_session.dart';
// import '../config/env_config.dart';

// part 'base_connection.g.dart';

// @riverpod
// Future<BaseConnection> baseConnection(Ref ref) async {
//   return BaseConnection.create();
// }

// class BaseConnection extends DioExtended {
//   BaseConnection._internal(Map<String, String> headers) 
//     : super(baseUrl: EnvConfig.apiBaseUrl, headersAsync: Future.value(headers));

//   static Future<BaseConnection> create() async {
//     final headers = await _buildAuthHeaders();
//     return BaseConnection._internal(headers);
//   }

//   static Future<Map<String, String>> _buildAuthHeaders() async {
//     String token = UserSessions.getToken() ?? '';
//     return {
//       'token': 'Bearer \${token.toString()}',
//     };
//   }
// }
''';
  }

  static String baseConnectionBloc() {
    return '''
import 'package:dio_extended/diox.dart';

import '../../sessions/user_session.dart';
import '../config/env_config.dart';

class BaseConnection extends DioExtended {

  BaseConnection._internal()
    : super(baseUrl: EnvConfig.apiBaseUrl, headers: _buildAuthHeaders(), tokenExpiredCode: 402);

  static final BaseConnection _instance = BaseConnection._internal();
  factory BaseConnection() => _instance;

  @override
  Future<dynamic> handleTokenExpired() async {
    /// Fetch your new token here
    /// .........
    return _buildAuthHeaders();
  }

  static Map<String, String> _buildAuthHeaders() {
    final token = UserSessions.getToken();
    if (token == null) return {};
    return {'token': token};
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
  "homeView": "Home View"
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
  "homeView": "Beranda"
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
