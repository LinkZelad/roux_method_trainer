class LseCase {
  final String name;
  final String description;
  final String alg;
  final String setup;
  final String? mirror;

  const LseCase({
    required this.name,
    required this.description,
    required this.alg,
    required this.setup,
    this.mirror,
  });
}

/// Edge Orientation cases.
/// Setup scrambles are the inverses of the solving algorithms.
const List<LseCase> eoCases = [
  LseCase(
    name: 'Case 1',
    description: '6 bad edges (all misoriented)',
    alg: "R U' r' U' M' U r U r'",
    setup: "r U' r' U' M U r U' R'",
  ),
  LseCase(
    name: 'Case 2',
    description: '4 bad edges (arrow variant)',
    alg: "M' U2 M' U2 M U' M'",
    setup: "M U M' U2 M U2",
  ),
  LseCase(
    name: 'Case 3',
    description: '4 bad edges',
    alg: "M' U M' U' M U' M'",
    setup: "M U M' U M U'",
  ),
  LseCase(
    name: 'Case 4',
    description: '2 bad edges (opposite)',
    alg: "M' U' M'",
    setup: "M U M",
    mirror: "M U' M'",
  ),
  LseCase(
    name: 'Case 5',
    description: '4 bad edges (double swap)',
    alg: "M' U2 M' U2 M' U' M'",
    setup: "M U M U2 M U2",
  ),
  LseCase(
    name: 'Case 6',
    description: '4 bad edges (cross pattern)',
    alg: "M' U M U' M' U' M'",
    setup: "M U M' U M' U'",
  ),
  LseCase(
    name: 'Case 7',
    description: '4 bad edges (L-shape)',
    alg: "M' U M' U2 M' U' M'",
    setup: "M U M U2 M' U'",
  ),
  LseCase(
    name: 'Case 8',
    description: '4 bad edges (diagonal)',
    alg: "M' U' M' U' M U' M'",
    setup: "M U M U M' U",
    mirror: "M' U' M U' M' U' M'",
  ),
  LseCase(
    name: 'Case 9',
    description: '2 bad edges (adjacent)',
    alg: "M2 U' M' U' M'",
    setup: "M U M U M2",
  ),
];

/// Left/Right edge placement cases.
const List<LseCase> lrCases = [
  LseCase(
    name: 'Both on D layer',
    description: 'Align corners, then M2 to solve',
    alg: 'M2',
    setup: "M' U2 M' U2 M'",
  ),
  LseCase(
    name: 'One on D, one on U (adjacent)',
    description: 'Use M2 to bring U edge to D',
    alg: "M' U2 M",
    setup: "M' U2 M",
  ),
  LseCase(
    name: 'One on D, one on U (opposite)',
    description: 'Swap via front or back',
    alg: "M' U2 M  (front swap)",
    setup: "M U2 M'",
  ),
  LseCase(
    name: 'Both on U (opposite)',
    description: 'M2 to bring one down, then solve',
    alg: "M2 U2 M2",
    setup: "M2 U2 M2",
  ),
  LseCase(
    name: 'Both on U (adjacent)',
    description: 'M2 to bring one to D layer',
    alg: "M2",
    setup: "M' U' M U2 M' U M",
  ),
];

/// 4C (Last Four Centers / M-slice permutation) cases.
const List<LseCase> fourCCases = [
  LseCase(
    name: 'Ua Perm',
    description: '3-cycle clockwise',
    alg: 'M2 U M U2 M\' U M2',
    setup: "M2 U' M U2 M' U' M2",
  ),
  LseCase(
    name: 'Ub Perm',
    description: '3-cycle counter-clockwise',
    alg: "M2 U' M U2 M' U' M2",
    setup: 'M2 U M U2 M\' U M2',
  ),
  LseCase(
    name: 'Z Perm',
    description: 'Double swap (adjacent)',
    alg: "M2 U M2 U M' U2 M2 U2 M'",
    setup: "M U2 M2 U2 M U' M2 U' M2",
  ),
  LseCase(
    name: 'H Perm',
    description: 'Double swap (opposite)',
    alg: "M2 U' M2 U2 M2 U' M2",
    setup: 'M2 U M2 U2 M2 U M2',
  ),
  LseCase(
    name: 'Adjacent Swap',
    description: 'Direct solve both edges',
    alg: 'M2 U2 M2 U2',
    setup: 'M2 U2 M2 U2',
  ),
];
