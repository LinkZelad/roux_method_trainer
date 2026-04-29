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
  // Line (DL Edge)
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
    id: 'fb_line_back',
    name: 'DL Edge in Back',
    alg: "B L'",
    setup: "L B'",
    category: 'FB',
    subCategory: 'Line',
  ),
  
  // Pairs
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
    id: 'fb_pair1_misaligned',
    name: 'Front Pair Misaligned',
    alg: "U F' L F",
    setup: "F' L' F U'",
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
  RouxTeachingCase(
    id: 'fb_pair2_bottom',
    name: 'Back Pair on Bottom',
    alg: "D L' D' L",
    setup: "L' D L D'",
    category: 'FB',
    subCategory: 'Pairs',
  ),

  // Advanced/Common FB
  RouxTeachingCase(
    id: 'fb_square_basic',
    name: 'Basic Square (1x2x2)',
    alg: "U2 r U' r'",
    category: 'FB',
    subCategory: 'Advanced',
  ),
];

/// SB teaching cases
final List<RouxTeachingCase> sbTeachingCases = [
  // DR Edge
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
    id: 'sb_dr_misplaced',
    name: 'DR Edge Misplaced',
    alg: "M2 U R",
    category: 'SB',
    subCategory: 'DR',
  ),

  // Pairs
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
    id: 'sb_pair1_flipped',
    name: 'Front Pair Flipped',
    alg: "R U R' U' F' U F",
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
  RouxTeachingCase(
    id: 'sb_pair2_edge_in_slot',
    name: 'Edge in Slot (Pair 2)',
    alg: "U' R' U' R U R' U' R",
    category: 'SB',
    subCategory: 'Pairs',
  ),

  // Advanced/Common SB
  RouxTeachingCase(
    id: 'sb_m_slice_pair',
    name: 'M-Slice Pairing',
    alg: "M' U R U' R' M",
    category: 'SB',
    subCategory: 'Advanced',
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
