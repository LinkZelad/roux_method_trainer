# FB/SB/CMLL Random-State Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace placeholder random-move scramblers for FB, SB, and CMLL training modes with true random-state scramble generation using BFS pruning tables + IDDFS solvers.

**Architecture:** Extend existing `RouxCube` / `RouxPruner` / `RouxSolver` pattern. Each stage gets coordinate encoders, pruning tables built via BFS, and an IDDFS solver. The solver generates a scramble by solving a random target state and inverting the solution.

**Tech Stack:** Dart, Flutter test framework. No new dependencies.

**Key insight:** The solver moveset for FB/SB is {U,D,F,B,R,L,M} (all turns). Centers at tp[4],tp[5] are never moved by these moves, so center tracking is unnecessary. CMLL uses {U,R,F} only. The SB solver reuses the FB edge pruner as one of its sub-tables.

---

### Task 1: FB Coordinate Encoders + FB Pruner

**Files:**
- Modify: `lib/roux/pruner.dart`
- Test: `test/roux_pruner_test.dart`

- [ ] **Step 1: Write failing test for FB corner pruner**

In `test/roux_pruner_test.dart`, add:

```dart
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
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd roux_trainer && flutter test test/roux_pruner_test.dart`
Expected: FAIL — `RouxPruner.fbCorner` and `RouxPruner.fbEdge` don't exist

- [ ] **Step 3: Implement FB coordinate encoders and pruner factories**

In `lib/roux/pruner.dart`, add static encoder methods and factory methods.

FB corner coordinate: tracks positions and orientations of corners 4 and 5.
- `pos4 = cube.cp.indexOf(4)` (0-7), `ori4 = cube.co[pos4]` (0-2)
- `pos5 = cube.cp.indexOf(5)` (0-7), `ori5 = cube.co[pos5]` (0-2)
- Encoding: `pos4 * 72 + ori4 * 24 + pos5 * 3 + ori5`
- Table size: 576

FB edge coordinate: tracks positions and orientations of edges 5, 8, 9.
- Encoding: `pos5 * 1152 + ori5 * 576 + pos8 * 48 + ori8 * 24 + pos9 * 2 + ori9`
- Table size: 13824

Moveset for both: `['U', "U'", 'U2', 'D', "D'", 'D2', 'F', "F'", 'F2', 'B', "B'", 'B2', 'R', "R'", 'R2', 'L', "L'", 'L2', 'M', "M'", 'M2']`

Max depth: 10 (sufficient to fill all reachable coordinate states).

```dart
factory RouxPruner.fbCorner() {
  return RouxPruner(
    size: 576,
    maxDepth: 10,
    encode: _encodeFbCorner,
    moveset: const ['U', "U'", 'U2', 'D', "D'", 'D2', 'F', "F'", 'F2',
                     'B', "B'", 'B2', 'R', "R'", 'R2', 'L', "L'", 'L2',
                     'M', "M'", 'M2'],
    solvedStates: [RouxCube.solved()],
    name: 'fb-corner',
  );
}

factory RouxPruner.fbEdge() {
  return RouxPruner(
    size: 13824,
    maxDepth: 10,
    encode: _encodeFbEdge,
    moveset: const ['U', "U'", 'U2', 'D', "D'", 'D2', 'F', "F'", 'F2',
                     'B', "B'", 'B2', 'R', "R'", 'R2', 'L', "L'", 'L2',
                     'M', "M'", 'M2'],
    solvedStates: [RouxCube.solved()],
    name: 'fb-edge',
  );
}

static int _encodeFbCorner(RouxCube cube) {
  final pos4 = cube.cp.indexOf(4);
  final pos5 = cube.cp.indexOf(5);
  return pos4 * 72 + cube.co[pos4] * 24 + pos5 * 3 + cube.co[pos5];
}

static int _encodeFbEdge(RouxCube cube) {
  final pos5 = cube.ep.indexOf(5);
  final pos8 = cube.ep.indexOf(8);
  final pos9 = cube.ep.indexOf(9);
  return pos5 * 1152 + cube.eo[pos5] * 576 +
         pos8 * 48 + cube.eo[pos8] * 24 +
         pos9 * 2 + cube.eo[pos9];
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd roux_trainer && flutter test test/roux_pruner_test.dart`
Expected: All FB pruner tests PASS

