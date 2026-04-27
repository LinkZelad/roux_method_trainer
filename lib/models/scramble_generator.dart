// 打乱生成器

import 'dart:math';

class ScrambleGenerator {
  static final Random _rand = Random();

  static const List<String> _standardMoves = [
    'U',
    "U'",
    'U2',
    'D',
    "D'",
    'D2',
    'F',
    "F'",
    'F2',
    'B',
    "B'",
    'B2',
    'L',
    "L'",
    'L2',
    'R',
    "R'",
    'R2',
  ];

  static const List<String> _rouxMoves = [
    'U',
    "U'",
    'U2',
    'M',
    "M'",
    'M2',
    'R',
    "R'",
    'R2',
    'r',
    "r'",
    'r2',
    'F',
    "F'",
    'F2',
    'B',
    "B'",
    'B2',
    'L',
    "L'",
    'L2',
    'D',
    "D'",
    'D2',
  ];

  static const List<String> _lseMoves = ['U', "U'", 'U2', 'M', "M'", 'M2'];

  static String generateStandard({int length = 25}) {
    return _generate(_standardMoves, length);
  }

  static String generateRoux({int length = 25}) {
    return _generate(_rouxMoves, length);
  }

  static String generateLSE({int length = 12}) {
    return _generate(_lseMoves, length);
  }

  static String _generate(List<String> moveSet, int length) {
    final moves = <String>[];
    String? lastFace;
    String? secondLastFace;

    for (int i = 0; i < length; i++) {
      String move;
      String face;
      int attempts = 0;

      do {
        move = moveSet[_rand.nextInt(moveSet.length)];
        face = _getFace(move);
        attempts++;
      } while (attempts < 100 &&
          (face == lastFace ||
              (lastFace != null &&
                  _isOppositeFace(face, lastFace) &&
                  face == secondLastFace)));

      moves.add(move);
      secondLastFace = lastFace;
      lastFace = face;
    }

    return moves.join(' ');
  }

  static String _getFace(String move) {
    if (move.startsWith('r')) return 'R';
    if (move.startsWith('l')) return 'L';
    return move[0];
  }

  static bool _isOppositeFace(String a, String b) {
    const opposites = {
      'U': 'D',
      'D': 'U',
      'F': 'B',
      'B': 'F',
      'L': 'R',
      'R': 'L',
    };
    return opposites[a] == b;
  }
}
