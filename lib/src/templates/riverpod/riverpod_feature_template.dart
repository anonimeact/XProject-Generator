import '../../../core/configs/project_config.dart';
import '../common_templates.dart';

class RiverpodFeatureTemplate {
  static String datasourceRefxExt() {
    return '''
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/base_connection.dart';

extension DatasourceRefX on Ref {
  T makeDatasource<T>(T Function(BaseConnection conn) builder) {
    final connection = watch(baseConnectionProvider);
    return builder(connection);
  }
}
''';
  }

  static String generalDataSource(String featureName) {
    final pascal = CommonTemplates.pascalCase(featureName);
    return '''
import 'package:dio_extended/models/api_result.dart';

import '../../../../core/models/global_api_response.dart';
import '../../../../core/services/base_connection.dart';

class ${pascal}Datasources {
  /// Injected base connection
  /// You can use this to make API calls
  /// See: core/services/base_connection.dart

  final BaseConnection _connection;

  ${pascal}Datasources(this._connection);

  Future<ApiResult<GlobalApiResponse>> yourFunction({required String a}) async {
    final response = await _connection.callApiRequest(
      request: () => _connection.post('your_url', body: {'a': a}),
      parseData: (data) => GlobalApiResponse.fromJson(data),
    );
    return response;
  }
}
''';
  }

  static String generalProvider(String featureName) {
    final pascal = CommonTemplates.pascalCase(featureName);
    final snake = featureName.toLowerCase();

    return '''
import 'package:dio_extended/models/api_result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/extensions/datasource_refx.dart';
import '../../../../core/models/global_api_response.dart';
import '../../data/datasources/${snake}_datasources.dart';

part '${snake}_provider.g.dart';

@riverpod
${pascal}Datasources ${snake}Datasource(Ref ref) =>
    ref.makeDatasource((connection) => ${pascal}Datasources(connection));

@riverpod
class ${pascal}Controller extends _\$${pascal}Controller {
  @override
  AsyncValue<ApiResult<GlobalApiResponse>> build() {
    return AsyncData(ApiResult<GlobalApiResponse>.idle());
  }

  Future<void> yourFunction({required String a}) async {
    state = const AsyncLoading();

    final datasource = ref.read(${snake}DatasourceProvider);
    final result = await AsyncValue.guard(() => datasource.yourFunction(a: a));

    if (!ref.mounted) return;
    state = result;
  }
}
''';
  }

  static String generalEntity(String featureName) {
    final pascal = CommonTemplates.pascalCase(featureName);
    return '''
class ${pascal}Entity {
  const ${pascal}Entity({required this.id});

  final String id;
}
''';
  }

  static String generalRepository(String featureName) {
    final pascal = CommonTemplates.pascalCase(featureName);
    return '''
import 'package:dio_extended/models/api_result.dart';

import '../../../../core/models/global_api_response.dart';

abstract class ${pascal}Repository {
  Future<ApiResult<GlobalApiResponse>> yourFunction({required String a});
}
''';
  }

  static String generalRepositoryImpl(String featureName) {
    final pascal = CommonTemplates.pascalCase(featureName);
    final snake = featureName.toLowerCase();
    return '''
import 'package:dio_extended/models/api_result.dart';

import '../../../../core/models/global_api_response.dart';
import '../../domain/repositories/${snake}_repository.dart';
import '../datasources/${snake}_datasources.dart';

class ${pascal}RepositoryImpl implements ${pascal}Repository {
  ${pascal}RepositoryImpl({required this.datasource});

  final ${pascal}Datasources datasource;

  @override
  Future<ApiResult<GlobalApiResponse>> yourFunction({required String a}) async {
    return datasource.yourFunction(a: a);
  }
}
''';
  }

  static String generalUsecase(String featureName) {
    final pascal = CommonTemplates.pascalCase(featureName);
    final snake = featureName.toLowerCase();
    return '''
import 'package:dio_extended/models/api_result.dart';

import '../../../../core/models/global_api_response.dart';
import '../repositories/${snake}_repository.dart';

class Get${pascal} {
  Get${pascal}({required this.repository});

  final ${pascal}Repository repository;

  Future<ApiResult<GlobalApiResponse>> call({required String a}) async {
    return repository.yourFunction(a: a);
  }
}
''';
  }

