import 'package:flutter_test/flutter_test.dart';
import 'package:roux_trainer/models/cmll_algs.dart';
import 'package:roux_trainer/models/solve_record.dart';
import 'package:roux_trainer/providers/timer_provider.dart';
import 'package:roux_trainer/roux/cube.dart';
import 'package:roux_trainer/roux/solver.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('can train a specific CMLL case', () {
    final provider = TimerProvider();
    final cmllCase = cmllAlgs.firstWhere((case_) => case_.category == 'O');

    provider.selectCmllCase(cmllCase);

    expect(provider.mode, TrainingMode.cmll);
    expect(provider.currentCaseId, cmllCase.id);
    expect(provider.currentCaseName, '${cmllCase.category} ${cmllCase.name}');
    expect(provider.currentCaseAlg, cmllCase.alg);
  });

  test('can restrict random CMLL training to a category', () {
    final provider = TimerProvider();

    provider.selectCmllCategory('H');

    expect(provider.mode, TrainingMode.cmll);
    expect(provider.currentCaseName, startsWith('H '));
  });

  test('CMLL setup normalizes U2 prime turns when inverting algorithms', () {
    final provider = TimerProvider();
    final cmllCase = cmllAlgs.firstWhere((case_) => case_.alg.contains("U2'"));

    provider.selectCmllCase(cmllCase);

    expect(provider.scramble, isNot(contains("2''")));
    expect(provider.scramble, isNot(contains("U2'")));
  });

  test('EOLR mode generates a scramble that reaches the EOLR target', () {
    final provider = TimerProvider();
    final solver = RouxSolver.eolr();

    provider.setMode(TrainingMode.lseEOLR);
    final cube = RouxCube.solved().applyAlg(provider.scramble);

    expect(provider.scramble, isNotEmpty);
    expect(
      solver.solve(cube, minDepth: 0, maxDepth: 10, capacity: 1),
      isNotEmpty,
    );
  });

  test('4C mode generates a scramble that preserves oriented LSE edges', () {
    final provider = TimerProvider();

    provider.setMode(TrainingMode.lse4C);
    final cube = RouxCube.solved().applyAlg(provider.scramble);

    expect(provider.scramble, isNotEmpty);
    expect(RouxCubeUtil.isSolved(cube, RouxCubeMask.lse4c), isTrue);
  });
}
