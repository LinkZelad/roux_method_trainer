import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../roux/cube.dart';

/// 从 RouxCube 生成 6 个面 × 9 个 sticker 的颜色索引
List<List<int>> buildFaceColors(RouxCube cube) {
  final faces = List.generate(6, (_) => List.filled(9, 0));

  // Centers
  for (int i = 0; i < 6; i++) {
    faces[i][4] = cube.tp[i];
  }

  // Corner piece native colors (CW order: U/D, Face1, Face2)
  const cornerColors = [
    [0, 5, 2], // 0: UFL (U, L, F)
    [0, 3, 5], // 1: UBL (U, B, L)
    [0, 4, 3], // 2: UBR (U, R, B)
    [0, 2, 4], // 3: UFR (U, F, R)
    [1, 2, 5], // 4: DFL (D, F, L)
    [1, 5, 3], // 5: DBL (D, L, B)
    [1, 3, 4], // 6: DBR (D, B, R)
    [1, 4, 2], // 7: DFR (D, R, F)
  ];

  const cornerSlots = [
    [(0, 6), (5, 2), (2, 0)], // pos 0: UFL
    [(0, 0), (3, 2), (5, 0)], // pos 1: UBL
    [(0, 2), (4, 2), (3, 0)], // pos 2: UBR
    [(0, 8), (2, 2), (4, 0)], // pos 3: UFR
    [(1, 0), (2, 6), (5, 8)], // pos 4: DFL
    [(1, 6), (5, 6), (3, 8)], // pos 5: DBL
    [(1, 8), (3, 6), (4, 8)], // pos 6: DBR
    [(1, 2), (4, 6), (2, 8)], // pos 7: DFR
  ];

  for (int pos = 0; pos < 8; pos++) {
    final piece = cube.cp[pos];
    final co = cube.co[pos];
    final slots = cornerSlots[pos];
    final colors = cornerColors[piece];
    for (int s = 0; s < 3; s++) {
      final colorIdx = colors[(s + co) % 3];
      final (face, p) = slots[s];
      faces[face][p] = colorIdx;
    }
  }

  // Edge piece native colors (Slot 0 is primary facelet)
  const edgeColors = [
    [0, 2], // 0: UF
    [0, 5], // 1: UL
    [0, 3], // 2: UB
    [0, 4], // 3: UR
    [1, 2], // 4: DF
    [1, 5], // 5: DL
    [1, 3], // 6: DB
    [1, 4], // 7: DR
    [2, 5], // 8: FL
    [3, 5], // 9: BL
    [3, 4], // 10: BR
    [2, 4], // 11: FR
  ];

  const edgeSlots = [
    [(0, 7), (2, 1)], // 0: UF
    [(0, 3), (5, 1)], // 1: UL
    [(0, 1), (3, 1)], // 2: UB
    [(0, 5), (4, 1)], // 3: UR
    [(1, 1), (2, 7)], // 4: DF
    [(1, 3), (5, 7)], // 5: DL
    [(1, 7), (3, 7)], // 6: DB
    [(1, 5), (4, 7)], // 7: DR
    [(2, 3), (5, 5)], // 8: FL
    [(3, 5), (5, 3)], // 9: BL
    [(3, 3), (4, 5)], // 10: BR
    [(2, 5), (4, 3)], // 11: FR
  ];

  for (int pos = 0; pos < 12; pos++) {
    final piece = cube.ep[pos];
    final eo = cube.eo[pos];
    final slots = edgeSlots[pos];
    final colors = edgeColors[piece];
    for (int s = 0; s < 2; s++) {
      final colorIdx = colors[(s + eo) % 2];
      final (face, p) = slots[s];
      faces[face][p] = colorIdx;
    }
  }

  return faces;
}

/// 3x3 矩阵顺时针旋转
List<int> _rotateFaceClockwise(List<int> face) {
  return [
    face[6], face[3], face[0],
    face[7], face[4], face[1],
    face[8], face[5], face[2],
  ];
}

/// 3x3 矩阵逆时针旋转
List<int> _rotateFaceCounterClockwise(List<int> face) {
  return [
    face[2], face[5], face[8],
    face[1], face[4], face[7],
    face[0], face[3], face[6],
  ];
}

/// 根据 y 旋转次数变换 face colors
List<List<int>> _applyYRotation(List<List<int>> faces, int yRotation) {
  if (yRotation == 0) return faces;

  final result = List.generate(6, (i) => [...faces[i]]);

  // U and D faces rotate in place (viewed from above, U CW, D CCW)
  for (int r = 0; r < yRotation; r++) {
    result[0] = _rotateFaceClockwise(result[0]); // U
    result[1] = _rotateFaceCounterClockwise(result[1]); // D
  }

  // Side faces cycle when cube rotates around U-D axis.
  // y=0: L, F, R, B
  // y=1: B, L, F, R  (shift right)
  // y=2: R, B, L, F
  // y=3: F, R, B, L
  final sideData = [faces[5], faces[2], faces[4], faces[3]]; // L, F, R, B
  final reordered = [
    sideData, // y=0
    [sideData[3], sideData[0], sideData[1], sideData[2]], // y=1: B, L, F, R
    [sideData[2], sideData[3], sideData[0], sideData[1]], // y=2: R, B, L, F
    [sideData[1], sideData[2], sideData[3], sideData[0]], // y=3: F, R, B, L
  ][yRotation];

  result[5] = reordered[0]; // L position
  result[2] = reordered[1]; // F position
  result[4] = reordered[2]; // R position
  result[3] = reordered[3]; // B position

  return result;
}

