import 'package:test/test.dart';
import 'package:xproject_generator/src/cli_step_progress.dart';

void main() {
  test('stepProgressPercent stays within step range until complete', () {
    expect(
      stepProgressPercent(elapsedMs: 0, progressMin: 75, progressMax: 100),
      75,
    );
    final mid = stepProgressPercent(
      elapsedMs: 10000,
      progressMin: 75,
      progressMax: 100,
    );
    expect(mid, greaterThan(75));
    expect(mid, lessThan(100));
  });

  test('stepProgressPercent approaches top of range before complete', () {
    final high = stepProgressPercent(
      elapsedMs: 60000,
      progressMin: 0,
      progressMax: 25,
    );
    expect(high, greaterThan(20));
    expect(high, lessThan(25));
  });
}
