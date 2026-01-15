import '../../../core/configs/project_config.dart';
import '../common_templates.dart';

class RiverpodFeatureTemplate {
  static String generalDataSource(String featureName) {
    final pascal = CommonTemplates.pascalCase(featureName);

    return '''
class ${pascal}Datasources {
  Future<void> exampleCall() async {
    // TODO: integrate with API
  }
}
''';
  }

  static String generalProvider(String featureName) {
    final pascal = CommonTemplates.pascalCase(featureName);
    final snake = featureName.toLowerCase();

    return '''
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '${snake}_provider.g.dart';

@riverpod
class ${pascal}Notifier extends _\$${pascal}Notifier {
  @override
  int build() => 0;

  void increment() {
    state++;
  }
}
''';
  }

  static String generalView(String featureName) {
    final pascal = CommonTemplates.pascalCase(featureName);
    final snake = featureName.toLowerCase();

    return '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/${snake}_provider.dart';

class ${pascal}View extends ConsumerWidget {
  const ${pascal}View({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _ = ref.watch(${snake}Provider);

    return Scaffold(
      appBar: AppBar(title: const Text('$pascal')),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('This is Profile View')]),
      ),
    );
  }
}
''';
  }

  /// ==== Splash Feature Template ====
  static String splashNotifier(ProjectConfig config) {
    return '''
import 'package:riverpod_annotation/riverpod_annotation.dart';
${config.useFirebase ? '''
import 'package:flutter/material.dart';
import '../../../../core/services/firebase/firebase_service.dart';
''' : ''}

part 'splash_notifier.g.dart';

@riverpod
class SplashNotifier extends _\$SplashNotifier {
  @override
  Future<void> build() async {
    await _start();
  }

  Future<void> _start() async {
    ${config.useFirebase ? '''
    final stopwatch = Stopwatch()..start();
    try {
      await FirebaseService.init(
        onToken: (token) {
          debugPrint('FCM TOKEN: \$token');
        },
      );
    } catch (e) {
      debugPrint('Error during Firebase initialization: \$e');
    }
    final elapsed = stopwatch.elapsedMilliseconds;
    if (elapsed < 3000) {
      await Future.delayed(Duration(milliseconds: 3000 - elapsed));
    }
    ''' : 'await Future.delayed(Duration(seconds: 3));'}
  }
}
''';
  }

  static String splashView() {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes/routes.dart';
import '../providers/splash_notifier.dart';

class SplashView extends ConsumerWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(splashProvider);
    ref.listen(splashProvider, (_, next) {
      next.whenOrNull(
        data: (_) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            context.go(Routes.login);
          });
        },
      );
    });

    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FlutterLogo(size: 64),
            SizedBox(height: 12),
            Text(
              'Welcome',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
''';
  }

  /// ==== Login Feature Template ====

  static String loginFormField() {
    return '''
import 'package:flutter/material.dart';

class LoginFormFields {
  final formKey = GlobalKey<FormState>();

  final emailOrPhone = TextEditingController();
  final password = TextEditingController();

  void dispose() {
    emailOrPhone.dispose();
    password.dispose();
  }
}
''';
  }

  static String loginFormProvider() {
    return '''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../views/login_form_fields.dart';

final loginFormProvider = Provider.autoDispose<LoginFormFields>((ref) {
  final form = LoginFormFields();

  ref.onDispose(() {
    form.dispose();
  });

  return form;
});
''';
  }

  static String loginRemoteDataSource() {
    return '''
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../../../../core/config/env_config.dart';

abstract class LoginRemoteDataSource {
  Future<UserModel> login({
    required String emailOrPhone,
    required String password,
  });
}

class LoginRemoteDataSourceImpl implements LoginRemoteDataSource {
  final Dio dio;

  LoginRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> login({
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          'emailOrPhone': emailOrPhone,
          'password': password,
        },
      );

      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      return error.response?.data['message'] ?? 'Login failed';
    }
    return 'Network error. Please check your connection';
  }
}
''';
  }

  static String loginRemoteDatasource() {
    return '''
import 'package:dio_extended/models/api_result.dart';

import '../../../../core/services/base_connection.dart';
import '../models/user_model.dart';

class LoginRemoteDatasource {
  final BaseConnection _connection;

  LoginRemoteDatasource(this._connection);

  Future<ApiResult<UserModel>> login({
    required String emailOrPhone, required String password}) async {
    final response = await _connection.callApiRequest(
      request: () => _connection.post('/auth/login', body: {'email_or_phone': emailOrPhone, 'password': password}),
      parseData: (data) => UserModel.fromJson(data),
    );
    return response;
  }

  Future<void> logout() async {
    await _connection.callApiRequest(
      request: () => _connection.post('/auth/logout', body: {}),
      parseData: (data) => UserModel.fromJson(data),
    );
  }

  Future<UserModel?> getCurrentUser() async {
    final response = await _connection.get('/auth/me');

    if (response.data == null) return null;

    return UserModel.fromJson(response.data);
  }
}
''';
  }

  static String loginNotifier() {
    return '''
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Pastikan nama file sesuai, misal: login_notifier.dart
part 'login_notifier.g.dart'; 

@riverpod
class LoginNotifier extends _\$LoginNotifier {
  @override
  FutureOr<void> build() {
    // initial state
    return null;
  }

  Future<void> login({
    required String emailOrPhone,
    required String password,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      // TODO: integrate API call here (API request, save token, etc)
      await Future.delayed(const Duration(seconds: 1));
    });
  }
}
''';
  }

  static String loginView() {
    return '''
import 'package:app_test/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:xwidgets_pack/utils/x_form_validators.dart';
import 'package:xwidgets_pack/xwidgets.dart';

import '../../../../core/l10n/string_resources.dart';
import '../providers/login_form_provider.dart';
import '../providers/login_notifier.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  @override
  void initState() {
    super.initState();

    // Side-effects should be registered once
    ref.listenManual(loginProvider, (_, next) {
      next.whenOrNull(
        data: (_) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            context.go(Routes.home);
          });
        },
        error: (err, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            XSnackbar.error(err.toString());
          });
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch for UI updates (loading state)
    final asyncLogin = ref.watch(loginProvider);
    final form = ref.watch(loginFormProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: XCard(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Form(
            key: form.formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  R.string.loginTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(R.string.loginSubTitle),
                const XHeight(16),
                XTextField(
                  labelOnLine: R.string.phone,
                  controller: form.emailOrPhone,
                  validator: XFormValidator.combine([
                    XFormValidator.required(),
                    XFormValidator.phoneNumber(),
                  ]),
                ),
                XTextField(
                  labelOnLine: R.string.password,
                  isObscureText: true,
                  controller: form.password,
                  validator: XFormValidator.required(),
                ),
                const XHeight(16),
                XButton(
                  width: 300,
                  isLoading: asyncLogin.isLoading,
                  onPressed: () async {
                    final valid = form.formKey.currentState?.validate() ?? false;
                    if (!valid) return;

                    await ref.read(loginProvider.notifier).login(
                          emailOrPhone: form.emailOrPhone.text.trim(),
                          password: form.password.text.trim(),
                        );
                  },
                  child: Text(R.string.login),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
''';
  }

  /// ==== Home Feature Template ====

  static String homeView() {
    return '''
import 'package:app_test/core/l10n/locale_provider.dart';
import 'package:app_test/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/string_resources.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(R.string.homeView),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              ref.read(localeProvider.notifier).state = locale.languageCode == 'en'
                  ? const Locale('id')
                  : const Locale('en');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Welcome Home')]),
      ),
    );
  }
}
''';
  }
}