  static String generalProviderClean(String featureName) {
    final pascal = CommonTemplates.pascalCase(featureName);
    final snake = featureName.toLowerCase();

    return '''
import 'package:dio_extended/models/api_result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/extensions/datasource_refx.dart';
import '../../../../core/models/global_api_response.dart';
import '../../data/datasources/${snake}_datasources.dart';
import '../../data/repositories/${snake}_repository_impl.dart';
import '../../domain/repositories/${snake}_repository.dart';
import '../../domain/usecases/get_${snake}.dart';

part '${snake}_provider.g.dart';

@riverpod
${pascal}Datasources ${snake}Datasource(Ref ref) =>
    ref.makeDatasource((connection) => ${pascal}Datasources(connection));

@riverpod
${pascal}Repository ${snake}Repository(Ref ref) => ${pascal}RepositoryImpl(
      datasource: ref.watch(${snake}DatasourceProvider),
    );

@riverpod
Get${pascal} get${pascal}(Ref ref) => Get${pascal}(
      repository: ref.watch(${snake}RepositoryProvider),
    );

@riverpod
class ${pascal}Controller extends _\$${pascal}Controller {
  @override
  AsyncValue<ApiResult<GlobalApiResponse>> build() {
    return AsyncData(ApiResult<GlobalApiResponse>.idle());
  }

  Future<void> yourFunction({required String a}) async {
    state = const AsyncLoading();

    final usecase = ref.read(get${pascal}Provider);
    final result = await AsyncValue.guard(() => usecase(a: a));

    if (!ref.mounted) return;
    state = result;
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
    final ${snake}State = ref.watch(${snake}ControllerProvider);

    ref.listen(${snake}ControllerProvider, (_, next) {
      next.whenOrNull(
        data: (data) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Success')),
          );
        },
        error: (err, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: \$err')),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('$pascal')),
      body: Center(
        child: ${snake}State.isLoading
            ? const CircularProgressIndicator()
            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('This is $pascal View')]),
      ),
    );
  }
}
''';
  }

  static String generalViewClean(String featureName) {
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
    final asyncState = ref.watch(${snake}ControllerProvider);

    ref.listen(${snake}ControllerProvider, (_, next) {
      next.whenOrNull(
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Success')),
          );
        },
        error: (err, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: \$err')),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('$pascal')),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: \$err')),
        data: (result) => Center(
          child: Text('Result: \$result'),
        ),
      ),
    );
  }
}
''';
  }

  /// ==== Splash Feature Template ====
  static String splashProvider(ProjectConfig config) {
    return '''
import 'package:riverpod_annotation/riverpod_annotation.dart';
${config.useFirebase ? '''
import 'package:flutter/material.dart';
import '../../../../core/services/firebase/firebase_service.dart';
''' : ''}

part 'splash_provider.g.dart';