- [ ] **Step 5: Commit**

```bash
git add roux_trainer/lib/roux/pruner.dart roux_trainer/test/roux_pruner_test.dart
git commit -m "feat: add FB corner and edge pruning tables"
```

---

### Task 2: FB Solver + FB Random State Generator

**Files:**
- Modify: `lib/roux/solver.dart`
- Modify: `lib/roux/cube.dart` (add `getRandomFb`)
- Test: `test/roux_solver_test.dart`, `test/roux_cube_test.dart`

- [ ] **Step 1: Write failing test for FB solver**

In `test/roux_solver_test.dart`, add:

```dart
test('FB solver solves a random FB state', () {
  final solver = RouxSolver.fb();
  final random = Random(42);
  for (var i = 0; i < 5; i++) {
    final cube = RouxCubeUtil.getRandomFb(random: random);
    final solutions = solver.solve(cube, minDepth: 0, maxDepth: 15, capacity: 1);
    expect(solutions, hasLength(1));
    final solved = cube.apply(solutions.first);
    expect(RouxCubeUtil.isSolved(solved, RouxCubeMask.fb), isTrue);
  }
});

test('FB solver generates a valid scramble', () {
  final solver = RouxSolver.fb();
  final scramble = solver.generateScramble(
    randomState: (random) => RouxCubeUtil.getRandomFb(random: random),
    random: Random(7),
    maxDepth: 15,
    maxAttempts: 30,
  );
  expect(scramble, isNotNull);
  expect(scramble!.moves.length, lessThanOrEqualTo(15));
  final cube = RouxCube.solved().apply(scramble);
  expect(RouxCubeUtil.isSolved(cube, RouxCubeMask.fb), isFalse);
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd roux_trainer && flutter test test/roux_solver_test.dart`
Expected: FAIL — `RouxSolver.fb` and `RouxCubeUtil.getRandomFb` don't exist

- [ ] **Step 3: Implement `getRandomFb` in cube.dart**

In `RouxCubeUtil` class in `lib/roux/cube.dart`, add:

```dart
static RouxCube getRandomFb({Random? random}) {
  random ??= Random();
  while (true) {
    final cube = getRandomWithMask(RouxCubeMask.fb, random: random);
    if (!isSolved(cube, RouxCubeMask.fb)) return cube;
  }
}
```

- [ ] **Step 4: Implement `RouxSolver.fb()` in solver.dart**

```dart
factory RouxSolver.fb() {
  final fbCorner = RouxPruner.fbCorner();
  final fbEdge = RouxPruner.fbEdge();
  return RouxSolver(
    isSolved: (cube) => RouxCubeUtil.isSolved(cube, RouxCubeMask.fb),
    moveset: const ['U', "U'", 'U2', 'D', "D'", 'D2', 'F', "F'", 'F2',
                     'B', "B'", 'B2', 'R', "R'", 'R2', 'L', "L'", 'L2',
                     'M', "M'", 'M2'],
    pruners: [fbCorner, fbEdge],
  );
}
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `cd roux_trainer && flutter test test/roux_solver_test.dart`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add roux_trainer/lib/roux/solver.dart roux_trainer/lib/roux/cube.dart roux_trainer/test/roux_solver_test.dart
git commit -m "feat: add FB solver with random-state scramble generation"
```

---

### Task 3: SB Coordinate Encoders + SB Pruner

**Files:**
- Modify: `lib/roux/pruner.dart`
- Test: `test/roux_pruner_test.dart`

- [ ] **Step 1: Write failing test for SB pruners**

In `test/roux_pruner_test.dart`, add:

