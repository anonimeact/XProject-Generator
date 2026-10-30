import 'setup_change_report.dart';

/// Inserts dependency lines into an existing `pubspec.yaml`.
///
/// Lines are matched by package name (`firebase_core`, not the version), so
/// running setup twice does not duplicate a dependency the project already has.
abstract final class PubspecEditor {
  /// Returns [pubspec] with any missing [dependencyLines] inserted immediately
  /// above `dev_dependencies:`.
  ///
  /// Throws [SetupException] when the file has no `dev_dependencies:` key,
  /// because that is where the dependencies section is expected to end.
  static String addDependencies(String pubspec, List<String> dependencyLines) {
    final missing = <String>[];
    for (final line in dependencyLines) {
      final name = _packageName(line);
      if (name == null) {
        continue;
      }
      if (_declaresPackage(pubspec, name)) {
        continue;
      }
      missing.add(line);
    }
    if (missing.isEmpty) {
      return pubspec;
    }

    final dev = RegExp(r'^dev_dependencies:\s*$', multiLine: true);
    final match = dev.firstMatch(pubspec);
    if (match == null) {
      throw SetupException(
        'pubspec.yaml has no dev_dependencies: section, so Firebase packages '
        'could not be inserted safely.',
      );
    }

    final prefix = pubspec.substring(0, match.start);
    final needsLeadingBlank = !prefix.endsWith('\n\n');
    final insertion =
        '${needsLeadingBlank ? '\n' : ''}${missing.join('\n')}\n\n';
    return pubspec.replaceRange(match.start, match.start, insertion);
  }

  static String? _packageName(String line) {
    final match = RegExp(r'^\s*([A-Za-z0-9_]+):\s+\S').firstMatch(line);
    return match?.group(1);
  }

  static bool _declaresPackage(String pubspec, String name) {
    return RegExp(
      '^\\s*${RegExp.escape(name)}:\\s+\\S',
      multiLine: true,
    ).hasMatch(pubspec);
  }
}
