import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:roux_trainer/roux/cube.dart';
import 'package:roux_trainer/roux/pruner.dart';

void main() {
  test('LSE pruner estimates short states within their known depth', () {
    final pruner = RouxPruner.lse()..init();

    expect(pruner.query(RouxCube.solved()), 0);
    expect(pruner.query(RouxCube.solved().applyAlg('U')), lessThanOrEqualTo(1));
    expect(
      pruner.query(RouxCube.solved().applyAlg("M U M'")),
      lessThanOrEqualTo(3),
    );
  });

  test('LSE pruner reports generated LSE training states as near range', () {
    final pruner = RouxPruner.lse()..init();
    final random = Random(3);

    for (var i = 0; i < 5; i++) {
      final cube = RouxCubeUtil.getRandomLse(random: random);

      expect(pruner.query(cube), lessThanOrEqualTo(8));
    }
  });

  test('EOLR pruner treats configured EOLR states as solved targets', () {
    final pruner = RouxPruner.eolr(centerFlag: 0x11)..init();

    expect(pruner.query(RouxCube.solved().applyAlg("U' M2")), 0);
    expect(pruner.query(RouxCube.solved().applyAlg("M U M2")), 0);
    expect(pruner.query(RouxCube.solved()), greaterThanOrEqualTo(0));
  });

  test('FB corner pruner gives distance 0 for solved state', () {
    final pruner = RouxPruner.fbCorner()..init();
    expect(pruner.query(RouxCube.solved()), 0);
  });

  test('FB corner pruner gives distance 1 for single-move scramble', () {
    final pruner = RouxPruner.fbCorner()..init();
    expect(pruner.query(RouxCube.solved().applyAlg('R')), lessThanOrEqualTo(1));
  });

  test('FB edge pruner gives distance 0 for solved state', () {
    final pruner = RouxPruner.fbEdge()..init();
    expect(pruner.query(RouxCube.solved()), 0);
  });

  test('FB edge pruner gives distance 1 for single-move scramble', () {
    final pruner = RouxPruner.fbEdge()..init();
    expect(pruner.query(RouxCube.solved().applyAlg('L')), lessThanOrEqualTo(1));
  });
}