```dart
test('SB corner pruner gives distance 0 for solved state', () {
  final pruner = RouxPruner.sbCorner()..init();
  expect(pruner.query(RouxCube.solved()), 0);
});

test('SB edge A pruner gives distance 0 for solved state', () {
  final pruner = RouxPruner.sbEdgeA()..init();
  expect(pruner.query(RouxCube.solved()), 0);
});

test('SB pruners detect multi-move distances', () {
  final sbCorner = RouxPruner.sbCorner()..init();
  final sbEdgeA = RouxPruner.sbEdgeA()..init();
  final fbEdge = RouxPruner.fbEdge()..init();
  final cube = RouxCube.solved().applyAlg("R U R'");
  expect(sbCorner.query(cube), greaterThan(0));
  expect(sbEdgeA.query(cube), greaterThanOrEqualTo(0));
  expect(fbEdge.query(cube), greaterThanOrEqualTo(0));
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd roux_trainer && flutter test test/roux_pruner_test.dart`
Expected: FAIL — `RouxPruner.sbCorner`, `RouxPruner.sbEdgeA` don't exist

- [ ] **Step 3: Implement SB pruner factories**

SB corner: corners 6,7. Same structure as FB corner, table size 576.

SB edge A: edges 7, 10, 11. Same structure as FB edge, table size 13824.

SB reuses `RouxPruner.fbEdge()` for edges 5,8,9 (same encoding, same moveset, same solved state).

```dart
factory RouxPruner.sbCorner() {
  return RouxPruner(
    size: 576,
    maxDepth: 10,
    encode: _encodeSbCorner,
    moveset: const ['U', "U'", 'U2', 'D', "D'", 'D2', 'F', "F'", 'F2',
                     'B', "B'", 'B2', 'R', "R'", 'R2', 'L', "L'", 'L2',
                     'M', "M'", 'M2'],
    solvedStates: [RouxCube.solved()],
    name: 'sb-corner',
  );
}

factory RouxPruner.sbEdgeA() {
  return RouxPruner(
    size: 13824,
    maxDepth: 10,
    encode: _encodeSbEdgeA,
    moveset: const ['U', "U'", 'U2', 'D', "D'", 'D2', 'F', "F'", 'F2',
                     'B', "B'", 'B2', 'R', "R'", 'R2', 'L', "L'", 'L2',
                     'M', "M'", 'M2'],
    solvedStates: [RouxCube.solved()],
    name: 'sb-edge-a',
  );
}

static int _encodeSbCorner(RouxCube cube) {
  final pos6 = cube.cp.indexOf(6);
  final pos7 = cube.cp.indexOf(7);
  return pos6 * 72 + cube.co[pos6] * 24 + pos7 * 3 + cube.co[pos7];
}

static int _encodeSbEdgeA(RouxCube cube) {
  final pos7 = cube.ep.indexOf(7);
  final pos10 = cube.ep.indexOf(10);
  final pos11 = cube.ep.indexOf(11);
  return pos7 * 1152 + cube.eo[pos7] * 576 +
         pos10 * 48 + cube.eo[pos10] * 24 +
         pos11 * 2 + cube.eo[pos11];
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd roux_trainer && flutter test test/roux_pruner_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add roux_trainer/lib/roux/pruner.dart roux_trainer/test/roux_pruner_test.dart
git commit -m "feat: add SB corner and edge-A pruning tables"
```

---

### Task 4: SB Solver + SB Random State Generator

**Files:**
- Modify: `lib/roux/solver.dart`
- Modify: `lib/roux/cube.dart` (add `getRandomSb`)
- Test: `test/roux_solver_test.dart`, `test/roux_cube_test.dart`

- [ ] **Step 1: Write failing test for SB solver**

In `test/roux_solver_test.dart`, add:

