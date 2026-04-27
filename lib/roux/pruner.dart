import 'dart:typed_data';

import 'cube.dart';

typedef RouxPrunerEncoder = int Function(RouxCube cube);

class RouxPruner {
  final int size;
  final int maxDepth;
  final RouxPrunerEncoder encode;
  final List<RouxMove> moveset;
  final List<RouxCube> solvedStates;
  final String name;

  Uint8List? _distance;

  RouxPruner({
    required this.size,
    required this.maxDepth,
    required this.encode,
    required List<String> moveset,
    required this.solvedStates,
    required this.name,
  }) : moveset = List.unmodifiable(moveset.map((move) => RouxMove.all[move]!));

  factory RouxPruner.lse() {
    return RouxPruner(
      size: 12 * 12 * 12 * 12 * 12 * 12 * 4 * 4 ~/ 2,
      maxDepth: 7,
      encode: _encodeLse,
      moveset: const ['U', "U'", 'U2', "M'", 'M', 'M2'],
      solvedStates: [RouxCube.solved()],
      name: 'lse',
    );
  }

  factory RouxPruner.eolr({int centerFlag = 0x11, String? barbieMode}) {
    final preMoves = _eolrPreMoves(centerFlag, barbieMode);
    return RouxPruner(
      size: 6 * 6 * 64 * 4 * 2,
      maxDepth: 20,
      encode: _encodeEolr,
      moveset: const ['U', "U'", 'U2', "M'", 'M', 'M2'],
      solvedStates: preMoves
          .map((alg) => RouxCube.solved().apply(RouxMoveSeq.parse(alg)))
          .toList(),
      name: 'eolr-$centerFlag-$barbieMode',
    );
  }

  void init() {
    if (_distance != null) return;

    final distance = Uint8List(size);
    distance.fillRange(0, distance.length, 255);

    var frontier = [...solvedStates];
    for (final state in solvedStates) {
      distance[encode(state)] = 0;
    }

    for (var depth = 0; depth < maxDepth; depth++) {
      final nextFrontier = <RouxCube>[];
      for (final state in frontier) {
        for (final move in moveset) {
          final next = state.applyMove(move);
          final index = encode(next);
          if (distance[index] == 255) {
            distance[index] = depth + 1;
            nextFrontier.add(next);
          }
        }
      }
      frontier = nextFrontier;
    }

    _distance = distance;
  }

  int query(RouxCube cube) {
    init();
    final distance = _distance![encode(cube)];
    if (distance == 255) return maxDepth + 1;
    return distance;
  }

  static int _encodeLse(RouxCube cube) {
    const edgeEncode = [0, 1, 2, 3, 4, -1, 5, -1, -1, -1, -1, -1];
    final enc = List.filled(6, 0);

    for (var i = 0; i < 12; i++) {
      final idx = edgeEncode[cube.ep[i]];
      if (idx > 0) {
        enc[idx] = edgeEncode[i] * 2 + cube.eo[i];
      }
    }

    var edgeEnc = 0;
    for (var i = 0; i < 6; i++) {
      edgeEnc = edgeEnc * 12 + enc[i];
    }
    return edgeEnc * 4 * 4 + cube.tp[0] * 4 + cube.cp[0];
  }

  static int _encodeEolr(RouxCube cube) {
    const edgeEncode = [0, 1, 0, 2, 0, -1, 0, -1, -1, -1, -1, -1];
    const edgeIndex = [0, 1, 2, 3, 4, -1, 5, -1, -1, -1, -1, -1];
    var eo = 0;
    var ep = 0;

    for (var i = 0; i < 12; i++) {
      final idx = edgeEncode[cube.ep[i]];
      if (idx >= 0) {
        eo = eo * 2 + cube.eo[i];
      }
      if (idx > 0) {
        ep += _intPow(6, idx - 1) * edgeIndex[i];
      }
    }

    return (eo * 36 + ep) * 4 * 2 + (cube.tp[0] ~/ 2) * 4 + cube.cp[0];
  }

  static List<String> _eolrPreMoves(int centerFlag, String? barbieMode) {
    final movesAc = _cartesianProduct([
      ["U'", 'U'],
      ['M2'],
      ['', 'U', "U'", 'U2'],
    ]).map((parts) => parts.where((part) => part.isNotEmpty).join(' '));
    final movesMc = _cartesianProduct([
      ["M'"],
      ['U', "U'"],
      ['M2'],
      ['', 'U', "U'", 'U2'],
    ]).map((parts) => parts.where((part) => part.isNotEmpty).join(' '));

    final barbieAc = ['U', "U'"];
    final barbieMc = ['M U', "M U'"];

    final moves = <String>[];
    final barbieMoves = <String>[];
    if (centerFlag & 0x01 != 0) {
      moves.addAll(movesAc);
      barbieMoves.addAll(barbieAc);
    }
    if (centerFlag & 0x10 != 0) {
      moves.addAll(movesMc);
      barbieMoves.addAll(barbieMc);
    }

    if (barbieMode == 'barbie') return barbieMoves;
    if (barbieMode == 'ab4c') return ['id'];
    return moves;
  }

  static List<List<String>> _cartesianProduct(List<List<String>> entries) {
    var results = <List<String>>[const []];
    for (final entry in entries) {
      results = [
        for (final result in results)
          for (final value in entry) [...result, value],
      ];
    }
    return results;
  }

  static int _intPow(int base, int exponent) {
    var result = 1;
    for (var i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }
}
