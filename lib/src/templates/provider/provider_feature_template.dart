import '../../../core/configs/project_config.dart';
import '../common_templates.dart';

/// Templates for Provider (ChangeNotifier + provider package) feature modules.
class ProviderFeatureTemplate {
  static String generalRemoteDatasource(String featureName) {
    final pascal = CommonTemplates.pascalCase(featureName);
    return '''
import 'package:dio_extended/models/api_result.dart';

import '../../../../core/models/global_api_response.dart';
import '../../../../core/services/base_connection.dart';

class ${pascal}RemoteDatasource {
  /// Injected shared connection (provided at the app root, see app.dart).
  ${pascal}RemoteDatasource(this._connection);

  final BaseConnection _connection;

  Future<ApiResult<GlobalApiResponse>> fetch${pascal}({required String a}) async {
    final response = await _connection.callApiRequest(
      request: () => _connection.post('/api/$featureName', body: {'a': a}),
      parseData: (data) => GlobalApiResponse.fromJson(data),
    );
    return response;
  }
}
''';
  }

  static String generalState(String featureName) {
    final pascal = CommonTemplates.pascalCase(featureName);
    return '''
import 'package:dio_extended/models/api_result.dart';

import '../../../../core/models/global_api_response.dart';

class ${pascal}State {
  const ${pascal}State({
    this.isLoading = false,
    this.result,
    this.errorMessage,
  });

  final bool isLoading;
  final ApiResult<GlobalApiResponse>? result;
  final String? errorMessage;

  ${pascal}State copyWith({
    bool? isLoading,
    ApiResult<GlobalApiResponse>? result,
    String? errorMessage,
  }) {
    return ${pascal}State(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      errorMessage: errorMessage,
    );
  }
}
''';
  }

  static String generalNotifier(String featureName) {
    final pascal = CommonTemplates.pascalCase(featureName);
    final snake = featureName.toLowerCase();
    return '''
import 'package:flutter/foundation.dart';

import '../../data/datasources/${snake}_remote_datasource.dart';
import '${snake}_state.dart';

class ${pascal}Notifier extends ChangeNotifier {
  ${pascal}Notifier({required this.remoteDatasource});

  final ${pascal}RemoteDatasource remoteDatasource;

  ${pascal}State _state = const ${pascal}State();
  ${pascal}State get state => _state;

  Future<void> start() async {
    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();
    try {
      final result = await remoteDatasource.fetch${pascal}(a: 'example');
      _state = _state.copyWith(isLoading: false, result: result);
    } catch (e) {
      _state = _state.copyWith(isLoading: false, errorMessage: e.toString());
    }
    notifyListeners();
  }
}
''';
  }

  static String generalView(String featureName) {
    final pascal = CommonTemplates.pascalCase(featureName);
    final snake = featureName.toLowerCase();
    return '''
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/base_connection.dart';
import '../../data/datasources/${snake}_remote_datasource.dart';
import '../notifiers/${snake}_notifier.dart';

class ${pascal}View extends StatelessWidget {
  const ${pascal}View({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ${pascal}Notifier(
        remoteDatasource: ${pascal}RemoteDatasource(ctx.read<BaseConnection>()),
      )..start(),
      child: Consumer<${pascal}Notifier>(
        builder: (context, notifier, _) {
          final state = notifier.state;
          if (state.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state.errorMessage != null) {
            return Scaffold(
              body: Center(child: Text(state.errorMessage!)),
            );
          }

          if (state.result != null) {
            return Scaffold(
              body: Center(child: Text('Result: \${state.result}')),
            );
          }

          return Scaffold(
            appBar: AppBar(title: const Text('$pascal')),
            body: const Center(child: Text('This is $pascal View')),
          );
        },
      ),
    );
  }
}
''';
  }

  static String splashNotifier(ProjectConfig config) {
    return '''
import 'package:flutter/foundation.dart';
${config.useFirebase ? "import 'package:flutter/material.dart';\nimport '../../../../core/services/firebase/firebase_service.dart';" : ''}

class SplashNotifier extends ChangeNotifier {
  bool _isFinished = false;
  bool get isFinished => _isFinished;

  SplashNotifier() {
    _start();
  }

  Future<void> _start() async {
${config.useFirebase ? '''    final stopwatch = Stopwatch()..start();
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
''' : '    await Future.delayed(const Duration(seconds: 3));\n'}
    _isFinished = true;
    notifyListeners();
  }
}
''';
  }

  static String splashView() {
    return '''
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../routes/routes.dart';
import '../../../../sessions/user_session.dart';
import '../notifiers/splash_notifier.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  var _didRoute = false;

  void _routeAfterSplash(BuildContext context) {
    if (_didRoute || !context.mounted) return;
    _didRoute = true;
    final destination =
        UserSessions.hasActiveSession() ? Routes.home : Routes.login;
    context.go(destination);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SplashNotifier(),
      child: Consumer<SplashNotifier>(
        builder: (context, notifier, _) {
          if (notifier.isFinished && !_didRoute) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _routeAfterSplash(context);
            });
          }
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
        },
      ),
    );
  }
}
''';
  }

