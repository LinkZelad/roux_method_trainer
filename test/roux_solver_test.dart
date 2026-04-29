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

  test('FB solver solves a known short FB scramble', () {
    final solver = RouxSolver.fb();
    // Apply a short scramble that affects FB pieces, then solve it.
    final cube = RouxCube.solved().applyAlg("R U R'");
    final solutions = solver.solve(cube, minDepth: 0, maxDepth: 5, capacity: 1);
    expect(solutions, hasLength(1));
    final solved = cube.apply(solutions.first);
    expect(RouxCubeUtil.isSolved(solved, RouxCubeMask.fb), isTrue);
  });

  test('FB random state is not already solved', () {
    final random = Random(99);
    for (var i = 0; i < 10; i++) {
      final cube = RouxCubeUtil.getRandomFb(random: random);
      expect(RouxCubeUtil.isSolved(cube, RouxCubeMask.fb), isFalse);
    }
  });

  test('SB solver solves a known short SB scramble', () {
    final solver = RouxSolver.sb();
    final cube = RouxCube.solved().applyAlg("R U R'");
    final solutions = solver.solve(cube, minDepth: 0, maxDepth: 5, capacity: 1);
    expect(solutions, hasLength(1));
    final solved = cube.apply(solutions.first);
    expect(RouxCubeUtil.isSolved(solved, RouxCubeMask.sb), isTrue);
  });

  test('SB random state is not already solved', () {
    final random = Random(99);
    for (var i = 0; i < 10; i++) {
      final cube = RouxCubeUtil.getRandomSb(random: random);
      expect(RouxCubeUtil.isSolved(cube, RouxCubeMask.sb), isFalse);
    }
  });

  test('CMLL solver solves a known short CMLL scramble', () {
    final solver = RouxSolver.cmll();
    final cube = RouxCube.solved().applyAlg("R U R' U R U2 R'");
    final solutions = solver.solve(cube, minDepth: 0, maxDepth: 8, capacity: 1);
    expect(solutions, hasLength(1));
    final solved = cube.apply(solutions.first);
    expect(RouxCubeUtil.isSolved(solved, RouxCubeMask.cmll), isTrue);
  });

  test('CMLL random state is not already solved', () {
    final random = Random(99);
    for (var i = 0; i < 10; i++) {
      final cube = RouxCubeUtil.getRandomCmll(random: random);
      expect(RouxCubeUtil.isSolved(cube, RouxCubeMask.cmll), isFalse);
    }
  });

  test('generates a solvable FB scramble', () {
    final solver = RouxSolver.fb();
    final scramble = solver.generateScramble(
      randomState: (random) => RouxCubeUtil.getRandomFb(random: random),
      random: Random(3),
      maxDepth: 15,
      maxAttempts: 30,
    );
    expect(scramble, isNotNull);
    expect(scramble!.moves.length, lessThanOrEqualTo(15));
  });

  test('generates a solvable SB scramble', () {
    final solver = RouxSolver.sb();
    final scramble = solver.generateScramble(
      randomState: (random) => RouxCubeUtil.getRandomSb(random: random),
      random: Random(3),
      maxDepth: 18,
      maxAttempts: 30,
    );
    expect(scramble, isNotNull);
    expect(scramble!.moves.length, lessThanOrEqualTo(18));
  });

  test('generates a solvable CMLL scramble', () {
    final solver = RouxSolver.cmll();
    final scramble = solver.generateScramble(
      randomState: (random) => RouxCubeUtil.getRandomCmll(random: random),
      random: Random(3),
      maxDepth: 12,
      maxAttempts: 30,
    );
    expect(scramble, isNotNull);
    expect(scramble!.moves.length, lessThanOrEqualTo(12));
  });
}