```dart
test('SB solver solves a random SB state', () {
  final solver = RouxSolver.sb();
  final random = Random(99);
  for (var i = 0; i < 5; i++) {
    final cube = RouxCubeUtil.getRandomSb(random: random);
    // Random state should have FB solved, SB not solved
    expect(RouxCubeUtil.isSolved(cube, RouxCubeMask.fb), isTrue);
    expect(RouxCubeUtil.isSolved(cube, RouxCubeMask.sb), isFalse);
    final solutions = solver.solve(cube, minDepth: 0, maxDepth: 18, capacity: 1);
    expect(solutions, hasLength(1));
    final solved = cube.apply(solutions.first);
    expect(RouxCubeUtil.isSolved(solved, RouxCubeMask.sb), isTrue);
  }
});

test('SB solver generates a valid scramble', () {
  final solver = RouxSolver.sb();
  final scramble = solver.generateScramble(
    randomState: (random) => RouxCubeUtil.getRandomSb(random: random),
    random: Random(13),
    maxDepth: 18,
    maxAttempts: 30,
  );
  expect(scramble, isNotNull);
  expect(scramble!.moves.length, lessThanOrEqualTo(18));
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd roux_trainer && flutter test test/roux_solver_test.dart`
Expected: FAIL

- [ ] **Step 3: Add `sbOnly` mask and implement `getRandomSb` in cube.dart**

First, add a new mask in `RouxCubeMask` class. This mask tracks only SB-specific pieces (corners 6,7 and edges 7,10,11), keeping FB pieces solved:

```dart
static const sbOnly = RouxCubeMask(
  cp: [0, 0, 0, 0, 0, 0, 1, 1],
  ep: [0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1],
);
```

Then add `getRandomSb` in `RouxCubeUtil`:

```dart
static RouxCube getRandomSb({Random? random}) {
  random ??= Random();
  while (true) {
    final cube = getRandomWithMask(RouxCubeMask.sbOnly, random: random);
    if (!isSolved(cube, RouxCubeMask.sb)) return cube;
  }
}
```

The `sbOnly` mask randomizes only corners 6,7 and edges 7,10,11. The rest stay solved (identity permutation, zero orientation). The result is a cube where FB is solved and SB-specific pieces are randomly placed.

- [ ] **Step 4: Implement `RouxSolver.sb()` in solver.dart**

Uses three pruners: sbCorner, sbEdgeA, and fbEdge (reused).

```dart
factory RouxSolver.sb() {
  final sbCorner = RouxPruner.sbCorner();
  final sbEdgeA = RouxPruner.sbEdgeA();
  final fbEdge = RouxPruner.fbEdge();
  return RouxSolver(
    isSolved: (cube) => RouxCubeUtil.isSolved(cube, RouxCubeMask.sb),
    moveset: const ['U', "U'", 'U2', 'D', "D'", 'D2', 'F', "F'", 'F2',
                     'B', "B'", 'B2', 'R', "R'", 'R2', 'L', "L'", 'L2',
                     'M', "M'", 'M2'],
    pruners: [sbCorner, sbEdgeA, fbEdge],
  );
}
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `cd roux_trainer && flutter test test/roux_solver_test.dart`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add roux_trainer/lib/roux/solver.dart roux_trainer/lib/roux/cube.dart roux_trainer/test/roux_solver_test.dart
git commit -m "feat: add SB solver with random-state scramble generation"
```

---

### Task 5: CMLL Coordinate Encoder + CMLL Pruner

**Files:**
- Modify: `lib/roux/pruner.dart`
- Test: `test/roux_pruner_test.dart`

- [ ] **Step 1: Write failing test for CMLL pruner**

In `test/roux_pruner_test.dart`, add:

```dart
test('CMLL pruner covers all 648 states', () {
  final pruner = RouxPruner.cmll()..init();
  expect(pruner.query(RouxCube.solved()), 0);
  // Verify a single U move gives distance 1
  expect(pruner.query(RouxCube.solved().applyAlg('U')), lessThanOrEqualTo(1));
  // Verify a known CMLL case has finite distance
  expect(pruner.query(RouxCube.solved().applyAlg("R U R' U R U2 R'")),
         greaterThanOrEqualTo(0));
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd roux_trainer && flutter test test/roux_pruner_test.dart`
Expected: FAIL