  static String loginRemoteDatasource() {
    return '''
${CommonTemplates.loginRemoteDatasourceFileHeader()}
import 'package:dio_extended/models/api_result.dart';

import '../../../../core/models/global_api_response.dart';
import '../../../../core/services/base_connection.dart';

class LoginRemoteDatasource {
  /// Injected shared connection (provided at the app root, see app.dart).
  LoginRemoteDatasource(this._connection);

  final BaseConnection _connection;

  /// After a successful login, store the tokens on the shared connection so
  /// every next request is authenticated and can be refreshed:
  /// `_connection.saveSession(token: ..., refreshToken: ...)`.
  Future<ApiResult<GlobalApiResponse>> login({
    required String emailOrPhone,
    required String password,
  }) async {
    return _connection.callApiRequest(
      request: () => _connection.post(
        '/api/login',
        body: {
          'emailOrPhone': emailOrPhone,
          'password': password,
        },
      ),
      parseData: (data) => GlobalApiResponse.fromJson(data),
    );
  }
}
''';
  }

  static String loginState() {
    return '''
import 'package:dio_extended/models/api_result.dart';

import '../../../../core/models/global_api_response.dart';

class LoginState {
  const LoginState({
    this.isLoading = false,
    this.isSuccess = false,
    this.isPasswordObscured = true,
    this.result,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isSuccess;
  final bool isPasswordObscured;
  final ApiResult<GlobalApiResponse>? result;
  final String? errorMessage;

  LoginState copyWith({
    bool? isLoading,
    bool? isSuccess,
    bool? isPasswordObscured,
    ApiResult<GlobalApiResponse>? result,
    String? errorMessage,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isPasswordObscured: isPasswordObscured ?? this.isPasswordObscured,
      result: result ?? this.result,
      errorMessage: errorMessage,
    );
  }
}
''';
  }

  static String loginNotifier() {
    return '''
import 'package:flutter/foundation.dart';

import '../../../../core/services/base_connection.dart';
import '../../../../sessions/user_session.dart';
import '../../data/models/user_model.dart';
import '../../data/datasources/login_remote_datasource.dart';
import 'login_state.dart';

class LoginNotifier extends ChangeNotifier {
  LoginNotifier({required this.remoteDatasource, required this.connection});

  final LoginRemoteDatasource remoteDatasource;
  final BaseConnection connection;

  LoginState _state = const LoginState();
  LoginState get state => _state;

  Future<void> submit({
    required String emailOrPhone,
    required String password,
  }) async {
    _state = _state.copyWith(
      isLoading: true,
      errorMessage: null,
      isSuccess: false,
    );
    notifyListeners();
    try {
${CommonTemplates.demoLoginBypassBlock(
  phoneExpression: 'emailOrPhone',
  connectionExpression: 'connection',
  realApiSnippet: '''
    // final result = await remoteDatasource.login(
    //   emailOrPhone: emailOrPhone,
    //   password: password,
    // );
    // if (!result.isSuccess) {
    //   throw StateError(result.message ?? 'Login failed');
    // }
    // UserSessions.openSession(...); connection.saveSession(...);
''',
  trailingLines: '''
      _state = _state.copyWith(
        isLoading: false,
        isSuccess: true,
        errorMessage: null,
      );''',
)}
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _state = _state.copyWith(
      isPasswordObscured: !_state.isPasswordObscured,
      errorMessage: _state.errorMessage,
    );
    notifyListeners();
  }
}
''';
  }

  static String loginView() {
    return '''
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/string_resources.dart';
import '../widgets/auth_scaffold.dart';
import '../../../../core/services/base_connection.dart';
import '../../../../routes/routes.dart';
import '../../data/datasources/login_remote_datasource.dart';
import '../notifiers/login_notifier.dart';
import '../notifiers/login_state.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  var _handledSuccess = false;
  String? _lastErrorMessage;

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginState(BuildContext context, LoginState state) {
    if (state.isSuccess && !_handledSuccess) {
      _handledSuccess = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.go(Routes.home);
      });
    }
    // REAL API: uncomment to show login failures from [LoginNotifier] (network, 4xx, etc.).
    // final message = state.errorMessage;
    // if (message != null && message != _lastErrorMessage) {
    //   _lastErrorMessage = message;
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     if (!mounted) return;
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text(message)),
    //     );
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => LoginNotifier(
        remoteDatasource: LoginRemoteDatasource(ctx.read<BaseConnection>()),
        connection: ctx.read<BaseConnection>(),
      ),
      child: Consumer<LoginNotifier>(
        builder: (context, notifier, _) {
          _onLoginState(context, notifier.state);
          final state = notifier.state;
          return AuthScaffold(
            title: R.string.homeWelcome,
            subtitle: R.string.loginTitle,
            hint: R.string.loginSubTitle,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailOrPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: AuthDecorations.field(
                      label: R.string.phone,
                      icon: Icons.phone_outlined,
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: state.isPasswordObscured,
                    decoration: AuthDecorations.field(
                      label: R.string.password,
                      icon: Icons.lock_outline_rounded,
                      suffixIcon: IconButton(
                        onPressed: notifier.togglePasswordVisibility,
                        icon: Icon(
                          state.isPasswordObscured
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 28),
                  AuthPrimaryButton(
                    label: R.string.login,
                    isLoading: state.isLoading,
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;
                      notifier.submit(
                        emailOrPhone: _emailOrPhoneController.text,
                        password: _passwordController.text,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
''';
  }

  static String homeView() {
    return '''
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app.dart';
import '../../../../core/services/base_connection.dart';
import '../../../../routes/routes.dart';
import '../../../../sessions/user_session.dart';
import '../widgets/home_shell.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeShell(
      onToggleTheme: () => context.read<AppNotifier>().toggleTheme(),
      onToggleLanguage: () => context.read<AppNotifier>().toggleLanguage(),
      onLogout: () {
${CommonTemplates.goRouterLogoutBody(connectionExpression: 'context.read<BaseConnection>()')}
      },
    );
  }
}
''';
  }
}
