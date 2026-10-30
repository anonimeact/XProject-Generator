import 'package:test/test.dart';
import 'package:xproject_generator/core/package_version.dart';

void main() {
  test('readPackageVersion returns pubspec version', () async {
    final version = await readPackageVersion();
    expect(version, isNot('unknown'));
    expect(version, matches(RegExp(r'^\d+\.\d+\.\d+')));
  });
}
