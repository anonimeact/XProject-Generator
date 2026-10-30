import 'dart:math';

import 'package:test/test.dart';
import 'package:xproject_generator/core/configs/session_storage_keys.dart';

void main() {
  test('generate produces five unique 32-character keys', () {
    final keys = SessionStorageKeys.generate(Random(42));
    final values = [
      keys.userData,
      keys.accessToken,
      keys.refreshToken,
      keys.phone,
      keys.sessionActive,
    ];
    expect(values.every((k) => k.length == 32), isTrue);
    expect(values.toSet().length, values.length);
  });
}
