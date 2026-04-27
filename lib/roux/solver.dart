import 'dart:math';

import 'cube.dart';
import 'pruner.dart';

typedef RouxSolvedPredicate = bool Function(RouxCube cube);
typedef RouxRandomStateFactory = RouxCube Function(Random random);

class RouxSolver {
  final RouxSolvedPredicate isSolved;
  final List<RouxMove> moveset;
  final List<RouxPruner> pruners;
  final int maxStateCount;

  RouxSolver({
    required this.isSolved,
    required List<String> moveset,
    List<RouxPruner> pruners = const [],
    this.maxStateCount = 3000000,
  }) : moveset = List.unmodifiable(moveset.map((name) => RouxMove.all[name]!)),
       pruners = List.unmodifiable(pruners);

  factory RouxSolver.lse() {
    return RouxSolver(
      isSolved: (cube) => cube.isSolved,
      moveset: const ['U', "U'", 'U2', "M'", 'M', 'M2'],
      pruners: [RouxPruner.lse()],
    );
  }

  factory RouxSolver.eolr({int centerFlag = 0x11, String? barbieMode}) {
    final pruner = RouxPruner.eolr(
      centerFlag: centerFlag,
      barbieMode: barbieMode,
    );
    return RouxSolver(
      isSolved: (cube) => pruner.query(cube) == 0,
      moveset: const ['U', "U'", 'U2', "M'", 'M', 'M2'],
      pruners: [pruner],
    );
  }

  factory RouxSolver.fb() {
    final fbCorner = RouxPruner.fbCorner();
    final fbEdge = RouxPruner.fbEdge();
    return RouxSolver(
      isSolved: (cube) => RouxCubeUtil.isSolved(cube, RouxCubeMask.fb),
      moveset: const [
        'U', "U'", 'U2', 'D', "D'", 'D2', 'F', "F'", 'F2',
        'B', "B'", 'B2', 'R', "R'", 'R2', 'L', "L'", 'L2',
        'M', "M'", 'M2',
      ],
      pruners: [fbCorner, fbEdge],
    );
  }

  factory RouxSolver.exact() {
    return RouxSolver(
      isSolved: (cube) => cube.isSolved,
      moveset: const [
        'U',
        "U'",
        'U2',
        'R',
        "R'",
        'R2',
        'F',
        "F'",
        'F2',
        'M',
        "M'",
        'M2',
      ],
    );
  }

  List<RouxMoveSeq> solve(
    RouxCube cube, {
    required int minDepth,
    required int maxDepth,
    required int capacity,
  }) {
    final solutions = <RouxMoveSeq>[];
    var stateCount = 0;

    bool search(RouxCube current, int depth, int limit, List<RouxMove> path) {
      stateCount++;
      if (stateCount > maxStateCount) return true;

      if (isSolved(current)) {
        if (depth >= minDepth) {
          final solution = RouxMoveSeq([...path]);
          if (!solutions.any(
            (existing) => existing.toString() == solution.toString(),
          )) {
            solutions.add(solution);
          }
        }
        return solutions.length >= capacity;
      }

      if (depth >= limit) return false;
      if (_lowerBound(current) + depth > limit) return false;

      for (final move in _availableMoves(path)) {
        path.add(move);
        final stop = search(current.applyMove(move), depth + 1, limit, path);
        path.removeLast();
        if (stop) return true;
      }
      return false;
    }

    for (var limit = minDepth; limit <= maxDepth; limit++) {
      if (search(cube, 0, limit, [])) break;
      if (solutions.length >= capacity || stateCount > maxStateCount) break;
    }

    return solutions;
  }

  int _lowerBound(RouxCube cube) {
    var bound = 0;
    for (final pruner in pruners) {
      final distance = pruner.query(cube);
      if (distance > bound) bound = distance;
    }
    return bound;
  }

  RouxMoveSeq? scrambleFor(RouxCube cube, {required int maxDepth}) {
    final solutions = solve(cube, minDepth: 0, maxDepth: maxDepth, capacity: 1);
    if (solutions.isEmpty) return null;
    return solutions.first.inverse();
  }

  RouxMoveSeq? generateScramble({
    required RouxRandomStateFactory randomState,
    Random? random,
    required int maxDepth,
    int maxAttempts = 50,
  }) {
    random ??= Random();
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final cube = randomState(random);
      final scramble = scrambleFor(cube, maxDepth: maxDepth);
      if (scramble != null) return scramble;
    }
    return null;
  }

  Iterable<RouxMove> _availableMoves(List<RouxMove> path) {
    if (path.isEmpty) return moveset;
    final previous = path.last.name;
    return moveset.where((move) => _canFollow(previous, move.name));
  }

  bool _canFollow(String previous, String next) {
    final previousFace = previous[0];
    final nextFace = next[0];
    if (previousFace == nextFace) return false;

    switch (previousFace) {
      case 'U':
        return nextFace != 'u';
      case 'u':
        return nextFace != 'U';
      case 'D':
        return nextFace != 'U';
      case 'R':
        return nextFace != 'r' && nextFace != 'M';
      case 'r':
      case 'M':
      case 'L':
        return nextFace != 'R' &&
            nextFace != 'r' &&
            nextFace != 'M' &&
            nextFace != 'L';
      case 'F':
        return nextFace != 'f' && nextFace != 'S';
      case 'f':
      case 'S':
      case 'B':
        return nextFace != 'F' &&
            nextFace != 'f' &&
            nextFace != 'S' &&
            nextFace != 'B';
      case 'E':
        return nextFace != 'U' && nextFace != 'D';
      default:
        return true;
    }
  }
}
