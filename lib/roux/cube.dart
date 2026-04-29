import 'dart:math';

typedef PermChange = (int src, int dst);

class RouxCube {
  final List<int> cp;
  final List<int> co;
  final List<int> ep;
  final List<int> eo;
  final List<int> tp;

  RouxCube({
    required List<int> cp,
    required List<int> co,
    required List<int> ep,
    required List<int> eo,
    List<int>? tp,
  }) : cp = List.unmodifiable(cp),
       co = List.unmodifiable(co),
       ep = List.unmodifiable(ep),
       eo = List.unmodifiable(eo),
       tp = List.unmodifiable(tp ?? const [0, 1, 2, 3, 4, 5]);

  factory RouxCube.solved() {
    return RouxCube(
      cp: const [0, 1, 2, 3, 4, 5, 6, 7],
      co: List.filled(8, 0),
      ep: const [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
      eo: List.filled(12, 0),
      tp: const [0, 1, 2, 3, 4, 5],
    );
  }

  bool get isSolved {
    return _listEquals(cp, const [0, 1, 2, 3, 4, 5, 6, 7]) &&
        _listEquals(co, List.filled(8, 0)) &&
        _listEquals(ep, const [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]) &&
        _listEquals(eo, List.filled(12, 0)) &&
        _listEquals(tp, const [0, 1, 2, 3, 4, 5]);
  }

  bool get isSolvable {
    final parityCorrect =
        (RouxCubeUtil.parity(cp) + RouxCubeUtil.parity(ep)) % 2 == 0;
    final orientationCorrect =
        co.reduce((a, b) => a + b) % 3 == 0 &&
        eo.reduce((a, b) => a + b) % 2 == 0;
    return parityCorrect && orientationCorrect;
  }

  RouxCube apply(RouxMoveSeq alg) {
    var cube = this;
    for (final move in alg.moves) {
      cube = cube.applyMove(move);
    }
    return cube;
  }

  RouxCube applyAlg(String alg) => apply(RouxMoveSeq.parse(alg));

  RouxCube applyMove(RouxMove move) {
    final (nextCo, nextCp) = _applyPartial(co, cp, move.coc, move.cpc, 3);
    final (nextEo, nextEp) = _applyPartial(eo, ep, move.eoc, move.epc, 2);
    final nextTp = _applyPartialPerm(tp, move.tpc);
    return RouxCube(cp: nextCp, co: nextCo, ep: nextEp, eo: nextEo, tp: nextTp);
  }

  static (List<int>, List<int>) _applyPartial(
    List<int> orientation,
    List<int> permutation,
    List<int> orientationChanges,
    List<PermChange> permutationChanges,
    int mod,
  ) {
    final nextOrientation = [...orientation];
    final nextPermutation = [...permutation];
    for (var i = 0; i < permutationChanges.length; i++) {
      final change = permutationChanges[i];
      nextPermutation[change.$2] = permutation[change.$1];
      nextOrientation[change.$2] =
          (orientation[change.$1] + orientationChanges[i]) % mod;
    }
    return (nextOrientation, nextPermutation);
  }

  static List<int> _applyPartialPerm(
    List<int> permutation,
    List<PermChange> permutationChanges,
  ) {
    final nextPermutation = [...permutation];
    for (final change in permutationChanges) {
      nextPermutation[change.$2] = permutation[change.$1];
    }
    return nextPermutation;
  }

  static bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  bool operator ==(Object other) {
    return other is RouxCube &&
        _listEquals(cp, other.cp) &&
        _listEquals(co, other.co) &&
        _listEquals(ep, other.ep) &&
        _listEquals(eo, other.eo) &&
        _listEquals(tp, other.tp);
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(cp),
    Object.hashAll(co),
    Object.hashAll(ep),
    Object.hashAll(eo),
    Object.hashAll(tp),
  );
}

class RouxCubeMask {
  final List<int> cp;
  final List<int> ep;
  final List<int>? co;
  final List<int>? eo;
  final List<int>? tp;

  const RouxCubeMask({
    required this.cp,
    required this.ep,
    this.co,
    this.eo,
    this.tp,
  });

  static const solved = RouxCubeMask(
    cp: [1, 1, 1, 1, 1, 1, 1, 1],
    ep: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
  );

  static const empty = RouxCubeMask(
    cp: [0, 0, 0, 0, 0, 0, 0, 0],
    ep: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  );

