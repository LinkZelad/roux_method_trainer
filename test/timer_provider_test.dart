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

  test('can train a specific CMLL case', () async {
    final provider = TimerProvider();
    final cmllCase = cmllAlgs.firstWhere((case_) => case_.category == 'O');

    provider.selectCmllCase(cmllCase);
    await Future.delayed(const Duration(milliseconds: 200));

    expect(provider.mode, TrainingMode.cmll);
    expect(provider.currentCaseId, cmllCase.id);
    expect(provider.currentCaseName, '${cmllCase.category} ${cmllCase.name}');
    expect(provider.currentCaseAlg, cmllCase.alg);
  });

  test('can restrict random CMLL training to a category', () async {
    final provider = TimerProvider();

    provider.selectCmllCategory('H');
    await Future.delayed(const Duration(milliseconds: 200));

    expect(provider.mode, TrainingMode.cmll);
    expect(provider.currentCaseName, startsWith('H '));
  });

  test('CMLL setup normalizes U2 prime turns when inverting algorithms', () async {
    final provider = TimerProvider();
    final cmllCase = cmllAlgs.firstWhere((case_) => case_.alg.contains("U2'"));

    provider.selectCmllCase(cmllCase);
    await Future.delayed(const Duration(milliseconds: 200));

    expect(provider.scramble, isNot(contains("2''")));
    expect(provider.scramble, isNot(contains("U2'")));
  });

  test('EOLR mode generates a scramble that reaches the EOLR target', () async {
    final provider = TimerProvider();
    final solver = RouxSolver.eolr();

    provider.setMode(TrainingMode.lseEOLR);
    await Future.delayed(const Duration(milliseconds: 200));

    final cube = RouxCube.solved().applyAlg(provider.scramble);

    expect(provider.scramble, isNotEmpty);
    expect(
      solver.solve(cube, minDepth: 0, maxDepth: 10, capacity: 1),
      isNotEmpty,
    );
  });

  test('4C mode generates a scramble that preserves oriented LSE edges', () async {
    final provider = TimerProvider();

    provider.setMode(TrainingMode.lse4C);
    await Future.delayed(const Duration(milliseconds: 200));

    final cube = RouxCube.solved().applyAlg(provider.scramble);

    expect(provider.scramble, isNotEmpty);
    expect(RouxCubeUtil.isSolved(cube, RouxCubeMask.lse4c), isTrue);
  });

  test('FB mode generates a scramble that disturbs FB pieces', () async {
    final provider = TimerProvider();

    provider.setMode(TrainingMode.fb);
    await Future.delayed(const Duration(milliseconds: 500));

    final cube = RouxCube.solved().applyAlg(provider.scramble);

    expect(provider.scramble, isNotEmpty);
    expect(RouxCubeUtil.isSolved(cube, RouxCubeMask.fb), isFalse);
  });

  test('SB mode generates a scramble that disturbs SB pieces', () async {
    final provider = TimerProvider();

    provider.setMode(TrainingMode.sb);
    await Future.delayed(const Duration(milliseconds: 3000));

    final cube = RouxCube.solved().applyAlg(provider.scramble);

    expect(provider.scramble, isNotEmpty);
    expect(RouxCubeUtil.isSolved(cube, RouxCubeMask.sb), isFalse);
  });

  test('CMLL mode generates a scramble that disturbs CMLL pieces', () async {
    final provider = TimerProvider();

    provider.setMode(TrainingMode.cmll);
    await Future.delayed(const Duration(milliseconds: 200));

    final cube = RouxCube.solved().applyAlg(provider.scramble);

    expect(provider.scramble, isNotEmpty);
    expect(RouxCubeUtil.isSolved(cube, RouxCubeMask.cmll), isFalse);
  });

  test('CMLL identifyCase returns correct algorithm for known case', () {
    final case_ = cmllAlgs.firstWhere((c) => c.category == 'O');
    final cube = RouxCube.solved().applyAlg(case_.alg);

    final identified = identifyCmllCase(cube);

    expect(identified, isNotNull);
    expect(identified!.id, case_.id);
  });

  test('CMLL identifyCase handles AUF correctly', () {
    final case_ = cmllAlgs.firstWhere((c) => c.category == 'H');
    final cube = RouxCube.solved().applyAlg('U2 ${case_.alg}');

    final identified = identifyCmllCase(cube);

    expect(identified, isNotNull);
    expect(identified!.id, case_.id);
  });
}