- [ ] **Step 3: Implement CMLL pruner**

CMLL coordinate encodes top 4 corners (positions 0-3).
- Permutation: Lehmer code for cp[0..3] — 24 states (4! values)
- Orientation: `co[0]*9 + co[1]*3 + co[2]` — 27 states (co[3] determined by sum mod 3)
- Total: 24 × 27 = 648

Moveset: `['U', "U'", 'U2', 'R', "R'", 'R2', 'F', "F'", 'F2']`

```dart
factory RouxPruner.cmll() {
  return RouxPruner(
    size: 648,
    maxDepth: 11,
    encode: _encodeCmll,
    moveset: const ['U', "U'", 'U2', 'R', "R'", 'R2', 'F', "F'", 'F2'],
    solvedStates: [RouxCube.solved()],
    name: 'cmll',
  );
}

static int _encodeCmll(RouxCube cube) {
  final permIdx = _lehmer4(cube.cp[0], cube.cp[1], cube.cp[2], cube.cp[3]);
  final oriIdx = cube.co[0] * 9 + cube.co[1] * 3 + cube.co[2];
  return permIdx * 27 + oriIdx;
}

static int _lehmer4(int a, int b, int c, int d) {
  var code = 0;
  final digits = [a, b, c, d];
  for (var i = 0; i < 3; i++) {
    var inversions = 0;
    for (var j = i + 1; j < 4; j++) {
      if (digits[j] < digits[i]) inversions++;
    }
    code = code * (4 - i) + inversions;
  }
  return code;
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd roux_trainer && flutter test test/roux_pruner_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add roux_trainer/lib/roux/pruner.dart roux_trainer/test/roux_pruner_test.dart
git commit -m "feat: add CMLL pruning table"
```

---

### Task 6: CMLL Solver + CMLL Random State Generator

**Files:**
- Modify: `lib/roux/solver.dart`
- Modify: `lib/roux/cube.dart` (add `getRandomCmll`)
- Test: `test/roux_solver_test.dart`

- [ ] **Step 1: Write failing test for CMLL solver**

In `test/roux_solver_test.dart`, add:

```dart
test('CMLL solver solves a random CMLL state', () {
  final solver = RouxSolver.cmll();
  final random = Random(77);
  for (var i = 0; i < 5; i++) {
    final cube = RouxCubeUtil.getRandomCmll(random: random);
    final solutions = solver.solve(cube, minDepth: 0, maxDepth: 12, capacity: 1);
    expect(solutions, hasLength(1));
    final solved = cube.apply(solutions.first);
    expect(solved.isSolved, isTrue);
  }
});

test('CMLL solver generates a valid scramble', () {
  final solver = RouxSolver.cmll();
  final scramble = solver.generateScramble(
    randomState: (random) => RouxCubeUtil.getRandomCmll(random: random),
    random: Random(21),
    maxDepth: 12,
    maxAttempts: 30,
  );
  expect(scramble, isNotNull);
  expect(scramble!.moves.length, lessThanOrEqualTo(12));
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd roux_trainer && flutter test test/roux_solver_test.dart`
Expected: FAIL

- [ ] **Step 3: Implement `getRandomCmll` in cube.dart**

Generate a random top-4-corner configuration with bottom solved.

```dart
static RouxCube getRandomCmll({Random? random}) {
  random ??= Random();
  while (true) {
    // Randomize top corners only (positions 0-3)
    final indices = [0, 1, 2, 3]..shuffle(random);
    final cp = List.filled(8, 0);
    for (var i = 0; i < 4; i++) cp[i] = indices[i];
    cp[4] = 4; cp[5] = 5; cp[6] = 6; cp[7] = 7;

    // Random orientations satisfying sum mod 3 = 0
    var coSum = 0;
    final co = List.filled(8, 0);
    for (var i = 0; i < 3; i++) {
      co[i] = random.nextInt(3);
      coSum += co[i];
    }
    co[3] = (3 - coSum % 3) % 3;

    final cube = RouxCube(
      cp: cp, co: co,
      ep: const [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
      eo: List.filled(12, 0),
    );

    if (!cube.isSolved) return cube;
  }
}
```