  static const fb = RouxCubeMask(
    cp: [0, 0, 0, 0, 1, 1, 0, 0],
    ep: [0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0],
    tp: [0, 0, 0, 0, 1, 1],
  );

  static const sb = RouxCubeMask(
    cp: [0, 0, 0, 0, 1, 1, 1, 1],
    ep: [0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 1],
    tp: [0, 0, 0, 0, 1, 1],
  );

  static const cmll = RouxCubeMask(
    cp: [1, 1, 1, 1, 1, 1, 1, 1],
    ep: [0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 1],
    tp: [0, 0, 0, 0, 1, 1],
  );

  static const lse = RouxCubeMask(
    cp: [1, 1, 1, 1, 1, 1, 1, 1],
    ep: [0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 1],
    tp: [0, 0, 0, 0, 0, 0],
  );

  static const lse4c = RouxCubeMask(
    cp: [1, 1, 1, 1, 1, 1, 1, 1],
    ep: [0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1],
    eo: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    tp: [0, 0, 0, 0, 0, 0],
  );

  static const fbdr = RouxCubeMask(
    cp: [0, 0, 0, 0, 1, 1, 0, 0],
    ep: [0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 0, 0],
    tp: [0, 0, 0, 0, 1, 1],
  );

  static const fs = RouxCubeMask(
    cp: [0, 0, 0, 0, 1, 0, 0, 0],
    ep: [0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0],
    tp: [0, 0, 0, 0, 0, 1],
  );
}

class RouxCubeUtil {
  static bool isSolved(RouxCube cube, RouxCubeMask mask) {
    final co = mask.co ?? mask.cp;
    final eo = mask.eo ?? mask.ep;
    final tp = mask.tp ?? List.filled(6, 1);

    for (var i = 0; i < 8; i++) {
      if (mask.cp[i] != 0 && cube.cp[i] != i) return false;
      if (co[i] != 0 && cube.co[i] != 0) return false;
    }

    for (var i = 0; i < 12; i++) {
      if (mask.ep[i] != 0 && cube.ep[i] != i) return false;
      if (eo[i] != 0 && cube.eo[i] != 0) return false;
    }

    for (var i = 0; i < 6; i++) {
      if (tp[i] != 0 && cube.tp[i] != i) return false;
    }

    return true;
  }

  static RouxCube getRandomWithMask(RouxCubeMask mask, {Random? random}) {
    random ??= Random();
    final coMask = mask.co ?? mask.cp;
    final eoMask = mask.eo ?? mask.ep;

    late List<int> cp;
    late List<int> ep;
    do {
      cp = _randomPermutation(mask.cp, random);
      ep = _randomPermutation(mask.ep, random);
    } while ((parity(cp) + parity(ep)) % 2 != 0);

    return RouxCube(
      cp: cp,
      co: _randomOrientation(coMask, 3, random),
      ep: ep,
      eo: _randomOrientation(eoMask, 2, random),
    );
  }

  static RouxCube getRandomFb({Random? random}) {
    random ??= Random();
    const fbScramble = RouxCubeMask(
      cp: [1, 1, 1, 1, 0, 0, 1, 1],
      ep: [1, 1, 1, 1, 1, 0, 1, 1, 0, 0, 1, 1],
      tp: [1, 1, 1, 1, 0, 0],
    );
    while (true) {
      final cube = getRandomWithMask(fbScramble, random: random);
      if (!isSolved(cube, RouxCubeMask.fb)) return cube;
    }
  }

  static RouxCube getRandomSb({Random? random}) {
    random ??= Random();
    const sbScramble = RouxCubeMask(
      cp: [1, 1, 1, 1, 1, 1, 0, 0],
      ep: [1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 0],
      tp: [1, 1, 1, 1, 1, 1],
    );
    while (true) {
      final cube = getRandomWithMask(sbScramble, random: random);
      if (!isSolved(cube, RouxCubeMask.sb)) return cube;
    }
  }

  static RouxCube getRandomCmll({Random? random}) {
    random ??= Random();
    const cmllScramble = RouxCubeMask(
      cp: [0, 0, 0, 0, 1, 1, 1, 1],
      ep: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      tp: [1, 1, 1, 1, 1, 1],
    );
    while (true) {
      final cube = getRandomWithMask(cmllScramble, random: random);
      if (!isSolved(cube, RouxCubeMask.cmll)) return cube;
    }
  }

