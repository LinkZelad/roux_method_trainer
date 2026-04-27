import 'package:flutter_test/flutter_test.dart';
import 'package:roux_trainer/roux/cube.dart';
import 'dart:math';

void main() {
  test('R move matches roux-trainers cubie mapping', () {
    final cube = RouxCube.solved().applyAlg('R');

    expect(cube.cp, [0, 1, 3, 7, 4, 5, 2, 6]);
    expect(cube.co, [0, 0, 1, 2, 0, 0, 2, 1]);
    expect(cube.ep, [0, 1, 2, 11, 4, 5, 6, 10, 8, 9, 3, 7]);
    expect(cube.eo, List.filled(12, 0));
    expect(cube.tp, [0, 1, 2, 3, 4, 5]);
  });

  test('applying an algorithm followed by its inverse solves the cube', () {
    final alg = RouxMoveSeq.parse("r U2' M U R' F // comment");
    final cube = RouxCube.solved().apply(alg).apply(alg.inverse());

    expect(cube.isSolved, isTrue);
  });

  test('parser ignores comments and normalizes U2 prime suffixes', () {
    final alg = RouxMoveSeq.parse("  B T F' // M U2 // \n R U2'");

    expect(alg.toString(), "B F' R U2");
  });

  test('collapse combines adjacent moves on the same face', () {
    final alg = RouxMoveSeq.parse("R R U U' M M M");

    expect(alg.collapse().toString(), "R2 M'");
  });

  test('FB mask only requires the first block cubies to be solved', () {
    final solvedWithFreeTopLayer = RouxCube.solved().applyAlg('U');
    final brokenFirstBlock = RouxCube.solved().applyAlg('F');

    expect(
      RouxCubeUtil.isSolved(solvedWithFreeTopLayer, RouxCubeMask.fb),
      isTrue,
    );
    expect(RouxCubeUtil.isSolved(brokenFirstBlock, RouxCubeMask.fb), isFalse);
  });

  test(
    'masked random cube preserves solved mask pieces and stays solvable',
    () {
      final random = Random(42);
      final cubes = List.generate(
        50,
        (_) => RouxCubeUtil.getRandomWithMask(RouxCubeMask.fb, random: random),
      );

      expect(cubes.any((cube) => !cube.isSolved), isTrue);
      for (final cube in cubes) {
        expect(RouxCubeUtil.isSolved(cube, RouxCubeMask.fb), isTrue);
        expect(cube.isSolvable, isTrue);
      }
    },
  );

  test('random LSE cube preserves solved CMLL state', () {
    final cube = RouxCubeUtil.getRandomLse(random: Random(7));

    expect(RouxCubeUtil.isSolved(cube, RouxCubeMask.lse), isTrue);
    expect(cube.isSolvable, isTrue);
  });
}
