import 'dart:io';

import 'package:interact/interact.dart';

/// Reads a line using the shell's line editor ([stdin.readLineSync]).
///
/// Unlike [Input] from `interact`, this does not cap input length to the
/// terminal width at prompt time, so typing wraps and resizing the terminal
/// still allows editing the full line.
String promptLine({
  required String prompt,
  String? defaultValue,
  bool Function(String)? validator,
  Theme? theme,
}) {
  final resolvedTheme = theme ?? Theme.defaultTheme;
  while (true) {
    final prefix = StringBuffer()
      ..write(resolvedTheme.inputPrefix)
      ..write(resolvedTheme.messageStyle(prompt));
    if (defaultValue != null) {
      prefix
        ..write(' ')
        ..write(resolvedTheme.hintStyle(defaultValue));
    }
    prefix
      ..write(resolvedTheme.inputSuffix)
      ..write(' ');

    stdout.write(prefix.toString());

    final raw = stdin.readLineSync() ?? '';
    final line = raw.isEmpty && defaultValue != null ? defaultValue : raw;

    if (validator != null && !validator(line)) {
      continue;
    }

    stdout.writeln(
      '${resolvedTheme.successPrefix}'
      '${resolvedTheme.messageStyle(prompt)}'
      '${resolvedTheme.successSuffix}'
      '${resolvedTheme.valueStyle(' $line ')}',
    );

    return line;
  }
}