class CubeNet extends StatelessWidget {
  final List<List<int>> faceColors;
  final CubeColorScheme colorScheme;
  final List<List<bool>>? highlightMask;
  final int yRotation;
  final int xRotation;
  final int zRotation;
  final double stickerSize;

  const CubeNet({
    super.key,
    required this.faceColors,
    this.colorScheme = CubeColorScheme.standard,
    this.highlightMask,
    this.yRotation = 0,
    this.xRotation = 0,
    this.zRotation = 0,
    this.stickerSize = 24,
  });

  factory CubeNet.fromScramble(
    String scramble, {
    CubeColorScheme colorScheme = CubeColorScheme.standard,
    List<List<bool>>? highlightMask,
    int yRotation = 0,
    int xRotation = 0,
    int zRotation = 0,
    double stickerSize = 24,
  }) {
    final cube = RouxCube.solved().applyAlg(scramble);
    final rotations = <String>[];
    if (xRotation != 0) {
      rotations.add('x${xRotation == 2 ? '2' : xRotation == 3 ? "'" : ''}');
    }
    if (yRotation != 0) {
      rotations.add('y${yRotation == 2 ? '2' : yRotation == 3 ? "'" : ''}');
    }
    if (zRotation != 0) {
      rotations.add('z${zRotation == 2 ? '2' : zRotation == 3 ? "'" : ''}');
    }
    final rotatedCube = rotations.isEmpty
        ? cube
        : cube.applyAlg(rotations.join(' '));
    final colors = buildFaceColors(rotatedCube);
    return CubeNet(
      faceColors: colors,
      colorScheme: colorScheme,
      highlightMask: highlightMask,
      yRotation: 0,
      xRotation: 0,
      zRotation: 0,
      stickerSize: stickerSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Auto-scale: the middle row is the widest part.
        // 4 faces × (3 stickers + padding) + 3 gaps between faces
        // Approximate factor: 12.88 (measured from the layout below)
        final maxStickerSizeW = constraints.maxWidth / 12.88;
        // Also consider height: 3 rows of faces (U + middle + D)
        // Approx height factor: 9.5
        final maxStickerSizeH = constraints.maxHeight / 9.5;
        final maxStickerSize = math.min(maxStickerSizeW, maxStickerSizeH);
        final size = stickerSize > 0
            ? (stickerSize < maxStickerSize ? stickerSize : maxStickerSize)
            : maxStickerSize;

        final gap = size * 0.08;
        final borderWidth = size * 0.06;
        final rotatedFaces = _applyYRotation(faceColors, yRotation % 4);

        final sideOrder = [
          [5, 2, 4, 3], // y=0: L, F, R, B
          [2, 4, 3, 5], // y=1: F, R, B, L
          [4, 3, 5, 2], // y=2: R, B, L, F
          [3, 5, 2, 4], // y=3: B, L, F, R
        ][yRotation % 4];

        Widget buildSticker(int faceIdx, int stickerIdx) {
          final color = colorScheme.getByIndex(rotatedFaces[faceIdx][stickerIdx]);
          final isHighlighted = highlightMask == null ||
              (highlightMask![faceIdx].length > stickerIdx &&
                  highlightMask![faceIdx][stickerIdx]);

          return Container(
            width: size,
            height: size,
            margin: EdgeInsets.all(gap * 0.5),
            decoration: BoxDecoration(
              color: isHighlighted ? color : color.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(gap * 0.5),
              border: Border.all(
                color: isHighlighted ? Colors.black : Colors.black45,
                width: borderWidth,
              ),
            ),
          );
        }

        Widget buildFace(int faceIdx) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(gap),
            ),
            padding: EdgeInsets.all(gap),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int row = 0; row < 3; row++)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int col = 0; col < 3; col++)
                        buildSticker(faceIdx, row * 3 + col),
                    ],
                  ),
              ],
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top row: empty, U, empty, empty
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: size * 3.5),
                buildFace(0), // U
                SizedBox(width: size * 3.5),
              ],
            ),
            SizedBox(height: gap),
            // Middle row: sides in rotated order
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildFace(sideOrder[0]),
                SizedBox(width: gap),
                buildFace(sideOrder[1]),
                SizedBox(width: gap),
                buildFace(sideOrder[2]),
                SizedBox(width: gap),
                buildFace(sideOrder[3]),
              ],
            ),
            SizedBox(height: gap),
            // Bottom row: empty, D, empty, empty
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: size * 3.5),
                buildFace(1), // D
                SizedBox(width: size * 3.5),
              ],
            ),
          ],
        );
      },
    );
  }
}
