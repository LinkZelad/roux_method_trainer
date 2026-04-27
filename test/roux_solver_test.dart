import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:roux_trainer/roux/cube.dart';
import 'package:roux_trainer/roux/solver.dart';

void main() {
  test('solves a short LSE case with U and M moves', () {
    final solver = RouxSolver.lse();
    final cube = RouxCube.solved().applyAlg("U M U'");

    final solutions = solver.solve(cube, minDepth: 0, maxDepth: 4, capacity: 1);

    expect(solutions, hasLength(1));
    expect(cube.apply(solutions.first).isSolved, isTrue);
  });

  test('solves a bounded LSE training state', () {
    final solver = RouxSolver.lse();
    final cube = RouxCube.solved().applyAlg("M U2 M' U M2");

    final solutions = solver.solve(cube, minDepth: 0, maxDepth: 5, capacity: 1);

    expect(solutions, hasLength(1));
    expect(cube.apply(solutions.first).isSolved, isTrue);
  });

  test('generates a solvable LSE scramble by retrying out-of-range states', () {
    final solver = RouxSolver.lse();
    final scramble = solver.generateScramble(
      randomState: (random) => RouxCubeUtil.getRandomLse(random: random),
      random: Random(3),
      maxDepth: 8,
      maxAttempts: 20,
    );

    expect(scramble, isNotNull);
    expect(scramble!.moves.length, lessThanOrEqualTo(8));
  });

  test('generates an EOLR scramble that reaches the EOLR target', () {
    final solver = RouxSolver.eolr();
    final scramble = solver.generateScramble(
      randomState: (random) => RouxCubeUtil.getRandomLse(random: random),
      random: Random(5),
      maxDepth: 10,
      maxAttempts: 20,
    );

    expect(scramble, isNotNull);
    expect(
      solver.solve(
        RouxCube.solved().apply(scramble!),
        minDepth: 0,
        maxDepth: 10,
        capacity: 1,
      ),
      isNotEmpty,
    );
  });

  test('returns inverse solution as a scramble for an exact target cube', () {
    final solver = RouxSolver.exact();
    final cube = RouxCube.solved().applyAlg('R U');

    final scramble = solver.scrambleFor(cube, maxDepth: 4);

    expect(scramble, isNotNull);
    expect(RouxCube.solved().apply(scramble!), cube);
  });
}