  static RouxCube getRandomLse({Random? random}) {
    random ??= Random();
    final cube = getRandomWithMask(RouxCubeMask.lse, random: random);
    final premoves = [
      RouxMoveSeq(const []),
      RouxMoveSeq([RouxMove.all['M2']!]),
    ];
    return cube.apply(premoves[random.nextInt(premoves.length)]);
  }

  static RouxCube getRandomLse4c({Random? random}) {
    random ??= Random();
    final cube = getRandomWithMask(RouxCubeMask.lse4c, random: random);
    final premoves = [
      RouxMoveSeq(const []),
      RouxMoveSeq([RouxMove.all['M2']!]),
    ];
    return cube.apply(premoves[random.nextInt(premoves.length)]);
  }

  static RouxCube getRandomFbdr({Random? random}) {
    random ??= Random();
    const fbdrScramble = RouxCubeMask(
      cp: [1, 1, 1, 1, 0, 0, 1, 1],
      ep: [1, 1, 1, 1, 1, 0, 1, 0, 0, 0, 1, 1],
      tp: [1, 1, 1, 1, 0, 0],
    );
    while (true) {
      final cube = getRandomWithMask(fbdrScramble, random: random);
      if (!isSolved(cube, RouxCubeMask.fbdr)) return cube;
    }
  }

  static RouxCube getRandomFs({Random? random}) {
    random ??= Random();
    const fsScramble = RouxCubeMask(
      cp: [1, 1, 1, 1, 0, 1, 1, 1],
      ep: [1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1],
      tp: [1, 1, 1, 1, 1, 0],
    );
    while (true) {
      final cube = getRandomWithMask(fsScramble, random: random);
      if (!isSolved(cube, RouxCubeMask.fs)) return cube;
    }
  }

  static int parity(List<int> permutation) {
    final visited = List.filled(permutation.length, false);

    int follow(int index, int count) {
      if (visited[index]) return 0;
      visited[index] = true;
      if (visited[permutation[index]]) return count;
      return follow(permutation[index], count + 1);
    }

    var result = 0;
    for (final item in permutation) {
      result += follow(item, 0);
    }
    return result;
  }

  static List<int> _randomOrientation(List<int> mask, int mod, Random random) {
    while (true) {
      var sum = 0;
      final orientation = List.filled(mask.length, 0);
      for (var i = 0; i < mask.length; i++) {
        if (mask[i] == 0) {
          orientation[i] = random.nextInt(mod);
          sum += orientation[i];
        }
      }
      if (sum % mod == 0) return orientation;
    }
  }

  static List<int> _randomPermutation(List<int> mask, Random random) {
    final permutation = List.filled(mask.length, 0);
    final undecided = <int>[];
    for (var i = 0; i < mask.length; i++) {
      if (mask[i] == 0) {
        undecided.add(i);
      } else {
        permutation[i] = i;
      }
    }

    _shuffle(undecided, random);
    for (var i = 0, count = 0; i < mask.length; i++) {
      if (mask[i] == 0) {
        permutation[i] = undecided[count];
        count++;
      }
    }
    return permutation;
  }

  static void _shuffle<T>(List<T> values, Random random) {
    for (var i = 0; i < values.length - 1; i++) {
      final j = i + random.nextInt(values.length - i);
      final tmp = values[i];
      values[i] = values[j];
      values[j] = tmp;
    }
  }
}

class RouxMove {
  final List<PermChange> cpc;
  final List<int> coc;
  final List<PermChange> epc;
  final List<int> eoc;
  final List<PermChange> tpc;
  final String name;

  const RouxMove({
    required this.cpc,
    required this.coc,
    required this.epc,
    required this.eoc,
    required this.tpc,
    required this.name,
  });

  factory RouxMove.fromCube(RouxCube cube, String name) {
    final cpc = <PermChange>[];
    final coc = <int>[];
    final epc = <PermChange>[];
    final eoc = <int>[];
    final tpc = <PermChange>[];

    for (var i = 0; i < cube.cp.length; i++) {
      if (cube.cp[i] != i || cube.co[i] != 0) {
        cpc.add((cube.cp[i], i));
        coc.add(cube.co[i]);
      }
    }
    for (var i = 0; i < cube.ep.length; i++) {
      if (cube.ep[i] != i || cube.eo[i] != 0) {
        epc.add((cube.ep[i], i));
        eoc.add(cube.eo[i]);
      }
    }
    for (var i = 0; i < cube.tp.length; i++) {
      if (cube.tp[i] != i) {
        tpc.add((cube.tp[i], i));
      }
    }

    return RouxMove(
      cpc: cpc,
      coc: coc,
      epc: epc,
      eoc: eoc,
      tpc: tpc,
      name: name,
    );
  }

