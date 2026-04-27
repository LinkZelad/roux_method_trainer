# FB/SB/CMLL Random-State Scramble Generation & Solver

## Problem

FB and SB training modes use `ScrambleGenerator.generateRoux()` (random moves, not random-state). CMLL training uses a fixed SB setup + inverse of known algorithm. None of these produce true random-state scrambles, which are the gold standard for training quality.

## Approach

Build dedicated pruning tables and IDDFS solvers for each stage, following the existing LSE/EOLR pattern in `roux/pruner.dart` and `roux/solver.dart`.

## Architecture

No new files. Extend existing files:

- `lib/roux/cube.dart` — FB/SB/CMLL coordinate extraction methods + random state generators
- `lib/roux/pruner.dart` — `RouxPruner.fb()`, `RouxPruner.sb()`, `RouxPruner.cmll()` factory methods
- `lib/roux/solver.dart` — `RouxSolver.fb()`, `RouxSolver.sb()`, `RouxSolver.cmll()` factory methods
- `lib/providers/timer_provider.dart` — switch FB/SB/CMLL modes to solver-based scramble generation

| Stage | Pruner coordinate space | BFS depth | Solver max depth |
|-------|------------------------|-----------|------------------|
| FB    | ~11K (split into 2 tables) | 8-10   | 15               |
| SB    | ~21K (split into 3 tables) | 8-10   | 18               |
| CMLL  | 648 (single table)         | 11      | 12               |

## FB Solver & Pruner

**Pieces**: corners 4,5 (DFL, DBL) + edges 5,8,9 (DL, FL, BL) + centers 4,5 (D, L)

**Coordinate design** — split into two independent sub-coordinates, BFS builds separate tables, heuristic = max of both:

- **FB_Corner** (~504 valid states): position (0-7) + orientation (0-2) for corners 4 and 5. Encoding: `pos4 * 72 + ori4 * 24 + pos5 * 3 + ori5`
- **FB_Edge** (~10,560 valid states): position (0-11) + orientation (0-1) for edges 5, 8, 9. Encoding similar to existing LSE pruner.

Center tracking is folded into FB_Edge or a separate small table (to be determined during implementation based on `tp` encoding).

**Pruner**: `RouxPruner.fb()` returns two tables (`fbCorner`, `fbEdge`). BFS from FB-solved state outward to depth 8-10. Each table is a `Uint8List`, value = min distance to FB solved, 255 = beyond range.

**Solver**: `RouxSolver.fb()` with full moveset {U,U',U2,D,D',D2,F,F',F2,B,B',B2,R,R',R2,L,L',L2,M,M',M2}. IDDFS with heuristic = `max(fbCorner[cube], fbEdge[cube])`.

**Random state**: `RouxCubeUtil.getRandomFb()` — from solved cube, randomize FB piece positions/orientations, exclude already-solved state.

## SB Solver & Pruner

**Pieces**: additional corners 6,7 (DFR, DBR) + edges 7,10,11 (DR, FR, BR). FB must be solved at target.

**Coordinate design** — split into three sub-coordinates:

- **SB_Corner** (~504 valid states): position + orientation for corners 6 and 7
- **SB_Edge_A** (~10,560 valid states): position + orientation for edges 7, 10, 11 (SB-specific)
- **SB_Edge_B** (~10,560 valid states): position + orientation for edges 5, 8, 9 (must stay solved from FB)

Heuristic = `max(sbCorner, sbEdgeA, sbEdgeB)`.

**Pruner**: `RouxPruner.sb()` returns three tables. BFS from {FB+SB all solved} outward. FB pieces may be disrupted during BFS expansion — this is fine, the pruner only provides a lower bound and IDDFS verifies the full solution.

**Solver**: `RouxSolver.sb()` with same full moveset. IDDFS + three-table heuristic.

**Random state**: `RouxCubeUtil.getRandomSb()` — from solved cube, randomize corners 6,7 and edges 7,10,11 positions/orientations only. Exclude already-solved state.

## CMLL Solver & Pruner

**Pieces**: top 4 corners only (corners 0,1,2,3 = UFR, UBR, UBL, UFL). Bottom corners fixed (SB solved).

**Coordinate design**:

- 4-corner permutation: 4! = 24
- 4-corner orientation: 3^4 / 3 = 27 (orientation sum mod 3 = 0 constraint)
- Total: 24 × 27 = **648 states**
- Encoding: perm_index * 27 + ori_index

**Pruner**: `RouxPruner.cmll()` — single table, 648 entries, BFS to depth 11. Initialization is instantaneous.

**Solver**: `RouxSolver.cmll()` with CMLL moveset {U,U',U2,R,R',R2,F,F',F2} (standard CMLL moves that don't disturb bottom). IDDFS + cmll pruner heuristic.

**Random state**: `RouxCubeUtil.getRandomCmll()` — from solved cube, randomize top 4 corners' permutation and orientation (satisfying orientation constraint), exclude solved state.

**Case identification**: New helper `CmllAlgs.identifyCase(RouxCube cube)` maps a CMLL state to one of the 42 standard algorithms by comparing top corner configuration against known algorithm effects.

## TimerProvider Integration

Add static solver instances (lazy pruner initialization via existing `RouxPruner.init()` pattern):

```dart
static final _fbSolver = RouxSolver.fb();
static final _sbSolver = RouxSolver.sb();
static final _cmllSolver = RouxSolver.cmll();
```

`_generateNewScramble()` changes:

| Mode | Before | After |
|------|--------|-------|
| `fb` | `ScrambleGenerator.generateRoux()` | `_fbSolver.generateScramble(randomState, maxDepth: 15)` |
| `sb` | `ScrambleGenerator.generateRoux()` | `_sbSolver.generateScramble(randomState, maxDepth: 18)` |
| `cmll` | Fixed setup + inverse alg | `_cmllSolver.generateScramble(randomState, maxDepth: 12)` |

For CMLL per-category/per-case training: generate random state constrained to the target case's corner configuration, then scramble from it.

## Performance Expectations

| Stage | Pruner init | Single scramble |
|-------|-------------|-----------------|
| FB    | <1s         | <100ms          |
| SB    | <1s         | <200ms          |
| CMLL  | Instant     | <50ms           |

Initialization on first use or app startup. Loading indicator if needed.

## Testing

Extend existing test files:

- `test/roux_pruner_test.dart` — FB/SB/CMLL pruner: solved distance = 0, random states ≤ max depth, cross-validate with brute-force for small states
- `test/roux_solver_test.dart` — FB/SB/CMLL solver: solve random states, verify solution restores target pieces; scramble inverse verification
- `test/timer_provider_test.dart` — FB/SB/CMLL mode scramble generation produces valid scrambles; CMLL `identifyCase()` returns correct algorithm

No mocking of solvers. Real pruner tables in tests (CMLL trivial, FB/SB acceptable).
