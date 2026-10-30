import 'dart:math';

import 'package:test/test.dart';
import 'package:xproject_generator/core/configs/project_config.dart';
import 'package:xproject_generator/core/configs/session_storage_keys.dart';
import 'package:xproject_generator/src/templates/common_templates.dart';

/// Everything after the constructor part: token + refresh handling, which must
/// be byte-identical for every state management.
String _authSection(String source) {
  final start = source.indexOf('static const String _authHeaderKey');
  expect(start, greaterThan(-1), reason: 'auth section missing');
  return source.substring(start);
}

void main() {
  final variants = <String, String>{
    'getx': CommonTemplates.baseConnectionGetX(),
    'riverpod': CommonTemplates.baseConnectionRiverpod(),
    'bloc': CommonTemplates.baseConnectionBloc(),
    'provider': CommonTemplates.baseConnectionProvider(),
  };

  group('BaseConnection shared token handling', () {
    test('auth + refresh section is identical for all state managements', () {
      final reference = _authSection(variants['bloc']!);
      for (final entry in variants.entries) {
        expect(
          _authSection(entry.value),
          reference,
          reason: '${entry.key} drifted from the shared auth section',
        );
      }
    });

    for (final entry in variants.entries) {
      group(entry.key, () {
        final source = entry.value;

        test('exposes session helpers and a real refresh flow', () {
          expect(source, contains('void saveSession('));
          expect(source, contains('void clearSession()'));
          expect(source, contains('void updateAuthHeaders()'));
          expect(source, contains('UserSessions.getRefreshToken()'));
          expect(
            source,
            contains('Future<Map<String, dynamic>> handleTokenExpired()'),
          );
          expect(source, contains('_redirectToLogin();'));
          expect(source, contains('void _redirectToLogin()'));
        });

        test('never swaps the instance to refresh (DioExtended updates headers)', () {
          expect(source, isNot(contains('Get.delete')));
          expect(source, isNot(contains('static void reset()')));
          expect(source, isNot(contains('_instance = null')));
        });

        test('does not send an empty Bearer header', () {
          expect(source, contains('if (token == null || token.isEmpty) return {};'));
        });

        test('dollar signs are interpolated in the generated code', () {
          expect(source, contains(r"'Bearer $token'"));
        });
      });
    }
  });

  group('BaseConnection per state management', () {
    test('GetX: single permanent instance reachable via BaseConnection.to', () {
      final source = variants['getx']!;
      expect(source, contains('static BaseConnection get to => Get.find<BaseConnection>();'));
      expect(source, contains("import 'package:get/get.dart';"));
      expect(source, contains('Get.offAllNamed(Routes.login);'));
    });

    test('go_router stacks open login when refresh fails', () {
      for (final key in ['riverpod', 'bloc', 'provider']) {
        final source = variants[key]!;
        expect(source, contains('XSnackbar.navigatorKey.currentContext'));
        expect(source, contains('context.go(Routes.login);'));
        expect(source, isNot(contains('Get.offAllNamed')));
      }
    });

    test('Riverpod: keepAlive provider so headers are never rebuilt', () {
      final source = variants['riverpod']!;
      expect(source, contains('@Riverpod(keepAlive: true)'));
      expect(source, contains('BaseConnection baseConnection(Ref ref) => BaseConnection();'));
      expect(source, contains("part 'base_connection.g.dart';"));
      expect(source, isNot(contains('BaseConnection.create()')));
    });

    test('Bloc: lazy singleton factory', () {
      final source = variants['bloc']!;
      expect(source, contains('factory BaseConnection() => _instance;'));
      expect(source, contains('static final BaseConnection _instance'));
    });

    test('Provider: plain class injected via Provider<BaseConnection>', () {
      final source = variants['provider']!;
      expect(source, contains('  BaseConnection()\n    : super('));
      expect(source, isNot(contains('factory BaseConnection')));
      expect(source, isNot(contains('package:get/get.dart')));
      expect(source, isNot(contains('riverpod')));
    });
  });

  group('UserSessions refresh token', () {
    test('generated user session uses StorageHelper and random keys file', () {
      final body = CommonTemplates.userSessionsBloc();
      expect(body, contains('SessionStorageKeys.phone'));
      expect(body, contains('static void openSession('));
      expect(body, contains('static bool hasActiveSession()'));
      expect(body, contains('static void savePhone(String phone)'));
      expect(body, contains("import '../core/config/session_storage_keys.dart';"));
    });

    test('session storage keys file uses 32-char constants', () {
      final keys = SessionStorageKeys.generate(Random(0));
      final file = CommonTemplates.sessionStorageKeysFile(keys);
      expect(file, contains(keys.phone));
      expect(keys.phone.length, 32);
      expect(keys.sessionActive.length, 32);
    });

    test('riverpod session imports UserModel with a path that stays inside lib/', () {
      final sessions = CommonTemplates.userSessionsRiverpod();
      expect(
        sessions,
        contains("import '../features/login/data/models/user_model.dart';"),
      );
    });
  });
}