  factory RouxMove.fromMoves(List<RouxMove> moves, String name) {
    return RouxMove.fromCube(RouxCube.solved().apply(RouxMoveSeq(moves)), name);
  }

  RouxMove inverse() {
    final inverseName = switch (name[name.length - 1]) {
      "'" => name.substring(0, name.length - 1),
      '2' => name,
      _ => "$name'",
    };
    return all[inverseName]!;
  }

  @override
  String toString() => name;

  static final Map<String, RouxMove> all = _generateMoves();

  static List<RouxMove> _makeRotSet(RouxMove move) {
    return [
      move,
      RouxMove.fromMoves([move, move], '${move.name}2'),
      RouxMove.fromMoves([move, move, move], "${move.name}'"),
    ];
  }

  static Map<String, RouxMove> _generateMoves() {
    final u = _makeRotSet(_baseU);
    final f = _makeRotSet(_baseF);
    final r = _makeRotSet(_baseR);
    final l = _makeRotSet(_baseL);
    final d = _makeRotSet(_baseD);
    final b = _makeRotSet(_baseB);
    final m = _makeRotSet(_baseM);
    final e = _makeRotSet(_baseE);
    final s = _makeRotSet(_baseS);

    final rw = RouxMove.fromMoves([_baseR, m[2]], 'r');
    final rws = _makeRotSet(rw);
    final lw = RouxMove.fromMoves([_baseL, _baseM], 'l');
    final lws = _makeRotSet(lw);
    final uw = RouxMove.fromMoves([_baseU, _baseE], 'u');
    final uws = _makeRotSet(uw);
    final fw = RouxMove.fromMoves([_baseF, _baseS], 'f');
    final fws = _makeRotSet(fw);

    final x = RouxMove.fromMoves([_baseR, l[2], m[2]], 'x');
    final xs = _makeRotSet(x);
    final y = RouxMove.fromMoves([_baseU, _baseE, d[2]], 'y');
    final ys = _makeRotSet(y);
    final z = RouxMove.fromMoves([x, y, x, x, x], 'z');
    final zs = _makeRotSet(z);

    final moves = [
      RouxMove.fromCube(RouxCube.solved(), 'id'),
      ...u,
      ...f,
      ...r,
      ...l,
      ...d,
      ...b,
      ...m,
      ...e,
      ...s,
      ...xs,
      ...ys,
      ...zs,
      ...rws,
      ...lws,
      ...uws,
      ...fws,
    ];

    return {for (final move in moves) move.name: move};
  }

  static const RouxMove _baseU = RouxMove(
    cpc: [(0, 1), (1, 2), (2, 3), (3, 0)],
    coc: [0, 0, 0, 0],
    epc: [(0, 1), (1, 2), (2, 3), (3, 0)],
    eoc: [0, 0, 0, 0],
    tpc: [],
    name: 'U',
  );

  static const RouxMove _baseF = RouxMove(
    cpc: [(0, 3), (3, 7), (7, 4), (4, 0)],
    coc: [1, 2, 1, 2],
    epc: [(0, 11), (11, 4), (4, 8), (8, 0)],
    eoc: [1, 1, 1, 1],
    tpc: [],
    name: 'F',
  );

  static const RouxMove _baseR = RouxMove(
    cpc: [(3, 2), (2, 6), (6, 7), (7, 3)],
    coc: [1, 2, 1, 2],
    epc: [(3, 10), (10, 7), (7, 11), (11, 3)],
    eoc: [0, 0, 0, 0],
    tpc: [],
    name: 'R',
  );

  static const RouxMove _baseL = RouxMove(
    cpc: [(0, 4), (4, 5), (5, 1), (1, 0)],
    coc: [2, 1, 2, 1],
    epc: [(1, 8), (8, 5), (5, 9), (9, 1)],
    eoc: [0, 0, 0, 0],
    tpc: [],
    name: 'L',
  );

  static const RouxMove _baseD = RouxMove(
    cpc: [(4, 7), (7, 6), (6, 5), (5, 4)],
    coc: [0, 0, 0, 0],
    epc: [(4, 7), (7, 6), (6, 5), (5, 4)],
    eoc: [0, 0, 0, 0],
    tpc: [],
    name: 'D',
  );