@riverpod
class SplashProcess extends _\$SplashProcess {
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
import '../providers/splash_provider.dart';

class SplashView extends ConsumerWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(splashProcessProvider);
    ref.listen(splashProcessProvider, (_, next) {
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

  static String loginRepository() {
    return '''
import 'package:dio_extended/models/api_result.dart';

import '../../data/models/user_model.dart';

abstract class LoginRepository {
  Future<ApiResult<UserModel>> login({
    required String emailOrPhone,
    required String password,
  });
}
''';
  }

  static String loginRepositoryImpl() {
    return '''
import 'package:dio_extended/models/api_result.dart';

import '../../domain/repositories/login_repository.dart';
import '../datasources/login_remote_datasource.dart';
import '../models/user_model.dart';

class LoginRepositoryImpl implements LoginRepository {
  LoginRepositoryImpl({required this.datasource});

  final LoginRemoteDatasource datasource;

  @override
  Future<ApiResult<UserModel>> login({
    required String emailOrPhone,
    required String password,
  }) async {
    return datasource.login(
      emailOrPhone: emailOrPhone,
      password: password,
    );
  }
}
''';
  }

  static String loginUsecase() {
    return '''
import 'package:dio_extended/models/api_result.dart';

import '../../data/models/user_model.dart';
import '../repositories/login_repository.dart';

class LoginUser {
  LoginUser({required this.repository});

  final LoginRepository repository;

  Future<ApiResult<UserModel>> call({
    required String emailOrPhone,
    required String password,
  }) async {
    return repository.login(
      emailOrPhone: emailOrPhone,
      password: password,
    );
  }
}
''';
  }

  static String loginProviderClean() {
    return '''
import 'package:dio_extended/models/api_result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/extensions/datasource_refx.dart';
import '../../data/datasources/login_remote_datasource.dart';
import '../../data/repositories/login_repository_impl.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/login_repository.dart';
import '../../domain/usecases/login_user.dart';

part 'login_provider.g.dart';

@riverpod
LoginRemoteDatasource loginDatasource(Ref ref) =>
    ref.makeDatasource((conn) => LoginRemoteDatasource(conn));

@riverpod
LoginRepository loginRepository(Ref ref) => LoginRepositoryImpl(
      datasource: ref.watch(loginDatasourceProvider),
    );

@riverpod
LoginUser loginUser(Ref ref) => LoginUser(
      repository: ref.watch(loginRepositoryProvider),
    );

@riverpod
class LoginController extends _\$LoginController {
  @override
  AsyncValue<ApiResult<UserModel>> build() {
    return AsyncData(ApiResult<UserModel>.idle());
  }

  Future<void> login({
    required String emailOrPhone,
    required String password,
  }) async {
    state = const AsyncLoading();

    final usecase = ref.read(loginUserProvider);
    final result = await AsyncValue.guard(
      () => usecase(
        emailOrPhone: emailOrPhone,
        password: password,
      ),
    );

    if (!ref.mounted) return;
    state = result;
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

  static String loginProvider() {
    return '''
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Pastikan nama file sesuai, misal: login_provider.dart
part 'login_provider.g.dart'; 

@riverpod
class LoginController extends _\$LoginController {
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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:xwidgets_pack/utils/x_form_validators.dart';
import 'package:xwidgets_pack/xwidgets.dart';

import '../../../../core/l10n/string_resources.dart';
import '../widgets/auth_scaffold.dart';
import '../../../../routes/routes.dart';
import '../providers/login_form_provider.dart';
import '../providers/login_provider.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.listenManual(loginControllerProvider, (_, next) {
        next.whenOrNull(
          data: (_) {
            if (!mounted) return;
            context.go(Routes.home);
          },
          error: (err, _) {
            XSnackbar.error(err.toString());
          },
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncLogin = ref.watch(loginControllerProvider);
    final form = ref.watch(loginFormProvider);

    return AuthScaffold(
      title: R.string.homeWelcome,
      subtitle: R.string.loginTitle,
      hint: R.string.loginSubTitle,
      child: Form(
        key: form.formKey,
        child: Column(
          children: [
            TextFormField(
              controller: form.emailOrPhone,
              keyboardType: TextInputType.phone,
              decoration: AuthDecorations.field(
                label: R.string.phone,
                icon: Icons.phone_outlined,
              ),
              validator: XFormValidator.combine([
                XFormValidator.required(),
                XFormValidator.phoneNumber(),
              ]),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: form.password,
              obscureText: true,
              decoration: AuthDecorations.field(
                label: R.string.password,
                icon: Icons.lock_outline_rounded,
              ),
              validator: XFormValidator.required(),
            ),
            const SizedBox(height: 28),
            AuthPrimaryButton(
              label: R.string.login,
              isLoading: asyncLogin.isLoading,
              onPressed: () async {
                final valid = form.formKey.currentState?.validate() ?? false;
                if (!valid) return;
                await ref.read(loginControllerProvider.notifier).login(
                      emailOrPhone: form.emailOrPhone.text.trim(),
                      password: form.password.text.trim(),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}
''';
  }

  static String loginViewClean() {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:xwidgets_pack/utils/x_form_validators.dart';
import 'package:xwidgets_pack/xwidgets.dart';

import '../../../../core/l10n/string_resources.dart';
import '../widgets/auth_scaffold.dart';
import '../../../../routes/routes.dart';
import '../providers/login_form_provider.dart';
import '../providers/login_provider.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.listenManual(loginControllerProvider, (_, next) {
        next.whenOrNull(
          data: (result) {
            if (!mounted) return;
            XSnackbar.success('Result: \$result');
            context.go(Routes.home);
          },
          error: (err, _) {
            XSnackbar.error(err.toString());
          },
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncLogin = ref.watch(loginControllerProvider);
    final form = ref.watch(loginFormProvider);

    return AuthScaffold(
      title: R.string.homeWelcome,
      subtitle: R.string.loginTitle,
      hint: R.string.loginSubTitle,
      child: Form(
        key: form.formKey,
        child: Column(
          children: [
            TextFormField(
              controller: form.emailOrPhone,
              keyboardType: TextInputType.phone,
              decoration: AuthDecorations.field(
                label: R.string.phone,
                icon: Icons.phone_outlined,
              ),
              validator: XFormValidator.combine([
                XFormValidator.required(),
                XFormValidator.phoneNumber(),
              ]),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: form.password,
              obscureText: true,
              decoration: AuthDecorations.field(
                label: R.string.password,
                icon: Icons.lock_outline_rounded,
              ),
              validator: XFormValidator.required(),
            ),
            const SizedBox(height: 28),
            AuthPrimaryButton(
              label: R.string.login,
              isLoading: asyncLogin.isLoading,
              onPressed: () async {
                if (!form.formKey.currentState!.validate()) return;
                await ref.read(loginControllerProvider.notifier).login(
                      emailOrPhone: form.emailOrPhone.text,
                      password: form.password.text,
                    );
              },
            ),
          ],
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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/locale_provider.dart';
import '../widgets/home_shell.dart';
import '../../../../theme/theme_provider.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return HomeShell(
      onToggleTheme: () => ref.read(themeModeProvider.notifier).toggle(),
      onToggleLanguage: () {
        ref.read(localeProvider.notifier).state = locale.languageCode == 'en'
            ? const Locale('id')
            : const Locale('en');
      },
    );
  }
}
''';
  }
}
