import 'package:test/test.dart';
import 'package:xproject_generator/src/templates/guide/markdown_github_slug.dart';

void main() {
  test('matches github-slugger for GUIDE headings', () {
    final b = MarkdownPreviewSlugBuilder();
    final expected = [
      'panduan-setup-app',
      'daftar-isi',
      'bagian-1-memahami-proyek',
      'bagian-2-konfigurasi-yang-perlu-diselesaikan',
      'bagian-1-memahami-proyek-1',
      '1-prasyarat--cek-lingkungan',
      '1-langkah-awal--dependency',
      '7-vs-code-run--build',
      '2-file-environment-env',
    ];
    final headings = [
      'Panduan setup: App',
      'Daftar isi',
      'Bagian 1: Memahami proyek',
      'Bagian 2: Konfigurasi yang perlu diselesaikan',
      'Bagian 1: Memahami proyek',
      '1. Prasyarat & cek lingkungan',
      '1. Langkah awal & dependency',
      '7. VS Code: run & build',
      '2. File environment (`.env`)',
    ];
    for (var i = 0; i < headings.length; i++) {
      expect(b.add(headings[i]), expected[i], reason: headings[i]);
    }
  });
}
