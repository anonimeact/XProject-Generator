import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:mason_logger/mason_logger.dart';

const _brailleFrames = [
  '⠋',
  '⠙',
  '⠹',
  '⠸',
  '⠼',
  '⠴',
  '⠦',
  '⠧',
  '⠇',
  '⠏',
];

/// Maps elapsed time to a percentage in [[progressMin], [progressMax]), capped below [progressMax].
int stepProgressPercent({
  required int elapsedMs,
  required int progressMin,
  required int progressMax,
}) {
  final range = progressMax - progressMin;
  if (range <= 1) return progressMin;
  const rampMs = 20000;
  final t = math.min(1.0, elapsedMs / rampMs);
  final eased = 1 - math.pow(1 - t, 2).toDouble();
  final inner = (range * eased * 0.92).floor();
  return math.min(progressMax - 1, progressMin + inner);
}

String _formatDuration(Duration elapsed) {
  final ms = elapsed.inMilliseconds;
  if (ms < 1000) return '${ms}ms';
  return '${(ms / 1000).toStringAsFixed(1)}s';
}

/// Runs [action] with spinner + overall progress percentage on the right.
Future<T> runWithStepProgress<T>(
  Logger logger,
  String label,
  String leadingIcon,
  Future<T> Function() action, {
  int progressMin = 0,
  int progressMax = 100,
}) async {
  if (logger.level.index > Level.info.index) {
    return action();
  }

  final out = stdout;
  final stopwatch = Stopwatch()..start();
  var frameIndex = 0;
  Timer? timer;

  void render({required int percent, required bool done, Duration? elapsed}) {
    final prefix = done
        ? '${lightGreen.wrap('✓')} $leadingIcon'
        : '${lightGreen.wrap('${leadingIcon} ${_brailleFrames[frameIndex % _brailleFrames.length]}')}';
    final trailingText = done
        ? (darkGray.wrap('(${_formatDuration(elapsed!)})') ?? '')
        : '$percent%';
    final message = '$prefix $label';
    if (!out.hasTerminal) {
      if (done) {
        out.writeln('$message $trailingText');
      }
      return;
    }
    final cols = out.terminalColumns;
    final pad = math.max(1, cols - message.length - trailingText.length);
    out.write('\u001b[2K\r$message${' ' * pad}$trailingText');
    if (done) out.writeln();
  }

  if (out.hasTerminal) {
    timer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      frameIndex++;
      final percent = stepProgressPercent(
        elapsedMs: stopwatch.elapsedMilliseconds,
        progressMin: progressMin,
        progressMax: progressMax,
      );
      render(percent: percent, done: false);
    });
    render(
      percent: stepProgressPercent(
        elapsedMs: 0,
        progressMin: progressMin,
        progressMax: progressMax,
      ),
      done: false,
    );
  } else {
    out.writeln('$leadingIcon $label...');
  }

  try {
    final result = await action();
    timer?.cancel();
    stopwatch.stop();
    render(
      percent: progressMax,
      done: true,
      elapsed: stopwatch.elapsed,
    );
    return result;
  } catch (_) {
    timer?.cancel();
    stopwatch.stop();
    if (out.hasTerminal) {
      out.writeln(
        '\u001b[2K\r${red.wrap('✗')} $leadingIcon $label '
        '${darkGray.wrap('(${_formatDuration(stopwatch.elapsed)})') ?? ''}',
      );
    }
    rethrow;
  }
}
