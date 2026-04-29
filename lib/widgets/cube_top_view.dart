import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../roux/cube.dart';
import 'cube_net.dart';

/// A top-down 2D view of the cube showing the U face and the adjacent
/// stickers from F, R, B, L faces. Useful for CMLL recognition.
class CubeTopView extends StatelessWidget {
  final List<List<int>> faceColors;
  final CubeColorScheme colorScheme;
  final double stickerSize;
  final List<List<bool>>? highlightMask;

  const CubeTopView({
    super.key,
    required this.faceColors,
    this.colorScheme = CubeColorScheme.standard,
    this.stickerSize = 24,
    this.highlightMask,
  });

  factory CubeTopView.fromScramble(
    String scramble, {
    CubeColorScheme colorScheme = CubeColorScheme.standard,
    double stickerSize = 24,
    List<List<bool>>? highlightMask,
  }) {
    final cube = RouxCube.solved().applyAlg(scramble);
    final colors = buildFaceColors(cube);
    return CubeTopView(
      faceColors: colors,
      colorScheme: colorScheme,
      stickerSize: stickerSize,
      highlightMask: highlightMask,
    );
  }

  factory CubeTopView.fromCube(
    RouxCube cube, {
    CubeColorScheme colorScheme = CubeColorScheme.standard,
    double stickerSize = 24,
    List<List<bool>>? highlightMask,
  }) {
    final colors = buildFaceColors(cube);
    return CubeTopView(
      faceColors: colors,
      colorScheme: colorScheme,
      stickerSize: stickerSize,
      highlightMask: highlightMask,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxByWidth = constraints.maxWidth / 5.5;
        final maxByHeight = constraints.maxHeight / 5.5;
        final size = stickerSize > 0
            ? math.min(stickerSize, math.min(maxByWidth, maxByHeight))
            : math.min(maxByWidth, maxByHeight);

        final gap = size * 0.08;
        final borderWidth = size * 0.06;

        Color getColor(int faceIdx, int stickerIdx) {
          final baseColor = colorScheme.getByIndex(faceColors[faceIdx][stickerIdx]);
          final isHighlighted = highlightMask == null ||
              (highlightMask!.length > faceIdx &&
                  highlightMask![faceIdx].length > stickerIdx &&
                  highlightMask![faceIdx][stickerIdx]);
          return isHighlighted ? baseColor : baseColor.withValues(alpha: 0.25);
        }

        BorderSide getBorder(int faceIdx, int stickerIdx) {
          final isHighlighted = highlightMask == null ||
              (highlightMask!.length > faceIdx &&
                  highlightMask![faceIdx].length > stickerIdx &&
                  highlightMask![faceIdx][stickerIdx]);
          return BorderSide(
            color: isHighlighted ? Colors.black : Colors.black38,
            width: borderWidth,
          );
        }

        Widget buildSticker(int faceIdx, int stickerIdx) {
          return Container(
            width: size,
            height: size,
            margin: EdgeInsets.all(gap * 0.5),
            decoration: BoxDecoration(
              color: getColor(faceIdx, stickerIdx),
              borderRadius: BorderRadius.circular(gap * 0.5),
              border: Border.all(
                color: getBorder(faceIdx, stickerIdx).color,
                width: getBorder(faceIdx, stickerIdx).width,
              ),
            ),
          );
        }

        // U face 3x3
        Widget buildUFace() {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int row = 0; row < 3; row++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int col = 0; col < 3; col++)
                      buildSticker(0, row * 3 + col),
                  ],
                ),
            ],
          );
        }

        // B face exposed row (top of U) - reversed left-to-right when viewed from above
        Widget buildBRow() {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // B face row 0 reversed: UBR(2), UB(1), UBL(0)
              buildSticker(3, 2),
              buildSticker(3, 1),
              buildSticker(3, 0),
            ],
          );
        }

        // F face exposed row (bottom of U)
        Widget buildFRow() {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // F face row 0: UFL(0), UF(1), UFR(2)
              buildSticker(2, 0),
              buildSticker(2, 1),
              buildSticker(2, 2),
            ],
          );
        }

        // L face exposed column (left of U) - top to bottom
        Widget buildLCol() {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // L face row 0: UBL(0), UL(1), UFL(2)
              buildSticker(5, 0),
              buildSticker(5, 1),
              buildSticker(5, 2),
            ],
          );
        }

        // R face exposed column (right of U) - reversed top-to-bottom when viewed from above
        Widget buildRCol() {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // R face row 0 reversed: UBR(2), UR(1), UFR(0)
              buildSticker(4, 2),
              buildSticker(4, 1),
              buildSticker(4, 0),
            ],
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // B row
            buildBRow(),
            // Middle: L col + U face + R col
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildLCol(),
                SizedBox(width: gap),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(gap),
                  ),
                  padding: EdgeInsets.all(gap),
                  child: buildUFace(),
                ),
                SizedBox(width: gap),
                buildRCol(),
              ],
            ),
            // F row
            buildFRow(),
          ],
        );
      },
    );
  }
}