  static const RouxMove _baseB = RouxMove(
    cpc: [(1, 5), (5, 6), (6, 2), (2, 1)],
    coc: [2, 1, 2, 1],
    epc: [(2, 9), (9, 6), (6, 10), (10, 2)],
    eoc: [1, 1, 1, 1],
    tpc: [],
    name: 'B',
  );

  static const RouxMove _baseM = RouxMove(
    cpc: [],
    coc: [],
    epc: [(0, 4), (4, 6), (6, 2), (2, 0)],
    eoc: [1, 1, 1, 1],
    tpc: [(0, 2), (2, 1), (1, 3), (3, 0)],
    name: 'M',
  );

  static const RouxMove _baseE = RouxMove(
    cpc: [],
    coc: [],
    epc: [(8, 9), (9, 10), (10, 11), (11, 8)],
    eoc: [1, 1, 1, 1],
    tpc: [(2, 4), (4, 3), (3, 5), (5, 2)],
    name: 'E',
  );

  static const RouxMove _baseS = RouxMove(
    cpc: [],
    coc: [],
    epc: [(1, 3), (3, 7), (7, 5), (5, 1)],
    eoc: [1, 1, 1, 1],
    tpc: [(0, 5), (5, 1), (1, 4), (4, 0)],
    name: 'S',
  );
}

class RouxMoveSeq {
  final List<RouxMove> moves;

  RouxMoveSeq(List<RouxMove> moves) : moves = List.unmodifiable(moves);

  factory RouxMoveSeq.parse(String alg) {
    return RouxMoveSeq(_parse(alg));
  }

  RouxMoveSeq inverse() {
    return RouxMoveSeq(moves.reversed.map((move) => move.inverse()).toList());
  }

  RouxMoveSeq collapse() {
    final collapsed = <RouxMove>[];
    for (final nextMove in moves) {
      if (collapsed.isEmpty) {
        collapsed.add(nextMove);
        continue;
      }
      final previous = collapsed.removeLast();
      collapsed.addAll(_combine(previous, nextMove).moves);
    }
    return RouxMoveSeq(collapsed);
  }

  @override
  String toString() => moves.map((move) => move.name).join(' ');

  static List<RouxMove> _parse(String alg) {
    return alg.split('\n').expand(_parseLine).toList();
  }

  static List<RouxMove> _parseLine(String line) {
    final commentIndex = line.indexOf('//');
    if (commentIndex >= 0) {
      line = line.substring(0, commentIndex);
    }

    final tokens = <String>[];
    var token = '';
    for (var i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '2' || ch == "'") {
        if (token.length == 1 || token.endsWith('w')) {
          token += ch;
          tokens.add(_normalizeToken(token));
          token = '';
        } else if (token.endsWith('2') && ch == "'") {
          tokens.add(_normalizeToken(token));
          token = '';
        }
      } else if (ch.trim().isEmpty) {
        if (token.isNotEmpty) {
          tokens.add(_normalizeToken(token));
          token = '';
        }
      } else if (_isAsciiLetter(ch)) {
        if (token.isNotEmpty) {
          tokens.add(_normalizeToken(token));
          token = '';
        }
        token += ch;
      }
    }
    if (token.isNotEmpty) {
      tokens.add(_normalizeToken(token));
    }

    return tokens
        .map((token) => RouxMove.all[token])
        .whereType<RouxMove>()
        .toList();
  }

  static String _normalizeToken(String token) {
    token = token.replaceAll('Rw', 'r').replaceAll('Lw', 'l');
    token = token.replaceAll('Uw', 'u').replaceAll('Fw', 'f');
    if (token.endsWith("2'")) return token.substring(0, token.length - 1);
    return token;
  }

  static bool _isAsciiLetter(String ch) {
    final code = ch.codeUnitAt(0);
    return (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
  }

  static RouxMoveSeq _combine(RouxMove move1, RouxMove move2) {
    if (move1.name[0] != move2.name[0]) {
      return RouxMoveSeq([move1, move2]);
    }

    final count = (_quarterCount(move1.name) + _quarterCount(move2.name)) % 4;
    if (count == 0) return RouxMoveSeq(const []);
    return RouxMoveSeq([RouxMove.all[move1.name[0] + _suffixForCount(count)]!]);
  }

  static int _quarterCount(String name) {
    if (name.length == 1) return 1;
    return name[1] == '2' ? 2 : 3;
  }

  static String _suffixForCount(int count) {
    return switch (count) {
      1 => '',
      2 => '2',
      3 => "'",
      _ => '',
    };
  }
}
