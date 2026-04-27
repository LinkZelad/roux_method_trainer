import 'package:flutter_test/flutter_test.dart';
import 'package:roux_trainer/models/solve_record.dart';

SolveRecord _record(int seconds, {Penalty penalty = Penalty.none}) {
  return SolveRecord(
    id: '$seconds-$penalty',
    timestamp: DateTime(2026),
    time: Duration(seconds: seconds),
    penalty: penalty,
    scramble: 'R U R\'',
  );
}

void main() {
  test('ao5 treats one DNF as the dropped worst solve', () {
    final average = StatsCalculator.calculateTrimmedAverage([
      _record(10),
      _record(11),
      _record(12),
      _record(13),
      _record(99, penalty: Penalty.dnf),
    ], 5);

    expect(average, const Duration(seconds: 12));
  });

  test('ao5 is DNF when the window contains two DNFs', () {
    final average = StatsCalculator.calculateTrimmedAverage([
      _record(10),
      _record(11),
      _record(12),
      _record(98, penalty: Penalty.dnf),
      _record(99, penalty: Penalty.dnf),
    ], 5);

    expect(average, isNull);
  });
}
