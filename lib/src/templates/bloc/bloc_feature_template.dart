import '../../../core/configs/project_config.dart';
import '../common_templates.dart';

/// XProject Generator - Bloc Feature Templates
///
/// Provides static methods to generate Dart code templates for Bloc feature modules
/// following a clean architecture structure (data/domain/presentation).
class BlocFeatureTemplate {
  /// ==== General Feature Templates ====

  static String generalEntity(String featureName) {
    final pascal = CommonTemplates.pascalCase(featureName);
    return '''
import 'package:equatable/equatable.dart';

class ${pascal}Entity extends Equatable {
  const ${pascal}Entity({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}
''';
  }

  static String generalRepository(String featureName) {
    final pascal = CommonTemplates.pascalCase(featureName);
    return '''
import 'package:dio_extended/models/api_result.dart';

import '../../../../core/models/global_api_response.dart';

abstract class ${pascal}Repository {
  Future<ApiResult<GlobalApiResponse>> fetch${pascal}({required String a});
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
import '../datasources/${snake}_remote_datasource.dart';

class ${pascal}RepositoryImpl implements ${pascal}Repository {
  ${pascal}RepositoryImpl({required this.remoteDatasource});

  final ${pascal}RemoteDatasource remoteDatasource;

  @override
  Future<ApiResult<GlobalApiResponse>> fetch${pascal}({required String a}) async {
    return remoteDatasource.fetch${pascal}(a: a);
  }
}
''';
  }

  static String generalRemoteDatasource(String featureName) {
    final pascal = CommonTemplates.pascalCase(featureName);
    return '''
import 'package:dio_extended/models/api_result.dart';

import '../../../../core/models/global_api_response.dart';
import '../../../../core/services/base_connection.dart';

class ${pascal}RemoteDatasource {
  final _connection = BaseConnection();

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

  static String generalUsecase(String featureName) {
    final pascal = CommonTemplates.pascalCase(featureName);
    final snake = featureName.toLowerCase();
    return '''
import '../repositories/${snake}_repository.dart';
import '../../../../core/models/global_api_response.dart';
import 'package:dio_extended/models/api_result.dart';

class Get${pascal} {
  Get${pascal}({required this.repository});

  final ${pascal}Repository repository;

  Future<ApiResult<GlobalApiResponse>> call({required String a}) async {
    return repository.fetch${pascal}(a: a);
  }
}
''';
  }

  static String generalEvent(String featureName) {
    final pascal = CommonTemplates.pascalCase(featureName);
    return '''
import 'package:equatable/equatable.dart';

abstract class ${pascal}Event extends Equatable {
  const ${pascal}Event();

  @override
  List<Object?> get props => [];
}

class ${pascal}Started extends ${pascal}Event {
  const ${pascal}Started();
}
''';
  }

  static String generalState(String featureName) {
    final pascal = CommonTemplates.pascalCase(featureName);
    return '''
import 'package:equatable/equatable.dart';
import 'package:dio_extended/models/api_result.dart';

import '../../../../core/models/global_api_response.dart';

class ${pascal}State extends Equatable {
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

  @override
  List<Object?> get props => [isLoading, result, errorMessage];
}
''';
  }

  static String generalBloc(String featureName) {
    final pascal = CommonTemplates.pascalCase(featureName);
    final snake = featureName.toLowerCase();
    return '''
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_${snake}.dart';
import '${snake}_event.dart';
import '${snake}_state.dart';

class ${pascal}Bloc extends Bloc<${pascal}Event, ${pascal}State> {
  ${pascal}Bloc({required this.get${pascal}}) : super(const ${pascal}State()) {
    on<${pascal}Started>(_onStarted);
  }

  final Get${pascal} get${pascal};

  Future<void> _onStarted(
    ${pascal}Started event,
    Emitter<${pascal}State> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final result = await get${pascal}(a: 'example');
      emit(state.copyWith(isLoading: false, result: result));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
''';
  }

  static String generalView(String featureName) {
    final pascal = CommonTemplates.pascalCase(featureName);
    final snake = featureName.toLowerCase();
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/${snake}_remote_datasource.dart';
import '../../data/repositories/${snake}_repository_impl.dart';
import '../../domain/usecases/get_${snake}.dart';
import '../bloc/${snake}_bloc.dart';
import '../bloc/${snake}_event.dart';
import '../bloc/${snake}_state.dart';

class ${pascal}View extends StatelessWidget {
  const ${pascal}View({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ${pascal}Bloc(
        get${pascal}: Get${pascal}(
          repository: ${pascal}RepositoryImpl(
            remoteDatasource: ${pascal}RemoteDatasource(),
          ),
        ),
      )..add(const ${pascal}Started()),
      child: Scaffold(
        appBar: AppBar(title: const Text('$pascal')),
        body: BlocBuilder<${pascal}Bloc, ${pascal}State>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.errorMessage != null) {
              return Center(child: Text(state.errorMessage!));
            }

            if (state.result != null) {
              return Center(child: Text('Result: \${state.result}'));
            }

            return const Center(child: Text('This is $pascal View'));
          },
        ),
      ),
    );
  }
}
''';
  }

  static String generalBlocSimple(String featureName) {
    final pascal = CommonTemplates.pascalCase(featureName);
    final snake = featureName.toLowerCase();
    return '''
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/${snake}_remote_datasource.dart';
import '${snake}_event.dart';
import '${snake}_state.dart';

class ${pascal}Bloc extends Bloc<${pascal}Event, ${pascal}State> {
  ${pascal}Bloc({required this.remoteDatasource}) : super(const ${pascal}State()) {
    on<${pascal}Started>(_onStarted);
  }

  final ${pascal}RemoteDatasource remoteDatasource;

  Future<void> _onStarted(
    ${pascal}Started event,
    Emitter<${pascal}State> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final result = await remoteDatasource.fetch${pascal}(a: 'example');
      emit(state.copyWith(isLoading: false, result: result));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
''';
  }

  static String generalViewSimple(String featureName) {
    final pascal = CommonTemplates.pascalCase(featureName);
    final snake = featureName.toLowerCase();
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/${snake}_remote_datasource.dart';
import '../bloc/${snake}_bloc.dart';
import '../bloc/${snake}_event.dart';
import '../bloc/${snake}_state.dart';

class ${pascal}View extends StatelessWidget {
  const ${pascal}View({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ${pascal}Bloc(
        remoteDatasource: ${pascal}RemoteDatasource(),
      )..add(const ${pascal}Started()),
      child: Scaffold(
        appBar: AppBar(title: const Text('$pascal')),
        body: BlocBuilder<${pascal}Bloc, ${pascal}State>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.errorMessage != null) {
              return Center(child: Text(state.errorMessage!));
            }

            if (state.result != null) {
              return Center(child: Text('Result: \${state.result}'));
            }

            return const Center(child: Text('This is $pascal View'));
          },
        ),
      ),
    );
  }
}
''';
  }

  /// ==== Splash Feature Templates ====

  static String splashEvent() {
    return '''
import 'package:equatable/equatable.dart';

abstract class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object?> get props => [];
}

