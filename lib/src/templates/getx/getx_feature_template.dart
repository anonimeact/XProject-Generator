import '../../../core/configs/project_config.dart';
import '../common_templates.dart';

/// XProject Generator - GetX Feature Templates
///
/// Provides static methods to generate Dart code templates for GetX feature modules (bindings, controllers, views, providers, models)
/// and for common features like login, splash, and home.
///
/// See README.md for more details.
class GetxFeatureTemplate {

  /// Returns the Dart code for a GetX Binding class for a given [featureName].
  static String generalBinding(String featureName) {
    final pascal = CommonTemplates.pascalCase(featureName);
    final snake = featureName.toLowerCase();

    return '''
import 'package:get/get.dart';

import '../controllers/${snake}_controller.dart';
import '../providers/${snake}_provider.dart';

class ${pascal}Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<${pascal}Provider>(() => ${pascal}Provider());
    Get.lazyPut<${pascal}Controller>(() => ${pascal}Controller(
          provider: Get.find<${pascal}Provider>(),
        ));
  }
}
''';
  }

  /// Returns the Dart code for a GetX Controller class for a given [featureName].
  static String generalController(String featureName) {
    final pascal = CommonTemplates.pascalCase(featureName);
    final snake = featureName.toLowerCase();

    return '''
import 'package:get/get.dart';

import '../providers/${snake}_provider.dart';

class ${pascal}Controller extends GetxController {
  ${pascal}Controller({
    required this.provider,
  });

  final ${pascal}Provider provider;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> onRefresh() async {}

  void toggleLoading() {
    isLoading.value = !isLoading.value;
  }
}
''';
  }

  /// Returns the Dart code for a GetX View class for a given [featureName].
  static String generalView(String featureName) {
    final pascal = CommonTemplates.pascalCase(featureName);

    return '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/${featureName}_controller.dart';

class ${pascal}View extends GetView<${pascal}Controller> {
  const ${pascal}View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('$pascal')),
      body: Obx(
        () => Center(
          child: controller.isLoading.value
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('This is $pascal View')
                  ],
                ),
        ),
      ),
    );
  }
}
''';
  }

  /// Returns the Dart code for a GetX Provider class for a given [featureName].
  static String generalProvider(String featureName) {
    final pascal = CommonTemplates.pascalCase(featureName);

    return '''
import '../../../core/services/base_connection.dart';

class ${pascal}Provider extends BaseConnection {}
''';
  }

  /// ==== Login Feature Template ====

  /// Returns the Dart code for the LoginProvider class.
  static String loginProvider() {
    return '''
import 'package:dio_extended/models/api_result.dart';
import '../../../core/services/base_connection.dart';
import '../models/user_model.dart';

class LoginProvider extends BaseConnection {
  Future<ApiResult<UserModel>> login(dynamic body) async {
    return callApiRequest<UserModel>(
      request: () => post('/api/login', body: body),
      parseData: (data) => UserModel.fromJson(data),
    );
  }
}
''';
  }

  /// Returns the Dart code for the LoginController class.
  static String loginController() {
    return '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../providers/login_provider.dart';

class LoginController extends GetxController {

  late LoginProvider loginProvider;

  LoginController({required this.loginProvider});

  final formKey = GlobalKey<FormState>();
  final emailOrPhoneController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final obscurePassword = true.obs;

  @override
  void onClose() {
    emailOrPhoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      // await loginProvider.login({'emailOrPhone': emailOrPhoneController.text, 'password': passwordController.text});

      // Navigate to home
      Get.offAllNamed(Routes.home);
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
''';
  }

  /// Returns the Dart code for the LoginView class.
  static String loginView() {
    return '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xwidgets_pack/utils/x_form_validators.dart';
import 'package:xwidgets_pack/xwidgets.dart';
import '../../../core/l10n/string_resources.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Obx(() {
        return XCard(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Form(
              key: controller.formKey,
              child: Column(
                mainAxisAlignment: .center,
                crossAxisAlignment: .center,
                children: [
                  Text(R.string.loginTitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(R.string.loginSubTitle, style: const TextStyle()),
                  XHeight(16),
                  XTextField(
                    labelOnLine: R.string.phone,
                    controller: controller.emailOrPhoneController,
                    validator: XFormValidator.combine([XFormValidator.required(), XFormValidator.phoneNumber()]),
                  ),
                  XTextField(
                    labelOnLine: R.string.password,
                    isObscureText: true,
                    controller: controller.passwordController,
                    validator: XFormValidator.required(),
                  ),
                  XHeight(16),
                  XButton(
                    width: 300,
                    isLoading: controller.isLoading.value,
                    onPressed: controller.login,
                    child: Text(R.string.login),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
''';
  }

  /// Returns the Dart code for the LoginBinding class.
  static String loginBinding() {
    return '''
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../providers/login_provider.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginProvider>(() => LoginProvider());
    Get.lazyPut<LoginController>(() => LoginController(loginProvider: Get.find()));
  }
}
''';
  }

  /// ==== Splash Feature Template ====
  /// Returns the Dart code for the SplashBinding class.
  static String splashBinding() {
    return '''
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SplashController>(SplashController());
  }
}
''';
  }

  /// Returns the Dart code for the SplashController class.
  static String splashController(ProjectConfig config) {
    return '''
import 'package:get/get.dart';
${config.useFirebase ? '''
import 'package:flutter/material.dart';
import '../../../core/services/firebase/firebase_service.dart';
''' : ''}
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _start();
  }

  Future<void> _start() async {
    ${config.useFirebase ? '''final stopwatch = Stopwatch()..start();
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

    Get.offAllNamed(Routes.login);
  }
}
''';
  }

  /// Returns the Dart code for the SplashView class.
  static String splashView() {
    return '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
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

  /// ==== Home Feature Template ====
  /// Returns the Dart code for the HomeController class.
  static String homeController() {
    return '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../providers/home_provider.dart';

class HomeController extends GetxController {
  HomeController({
    required this.provider,
  });

  final HomeProvider provider;

  final isDark = false.obs;
  void toggleTheme() {
    isDark.value = !isDark.value;
    Get.changeThemeMode(isDark.value ? ThemeMode.dark : ThemeMode.light);
  }
  final locale = const Locale('en').obs;

  void toggleLanguage() {
    if (locale.value.languageCode == 'en') {
      locale.value = const Locale('id');
      Get.updateLocale(const Locale('id'));
    } else {
      locale.value = const Locale('en');
      Get.updateLocale(const Locale('en'));
    }
  }
}
''';
  }

  /// Returns the Dart code for the HomeBinding class.
  static String homeBinding() {
    return '''
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../providers/home_provider.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeProvider>(() => HomeProvider());
    Get.lazyPut<HomeController>(() => HomeController(provider: Get.find<HomeProvider>()));
  }
}
''';
  }

  /// Returns the Dart code for the HomeView class.
  static String homeView() {
    return '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/l10n/string_resources.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(R.string.homeView),
        actions: [
          IconButton(icon: const Icon(Icons.brightness_6), onPressed: controller.toggleTheme),
          IconButton(icon: const Icon(Icons.language), onPressed: controller.toggleLanguage),
        ],
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('Welcome Home :)')]),
      ),
    );
  }
}
''';
  }
}
