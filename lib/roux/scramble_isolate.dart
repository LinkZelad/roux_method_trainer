// 顶层函数，用于 Isolate 中生成 scramble。
// 这些函数必须是顶层函数（或静态方法），参数和返回值必须可序列化。

import 'dart:math';
import 'cube.dart';
import 'solver.dart';

class IsolateTimerRequest {
  final int mode;
  final int seed;

  const IsolateTimerRequest({required this.mode, required this.seed});
}

/// 在 Isolate 中生成计时器 scramble（仅返回 scramble 字符串）。
String generateTimerScramble(IsolateTimerRequest req) {
  final random = Random(req.seed);
  final scramble = switch (req.mode) {
    0 => _generateStandard(random),
    1 => _generateCmll(random),
    2 => _generateFb(random),
    3 => _generateSb(random),
    4 => _generateEolr(random),
    5 => _generateLse4c(random),
    6 => _generateFbdr(random),
    7 => _generateFs(random),
    _ => "R U R'",
  };
  return scramble;
}

String _generateStandard(Random random) {
  const moves = [
    'U', "U'", 'U2', 'D', "D'", 'D2',
    'F', "F'", 'F2', 'B', "B'", 'B2',
    'R', "R'", 'R2', 'L', "L'", 'L2',
  ];
  final result = <String>[];
  for (int i = 0; i < 25; i++) {
    result.add(moves[random.nextInt(moves.length)]);
  }
  return result.join(' ');
}

String _generateFb(Random random) {
  final solver = RouxSolver.fb();
  final scramble = solver.generateScramble(
    randomState: (r) => RouxCubeUtil.getRandomFb(random: r),
    random: random,
    maxDepth: 15,
    maxAttempts: 30,
  );
  return scramble?.toString() ?? "R U R'";
}

String _generateSb(Random random) {
  final solver = RouxSolver.sb();
  final scramble = solver.generateScramble(
    randomState: (r) => RouxCubeUtil.getRandomSb(random: r),
    random: random,
    maxDepth: 14,
    maxAttempts: 50,
  );
  return scramble?.toString() ?? "R U R'";
}

String _generateCmll(Random random) {
  // CMLL uses a simpler approach in timer mode
  const cmllCases = [
    "R U R' U' R' F R2 U' R' U' R U R' F'",
    "R U2 R' U' R U R' U' R U' R'",
    "R U2' R' U' R U' R'",
    "R2 D R' U2 R D' R' U2 R'",
  ];
  final caseAlg = cmllCases[random.nextInt(cmllCases.length)];
  final caseEffect = RouxCube.solved().applyAlg(caseAlg);
  final auf = ['', 'U', "U'", 'U2'][random.nextInt(4)];
  final targetCube = caseEffect.applyAlg(auf);
  final solver = RouxSolver.cmll();
  final scramble = solver.scrambleFor(targetCube, maxDepth: 12);
  return scramble?.toString() ??
      (RouxMoveSeq.parse(caseAlg).inverse().toString() +
          (auf.isEmpty ? '' : ' $auf'));
}

String _generateEolr(Random random) {
  final solver = RouxSolver.eolr();
  final scramble = solver.generateScramble(
    randomState: (r) => RouxCubeUtil.getRandomLse(random: r),
    random: random,
    maxDepth: 10,
    maxAttempts: 20,
  );
  return scramble?.toString() ?? 'M2 U M2';
}

String _generateLse4c(Random random) {
  final solver = RouxSolver.lse();
  final scramble = solver.generateScramble(
    randomState: (r) => RouxCubeUtil.getRandomLse4c(random: r),
    random: random,
    maxDepth: 8,
    maxAttempts: 20,
  );
  return scramble?.toString() ?? 'M2';
}

String _generateFbdr(Random random) {
  final solver = RouxSolver.fbdr();
  final scramble = solver.generateScramble(
    randomState: (r) => RouxCubeUtil.getRandomFbdr(random: r),
    random: random,
    maxDepth: 14,
    maxAttempts: 50,
  );
  return scramble?.toString() ?? "R U R'";
}

String _generateFs(Random random) {
  final solver = RouxSolver.fs();
  final scramble = solver.generateScramble(
    randomState: (r) => RouxCubeUtil.getRandomFs(random: r),
    random: random,
    maxDepth: 12,
    maxAttempts: 30,
  );
  return scramble?.toString() ?? "R U R'";
}

// ============================================================
// Practice Mode: returns (scramble, solution)
// ============================================================

class IsolatePracticeRequest {
  final int mode;
  final int seed;
  final String? cmllAlg;

  const IsolatePracticeRequest({
    required this.mode,
    required this.seed,
    this.cmllAlg,
  });
}

({String scramble, String? solution}) generatePracticeScramble(
  IsolatePracticeRequest req,
) {
  final random = Random(req.seed);
  return switch (req.mode) {
    0 => _practiceStandard(random),
    1 => _practiceCmll(random, req.cmllAlg),
    2 => _practiceFb(random),
    3 => _practiceSb(random),
    4 => _practiceEolr(random),
    5 => _practiceLse4c(random),
    6 => _practiceFbdr(random),
    7 => _practiceFs(random),
    _ => (scramble: "R U R'", solution: null),
  };
}