class SplashStarted extends SplashEvent {
  const SplashStarted();
}
''';
  }

  static String splashState() {
    return '''
import 'package:equatable/equatable.dart';

class SplashState extends Equatable {
  const SplashState({this.isFinished = false});

  final bool isFinished;

  SplashState copyWith({bool? isFinished}) {
    return SplashState(isFinished: isFinished ?? this.isFinished);
  }

  @override
  List<Object?> get props => [isFinished];
}
''';
  }

  static String splashBloc(ProjectConfig config) {
    return '''
import 'package:flutter_bloc/flutter_bloc.dart';
${config.useFirebase ? "import 'package:flutter/material.dart';\nimport '../../../../core/services/firebase/firebase_service.dart';" : ''}

import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(const SplashState()) {
    on<SplashStarted>(_onStarted);
  }

  Future<void> _onStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
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
    emit(state.copyWith(isFinished: true));
  }
}
''';
  }

  static String splashView() {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes/routes.dart';
import '../bloc/splash_bloc.dart';
import '../bloc/splash_event.dart';
import '../bloc/splash_state.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SplashBloc()..add(const SplashStarted()),
      child: BlocListener<SplashBloc, SplashState>(
        listenWhen: (previous, current) => current.isFinished,
        listener: (context, state) {
          context.go(Routes.login);
        },
        child: const Scaffold(
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
        ),
      ),
    );
  }
}
''';
  }

  /// ==== Login Feature Templates ====

  static String loginRemoteDatasource() {
    return '''
import 'package:dio_extended/models/api_result.dart';

import '../../../../core/models/global_api_response.dart';
import '../../../../core/services/base_connection.dart';

class LoginRemoteDatasource {
  final _connection = BaseConnection();

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

  static String loginRepository() {
    return '''
import 'package:dio_extended/models/api_result.dart';

import '../../../../core/models/global_api_response.dart';

abstract class LoginRepository {
  Future<ApiResult<GlobalApiResponse>> login({
    required String emailOrPhone,
    required String password,
  });
}
''';
  }

  static String loginRepositoryImpl() {
    return '''
import 'package:dio_extended/models/api_result.dart';

import '../../../../core/models/global_api_response.dart';
import '../../domain/repositories/login_repository.dart';
import '../datasources/login_remote_datasource.dart';

class LoginRepositoryImpl implements LoginRepository {
  LoginRepositoryImpl({required this.remoteDatasource});

  final LoginRemoteDatasource remoteDatasource;

  @override
  Future<ApiResult<GlobalApiResponse>> login({
    required String emailOrPhone,
    required String password,
  }) async {
    return remoteDatasource.login(
      emailOrPhone: emailOrPhone,
      password: password,
    );
  }
}
''';
  }

  static String loginUsecase() {
    return '''
import '../repositories/login_repository.dart';
import '../../../../core/models/global_api_response.dart';
import 'package:dio_extended/models/api_result.dart';

class LoginUser {
  LoginUser({required this.repository});

  final LoginRepository repository;

  Future<ApiResult<GlobalApiResponse>> call({
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

  static String loginEvent() {
    return '''
import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends LoginEvent {
  const LoginSubmitted({required this.emailOrPhone, required this.password});

  final String emailOrPhone;
  final String password;

  @override
  List<Object?> get props => [emailOrPhone, password];
}

class LoginTogglePassword extends LoginEvent {
  const LoginTogglePassword();
}
''';
  }

  static String loginState() {
    return '''
import 'package:equatable/equatable.dart';
import 'package:dio_extended/models/api_result.dart';

import '../../../../core/models/global_api_response.dart';

class LoginState extends Equatable {
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

  @override
  List<Object?> get props => [isLoading, isSuccess, isPasswordObscured, result, errorMessage];
}
''';
  }

  static String loginBloc() {
    return '''
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/login_remote_datasource.dart';
import '../../data/repositories/login_repository_impl.dart';
import '../../domain/usecases/login_user.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc()
      : _loginUser = LoginUser(
          repository: LoginRepositoryImpl(
            remoteDatasource: LoginRemoteDatasource(),
          ),
        ),
        super(const LoginState()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginTogglePassword>(_onTogglePassword);
  }

  final LoginUser _loginUser;

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null, isSuccess: false));
    try {
      final result = await _loginUser(
        emailOrPhone: event.emailOrPhone,
        password: event.password,
      );
      emit(state.copyWith(isLoading: false, isSuccess: true, result: result));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onTogglePassword(
    LoginTogglePassword event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(isPasswordObscured: !state.isPasswordObscured));
  }
}
''';
  }

  static String loginBlocSimple() {
    return '''
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/login_remote_datasource.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({required this.remoteDatasource}) : super(const LoginState()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginTogglePassword>(_onTogglePassword);
  }

  final LoginRemoteDatasource remoteDatasource;

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null, isSuccess: false));
    try {
      final result = await remoteDatasource.login(
        emailOrPhone: event.emailOrPhone,
        password: event.password,
      );
      emit(state.copyWith(isLoading: false, isSuccess: true, result: result));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onTogglePassword(
    LoginTogglePassword event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(isPasswordObscured: !state.isPasswordObscured));
  }
}
''';
  }

  static String loginView() {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes/routes.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(),
      child: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.result != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Result: \${state.result}')),
            );
          }
          if (state.isSuccess) {
            context.go(Routes.home);
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Login')),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _emailOrPhoneController,
                      decoration: const InputDecoration(labelText: 'Email or Phone'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: state.isPasswordObscured,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          onPressed: () => context.read<LoginBloc>().add(const LoginTogglePassword()),
                          icon: Icon(
                            state.isPasswordObscured
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.isLoading
                            ? null
                            : () {
                                if (!_formKey.currentState!.validate()) return;
                                context.read<LoginBloc>().add(
                                      LoginSubmitted(
                                        emailOrPhone: _emailOrPhoneController.text,
                                        password: _passwordController.text,
                                      ),
                                    );
                              },
                        child: state.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Login'),
                      ),
                    ),
                  ],
                ),
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

  static String loginViewSimple() {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes/routes.dart';
import '../../data/datasources/login_remote_datasource.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(remoteDatasource: LoginRemoteDatasource()),
      child: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.isSuccess) {
            context.go(Routes.home);
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Login')),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _emailOrPhoneController,
                      decoration: const InputDecoration(labelText: 'Email or Phone'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: state.isPasswordObscured,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          onPressed: () => context.read<LoginBloc>().add(const LoginTogglePassword()),
                          icon: Icon(
                            state.isPasswordObscured
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.isLoading
                            ? null
                            : () {
                                if (!_formKey.currentState!.validate()) return;
                                context.read<LoginBloc>().add(
                                      LoginSubmitted(
                                        emailOrPhone: _emailOrPhoneController.text,
                                        password: _passwordController.text,
                                      ),
                                    );
                              },
                        child: state.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Login'),
                      ),
                    ),
                  ],
                ),
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
}
