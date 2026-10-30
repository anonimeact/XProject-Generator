import 'dart:math';

/// Random 32-character keys for [StorageHelper] entries in generated apps.
class SessionStorageKeys {
  SessionStorageKeys({
    required this.userData,
    required this.accessToken,
    required this.refreshToken,
    required this.phone,
    required this.sessionActive,
  });

  final String userData;
  final String accessToken;
  final String refreshToken;
  final String phone;
  final String sessionActive;

  static SessionStorageKeys generate([Random? random]) {
    final r = random ?? Random.secure();
    return SessionStorageKeys(
      userData: _randomKey(r),
      accessToken: _randomKey(r),
      refreshToken: _randomKey(r),
      phone: _randomKey(r),
      sessionActive: _randomKey(r),
    );
  }

  static String _randomKey(Random random) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
      32,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }
}
