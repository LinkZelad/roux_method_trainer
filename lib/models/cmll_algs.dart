// CMLL算法集
// 移植自 roux-trainers/src/lib/Algs.tsx

class CmllCase {
  final String id;
  final String name;
  final String alg;
  final String? setup;
  final String category;

  const CmllCase({
    required this.id,
    required this.name,
    required this.alg,
    this.setup,
    required this.category,
  });
}

// CMLL算法库
final List<CmllCase> cmllAlgs = [
  // O cases
  CmllCase(
    id: 'o_adjacent_swap',
    name: 'Adjacent Swap',
    alg: "R U R' F' R U R' U' R' F R2 U' R'",
    category: 'O',
  ),
  CmllCase(
    id: 'o_diagonal_swap',
    name: 'Diagonal Swap',
    alg: "F R U' R' U' R U R' F' R U R' U' R' F R F'",
    category: 'O',
  ),

  // H cases
  CmllCase(
    id: 'h_columns',
    name: 'Columns',
    alg: "U' R U R' U R U' R' U R U2 R'",
    category: 'H',
  ),
  CmllCase(
    id: 'h_rows',
    name: 'Rows',
    alg: "F R U R' U' R U R' U' R U R' U' F'",
    category: 'H',
  ),
  CmllCase(
    id: 'h_column',
    name: 'Column',
    alg: "U' R U2' R2' F R F' U2 R' F R F'",
    category: 'H',
  ),
  CmllCase(
    id: 'h_row',
    name: 'Row',
    alg: "r U' r2' D' r U' r' D r2 U r'",
    category: 'H',
  ),

  // Pi cases
  CmllCase(
    id: 'pi_right_bar',
    name: 'Right Bar',
    alg: "F R U R' U' R U R' U' F'",
    category: 'Pi',
  ),
  CmllCase(
    id: 'pi_back_slash',
    name: 'Back Slash',
    alg: "U F R' F' R U2 R U' R' U R U2' R'",
    category: 'Pi',
  ),
  CmllCase(
    id: 'pi_x_checkerboard',
    name: 'X Checkerboard',
    alg: "U' R' F R U F U' R U R' U' F'",
    category: 'Pi',
  ),
  CmllCase(
    id: 'pi_forward_slash',
    name: 'Forward Slash',
    alg: "R U2 R' U' R U R' U2' R' F R F'",
    category: 'Pi',
  ),
  CmllCase(
    id: 'pi_columns',
    name: 'Columns',
    alg: "U' r U' r2' D' r U r' D r2 U r'",
    category: 'Pi',
  ),
  CmllCase(
    id: 'pi_left_bar',
    name: 'Left Bar',
    alg: "U' R' U' R' F R F' R U' R' U2 R",
    category: 'Pi',
  ),

  // U cases
  CmllCase(
    id: 'u_forward_slash',
    name: 'Forward Slash',
    alg: "U2 R2 D R' U2 R D' R' U2 R'",
    category: 'U',
  ),
  CmllCase(
    id: 'u_back_slash',
    name: 'Back Slash',
    alg: "R2' D' R U2 R' D R U2 R",
    category: 'U',
  ),
  CmllCase(
    id: 'u_front_row',
    name: 'Front Row',
    alg: "R' U' R U' R' U2 R2 U R' U R U2 R'",
    category: 'U',
  ),
  CmllCase(
    id: 'u_rows',
    name: 'Rows',
    alg: "U' F R2 D R' U R D' R2' U' F'",
    category: 'U',
  ),
  CmllCase(
    id: 'u_x_checkerboard',
    name: 'X Checkerboard',
    alg: "U2 r U' r' U r' D' r U' r' D r",
    category: 'U',
  ),
  CmllCase(
    id: 'u_back_row',
    name: 'Back Row',
    alg: "U' F R U R' U' F'",
    category: 'U',
  ),

  // T cases
  CmllCase(
    id: 't_left_bar',
    name: 'Left Bar',
    alg: "U' R U R' U' R' F R F'",
    category: 'T',
  ),
  CmllCase(
    id: 't_right_bar',
    name: 'Right Bar',
    alg: "U L' U' L U L F' L' F",
    category: 'T',
  ),
  CmllCase(
    id: 't_rows',
    name: 'Rows',
    alg: "R U2 R' U' R U' R2' U2' R U R' U R",
    category: 'T',
  ),
  CmllCase(
    id: 't_front_row',
    name: 'Front Row',
    alg: "r' U r U2' R2' F R F' R",
    category: 'T',
  ),
  CmllCase(
    id: 't_back_row',
    name: 'Back Row',
    alg: "r' D' r U r' D r U' r U r'",
    category: 'T',
  ),
  CmllCase(
    id: 't_columns',
    name: 'Columns',
    alg: "U2 r2' D' r U r' D r2 U' r' U' r",
    category: 'T',
  ),

  // S cases
  CmllCase(
    id: 's_left_bar',
    name: 'Left Bar',
    alg: "R U R' U R U2 R'",
    category: 'S',
  ),
  CmllCase(
    id: 's_x_checkerboard',
    name: 'X Checkerboard',
    alg: "L' U2 L U2' L F' L' F",
    category: 'S',
  ),
  CmllCase(
    id: 's_forward_slash',
    name: 'Forward Slash',
    alg: "F R' F' R U2 R U2' R'",
    category: 'S',
  ),
  CmllCase(
    id: 's_columns',
    name: 'Columns',
    alg: "R U R' U' R' F R F' R U R' U R U2' R'",
    category: 'S',
  ),
  CmllCase(
    id: 's_right_bar',
    name: 'Right Bar',
    alg: "U2' R U R' U R' F R F' R U2' R'",
    category: 'S',
  ),
  CmllCase(
    id: 's_back_slash',
    name: 'Back Slash',
    alg: "R U' L' U R' U' L",
    category: 'S',
  ),

  // AS cases
  CmllCase(
    id: 'as_right_bar',
    name: 'Right Bar',
    alg: "U' R U2' R' U' R U' R'",
    category: 'AS',
  ),
  CmllCase(
    id: 'as_columns',
    name: 'Columns',
    alg: "R2 D R' U R D' R' U R' U' R U' R'",
    category: 'AS',
  ),
  CmllCase(
    id: 'as_back_slash',
    name: 'Back Slash',
    alg: "F' r U r' U2' r' F2 r",
    category: 'AS',
  ),
  CmllCase(
    id: 'as_x_checkerboard',
    name: 'X Checkerboard',
    alg: "R U2' R' U2' R' F R F'",
    category: 'AS',
  ),
  CmllCase(
    id: 'as_forward_slash',
    name: 'Forward Slash',
    alg: "L' U R U' L U R'",
    category: 'AS',
  ),
  CmllCase(
    id: 'as_left_bar',
    name: 'Left Bar',
    alg: "U2' R U2' R' F R' F' R U' R U' R'",
    category: 'AS',
  ),

  // L cases
  CmllCase(
    id: 'l_mirror',
    name: 'Mirror',
    alg: "F R U' R' U' R U R' F'",
    category: 'L',
  ),
  CmllCase(
    id: 'l_inverse',
    name: 'Inverse',
    alg: "F R' F' R U R U' R'",
    category: 'L',
  ),
  CmllCase(
    id: 'l_pure',
    name: 'Pure',
    alg: "U2 R U R' U R U' R' U R U' R' U R U2' R'",
    category: 'L',
  ),
  CmllCase(
    id: 'l_front_commutator',
    name: 'Front Commutator',
    alg: "R U2 R D R' U2 R D' R2'",
    category: 'L',
  ),
  CmllCase(
    id: 'l_diag',
    name: 'Diagonal',
    alg: "U2 R' U' R U R' F' R U R' U' R' F R2",
    category: 'L',
  ),
  CmllCase(
    id: 'l_back_commutator',
    name: 'Back Commutator',
    alg: "U' R' U2 R' D' R U2 R' D R2",
    category: 'L',
  ),
];

// 获取所有分类
List<String> getCmllCategories() {
  return ['O', 'H', 'Pi', 'U', 'T', 'S', 'AS', 'L'];
}

// 按分类获取case
List<CmllCase> getCmllByCategory(String category) {
  return cmllAlgs.where((c) => c.category == category).toList();
}

// 随机获取一个CMLL case
CmllCase getRandomCmllCase({List<String>? categories}) {
  final filtered = categories != null
      ? cmllAlgs.where((c) => categories.contains(c.category)).toList()
      : cmllAlgs.toList();
  if (filtered.isEmpty) {
    return cmllAlgs.first;
  }
  filtered.shuffle();
  return filtered.first;
}