- [ ] **Step 4: Implement `RouxSolver.cmll()` in solver.dart**

```dart
factory RouxSolver.cmll() {
  return RouxSolver(
    isSolved: (cube) => cube.isSolved,
    moveset: const ['U', "U'", 'U2', 'R', "R'", 'R2', 'F', "F'", 'F2'],
    pruners: [RouxPruner.cmll()],
  );
}
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `cd roux_trainer && flutter test test/roux_solver_test.dart`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add roux_trainer/lib/roux/solver.dart roux_trainer/lib/roux/cube.dart roux_trainer/test/roux_solver_test.dart
git commit -m "feat: add CMLL solver with random-state scramble generation"
```

---

### Task 7: CMLL Case Identification

**Files:**
- Modify: `lib/models/cmll_algs.dart`
- Test: `test/timer_provider_test.dart` (or new test file)

- [ ] **Step 1: Write failing test for case identification**

```dart
test('identifyCmllCase identifies a known case from cube state', () {
  final alg = cmllAlgs.firstWhere((c) => c.id == 's_left_bar');
  // Apply the algorithm to solved cube, then identify the resulting state
  final cube = RouxCube.solved().applyAlg(alg.alg);
  final identified = identifyCmllCase(cube);
  // The identified case should have the same effect (possibly with AUF)
  expect(identified, isNotNull);
  // Apply identified alg to the scrambled state should solve corners
  final solved = cube.applyAlg(identified!.alg);
  expect(solved.cp[0], equals(0));
  expect(solved.cp[1], equals(1));
  expect(solved.cp[2], equals(2));
  expect(solved.cp[3], equals(3));
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd roux_trainer && flutter test test/timer_provider_test.dart`
Expected: FAIL — `identifyCmllCase` doesn't exist

- [ ] **Step 3: Implement `identifyCmllCase`**

Add to `lib/models/cmll_algs.dart`:

```dart
import '../roux/cube.dart';

/// Identify which CMLL case a cube state corresponds to.
/// The cube should have SB solved and only top corners scrambled.
/// Returns null if no case matches (should not happen for valid CMLL states).
CmllCase? identifyCmllCase(RouxCube cube) {
  for (final alg in cmllAlgs) {
    for (final auf in ['', 'U', "U'", 'U2']) {
      final setup = RouxCube.solved().applyAlg('$auf ${alg.alg}');
      if (_sameTopCorners(cube, setup)) {
        return alg;
      }
    }
  }
  return null;
}

bool _sameTopCorners(RouxCube a, RouxCube b) {
  for (var i = 0; i < 4; i++) {
    if (a.cp[i] != b.cp[i] || a.co[i] != b.co[i]) return false;
  }
  return true;
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd roux_trainer && flutter test test/timer_provider_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add roux_trainer/lib/models/cmll_algs.dart roux_trainer/test/timer_provider_test.dart
git commit -m "feat: add CMLL case identification from cube state"
```

---

### Task 8: TimerProvider Integration

**Files:**
- Modify: `lib/providers/timer_provider.dart`
- Test: `test/timer_provider_test.dart`

- [ ] **Step 1: Write failing tests for new scramble generation**