({String scramble, String? solution}) _practiceStandard(Random random) {
  const moves = [
    'U', "U'", 'U2', 'D', "D'", 'D2',
    'F', "F'", 'F2', 'B', "B'", 'B2',
    'R', "R'", 'R2', 'L', "L'", 'L2',
  ];
  final result = <String>[];
  for (int i = 0; i < 25; i++) {
    result.add(moves[random.nextInt(moves.length)]);
  }
  return (scramble: result.join(' '), solution: null);
}

({String scramble, String? solution}) _practiceFb(Random random) {
  final solver = RouxSolver.fb();
  final scramble = solver.generateScramble(
    randomState: (r) => RouxCubeUtil.getRandomFb(random: r),
    random: random,
    maxDepth: 15,
    maxAttempts: 30,
  );
  if (scramble == null) {
    return (scramble: "R U R'", solution: null);
  }
  final cube = RouxCube.solved().apply(scramble);
  final solutions = solver.solve(cube, minDepth: 0, maxDepth: 15, capacity: 1);
  return (
    scramble: scramble.toString(),
    solution: solutions.isNotEmpty ? solutions.first.toString() : null,
  );
}

({String scramble, String? solution}) _practiceSb(Random random) {
  final solver = RouxSolver.sb();
  final scramble = solver.generateScramble(
    randomState: (r) => RouxCubeUtil.getRandomSb(random: r),
    random: random,
    maxDepth: 14,
    maxAttempts: 50,
  );
  if (scramble == null) {
    return (scramble: "R U R'", solution: null);
  }
  final cube = RouxCube.solved().apply(scramble);
  final solutions = solver.solve(cube, minDepth: 0, maxDepth: 14, capacity: 1);
  return (
    scramble: scramble.toString(),
    solution: solutions.isNotEmpty ? solutions.first.toString() : null,
  );
}

({String scramble, String? solution}) _practiceCmll(
  Random random,
  String? cmllAlg,
) {
  final alg = cmllAlg ?? "R U R' U' R' F R2 U' R' U' R U R' F'";
  final caseEffect = RouxCube.solved().applyAlg(alg);
  final auf = ['', 'U', "U'", 'U2'][random.nextInt(4)];
  final targetCube = caseEffect.applyAlg(auf);
  final solver = RouxSolver.cmll();
  final scramble = solver.scrambleFor(targetCube, maxDepth: 12);
  final scrambleStr = scramble?.toString() ??
      (RouxMoveSeq.parse(alg).inverse().toString() +
          (auf.isEmpty ? '' : ' $auf'));
  return (scramble: scrambleStr, solution: alg);
}

({String scramble, String? solution}) _practiceEolr(Random random) {
  final solver = RouxSolver.eolr();
  final scramble = solver.generateScramble(
    randomState: (r) => RouxCubeUtil.getRandomLse(random: r),
    random: random,
    maxDepth: 10,
    maxAttempts: 20,
  );
  if (scramble == null) {
    return (scramble: 'M2 U M2', solution: null);
  }
  final cube = RouxCube.solved().apply(scramble);
  final solutions = solver.solve(cube, minDepth: 0, maxDepth: 10, capacity: 1);
  return (
    scramble: scramble.toString(),
    solution: solutions.isNotEmpty ? solutions.first.toString() : null,
  );
}

({String scramble, String? solution}) _practiceLse4c(Random random) {
  final solver = RouxSolver.lse();
  final scramble = solver.generateScramble(
    randomState: (r) => RouxCubeUtil.getRandomLse4c(random: r),
    random: random,
    maxDepth: 8,
    maxAttempts: 20,
  );
  if (scramble == null) {
    return (scramble: 'M2', solution: null);
  }
  final cube = RouxCube.solved().apply(scramble);
  final solutions = solver.solve(cube, minDepth: 0, maxDepth: 8, capacity: 1);
  return (
    scramble: scramble.toString(),
    solution: solutions.isNotEmpty ? solutions.first.toString() : null,
  );
}

({String scramble, String? solution}) _practiceFbdr(Random random) {
  final solver = RouxSolver.fbdr();
  final scramble = solver.generateScramble(
    randomState: (r) => RouxCubeUtil.getRandomFbdr(random: r),
    random: random,
    maxDepth: 14,
    maxAttempts: 50,
  );
  if (scramble == null) {
    return (scramble: "R U R'", solution: null);
  }
  final cube = RouxCube.solved().apply(scramble);
  final solutions = solver.solve(cube, minDepth: 0, maxDepth: 14, capacity: 1);
  return (
    scramble: scramble.toString(),
    solution: solutions.isNotEmpty ? solutions.first.toString() : null,
  );
}

({String scramble, String? solution}) _practiceFs(Random random) {
  final solver = RouxSolver.fs();
  final scramble = solver.generateScramble(
    randomState: (r) => RouxCubeUtil.getRandomFs(random: r),
    random: random,
    maxDepth: 12,
    maxAttempts: 30,
  );
  if (scramble == null) {
    return (scramble: "R U R'", solution: null);
  }
  final cube = RouxCube.solved().apply(scramble);
  final solutions = solver.solve(cube, minDepth: 0, maxDepth: 12, capacity: 1);
  return (
    scramble: scramble.toString(),
    solution: solutions.isNotEmpty ? solutions.first.toString() : null,
  );
}
