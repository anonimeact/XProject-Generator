import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('create/setup wizard prompts are English only', () {
    final source = File('lib/src/wizard_inputs.dart').readAsStringSync();
    const forbidden = [
      'CI saja',
      'Pilih minimal',
      'PC lokal',
      'Flutter di PATH',
      'Hanya artifact',
      'tanpa upload',
      'image Flutter',
    ];
    for (final phrase in forbidden) {
      expect(source, isNot(contains(phrase)), reason: phrase);
    }
    expect(source, contains('CI only (analyze & test)'));
    expect(source, contains('Artifacts only (no upload)'));
  });

  test('generated README template is English only', () {
    final source =
        File('lib/src/templates/project_readme_template.dart').readAsStringSync();
    expect(source, isNot(contains('Mulai di sini')));
    expect(source, isNot(contains('Proyek Flutter')));
    expect(source, contains('Start here'));
  });
}