```dart
test('FB mode generates a scramble that produces an FB state', () {
  final provider = TimerProvider();
  provider.setMode(TrainingMode.fb);
  final cube = RouxCube.solved().applyAlg(provider.scramble);
  expect(RouxCubeUtil.isSolved(cube, RouxCubeMask.fb), isFalse);
  // Scramble should be solver-based, not random moves
  // A 15-move scramble should have ≤ 15 moves
  final moves = provider.scramble.split(' ').where((s) => s.isNotEmpty).toList();
  expect(moves.length, lessThanOrEqualTo(15));
});

test('SB mode generates a scramble with FB solved', () {
  final provider = TimerProvider();
  provider.setMode(TrainingMode.sb);
  final cube = RouxCube.solved().applyAlg(provider.scramble);
  expect(RouxCubeUtil.isSolved(cube, RouxCubeMask.fb), isTrue);
  expect(RouxCubeUtil.isSolved(cube, RouxCubeMask.sb), isFalse);
});

test('CMLL mode generates a solver-based scramble', () {
  final provider = TimerProvider();
  provider.setMode(TrainingMode.cmll);
  expect(provider.scramble, isNotEmpty);
  expect(provider.currentCaseName, isNotNull);
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd roux_trainer && flutter test test/timer_provider_test.dart`
Expected: Some tests FAIL (FB/SB use random moves, not solver-based)

- [ ] **Step 3: Update TimerProvider**

Add solver instances and update `_generateNewScramble`:

```dart
static final RouxSolver _fbSolver = RouxSolver.fb();
static final RouxSolver _sbSolver = RouxSolver.sb();
static final RouxSolver _cmllSolver = RouxSolver.cmll();
```

Replace the FB case in `_generateNewScramble`:

```dart
case TrainingMode.fb:
  _scramble = _fbSolver
          .generateScramble(
            randomState: (random) => RouxCubeUtil.getRandomFb(random: random),
            random: _rand,
            maxDepth: 15,
            maxAttempts: 30,
          )
          ?.toString() ??
      'R U R\'';
  _currentCaseId = null;
  _currentCaseName = null;
  _currentCaseAlg = null;
  break;
```

Replace the SB case:

```dart
case TrainingMode.sb:
  _scramble = _sbSolver
          .generateScramble(
            randomState: (random) => RouxCubeUtil.getRandomSb(random: random),
            random: _rand,
            maxDepth: 18,
            maxAttempts: 30,
          )
          ?.toString() ??
      "R U R'";
  _currentCaseId = null;
  _currentCaseName = null;
  _currentCaseAlg = null;
  break;
```

Replace the CMLL case:

```dart
case TrainingMode.cmll:
  final case_ =
      _selectedCmllCase ??
      getRandomCmllCase(categories: _selectedCmllCategories);
  _currentCaseId = case_.id;
  _currentCaseName = '${case_.category} ${case_.name}';
  _currentCaseAlg = case_.alg;
  // Generate random CMLL state matching the target case, then scramble
  _scramble = _cmllSolver
          .generateScramble(
            randomState: (random) => _randomCmllStateForCase(case_, random),
            random: _rand,
            maxDepth: 12,
            maxAttempts: 30,
          )
          ?.toString() ??
      "R U R' U' R U R'";
  break;
```

Add helper for generating CMLL state matching a specific case:

```dart
RouxCube _randomCmllStateForCase(CmllCase case_, Random random) {
  final aufOptions = ['', 'U', "U'", 'U2'];
  final auf = aufOptions[random.nextInt(aufOptions.length)];
  return RouxCube.solved().applyAlg('$auf ${case_.alg}');
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd roux_trainer && flutter test test/timer_provider_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add roux_trainer/lib/providers/timer_provider.dart roux_trainer/test/timer_provider_test.dart
git commit -m "feat: integrate FB/SB/CMLL random-state scrambles into TimerProvider"
```

---

### Task 9: Run Full Test Suite + Static Analysis

- [ ] **Step 1: Run all tests**

Run: `cd roux_trainer && flutter test`
Expected: All tests pass

- [ ] **Step 2: Run static analysis**

Run: `cd roux_trainer && flutter analyze`
Expected: No issues

- [ ] **Step 3: Format code**

Run: `cd roux_trainer && dart format lib test`

- [ ] **Step 4: Commit any formatting fixes**

```bash
git add -A && git commit -m "style: format code" || echo "No formatting changes needed"
```
