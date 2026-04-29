import '../roux/cube.dart';

/// A teaching case for Roux steps (FB, SB, CMLL, LSE).
class RouxTeachingCase {
  final String id;
  final String name;
  final String alg; // The solution algorithm
  final String? setup; // The setup scramble (inverse of alg if null)
  final String category; // Step name (e.g., 'FB', 'SB')
  final String subCategory; // Sub-step (e.g., 'Pairs', 'Line')

  const RouxTeachingCase({
    required this.id,
    required this.name,
    required this.alg,
    this.setup,
    required this.category,
    required this.subCategory,
  });

  String get scramble => setup ?? RouxMoveSeq.parse(alg).inverse().toString();
}

/// FB teaching cases
final List<RouxTeachingCase> fbTeachingCases = [
  RouxTeachingCase(
    id: 'fb_line_u',
    name: 'DL Edge in U',
    alg: "U2 M' U2 L'",
    setup: "L U2 M U2",
    category: 'FB',
    subCategory: 'Line',
  ),
  RouxTeachingCase(
    id: 'fb_line_flipped',
    name: 'DL Edge Flipped',
    alg: "F' U' L",
    setup: "L' U F",
    category: 'FB',
    subCategory: 'Line',
  ),
  RouxTeachingCase(
    id: 'fb_pair1_basic',
    name: 'Basic Front Pair',
    alg: "U R U' L'",
    setup: "L U R' U'",
    category: 'FB',
    subCategory: 'Pairs',
  ),
  RouxTeachingCase(
    id: 'fb_pair1_split',
    name: 'Front Pair Split',
    alg: "R U R' U2 L'",
    setup: "L U2 R U' R'",
    category: 'FB',
    subCategory: 'Pairs',
  ),
  RouxTeachingCase(
    id: 'fb_pair2_basic',
    name: 'Basic Back Pair',
    alg: "U' R' U L",
    setup: "L' U' R U",
    category: 'FB',
    subCategory: 'Pairs',
  ),
];

/// SB teaching cases
final List<RouxTeachingCase> sbTeachingCases = [
  RouxTeachingCase(
    id: 'sb_dr_edge',
    name: 'DR Edge Setup',
    alg: "U M' U2 R",
    category: 'SB',
    subCategory: 'DR',
  ),
  RouxTeachingCase(
    id: 'sb_dr_flipped',
    name: 'DR Edge Flipped',
    alg: "U R U' R' U R U' R'",
    category: 'SB',
    subCategory: 'DR',
  ),
  RouxTeachingCase(
    id: 'sb_pair1_basic',
    name: 'Basic Front Pair',
    alg: "U R U' R'",
    category: 'SB',
    subCategory: 'Pairs',
  ),
  RouxTeachingCase(
    id: 'sb_pair1_split',
    name: 'Front Pair Split',
    alg: "U' R U2 R' U R U' R'",
    category: 'SB',
    subCategory: 'Pairs',
  ),
  RouxTeachingCase(
    id: 'sb_pair2_basic',
    name: 'Basic Back Pair',
    alg: "U' R' U R",
    category: 'SB',
    subCategory: 'Pairs',
  ),
  RouxTeachingCase(
    id: 'sb_pair2_trapped',
    name: 'Back Pair Trapped',
    alg: "R' U R U' R' U R",
    category: 'SB',
    subCategory: 'Pairs',
  ),
];

/// Get all teaching cases for a step
List<RouxTeachingCase> getTeachingCasesByStep(String step) {
  if (step == 'FB') return fbTeachingCases;
  if (step == 'SB') return sbTeachingCases;
  return [];
}

/// Get all sub-categories for a step
List<String> getSubCategoriesByStep(String step) {
  final cases = getTeachingCasesByStep(step);
  return cases.map((c) => c.subCategory).toSet().toList();
}
