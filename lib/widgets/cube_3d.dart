import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3, Matrix4;
import '../models/app_settings.dart';
import '../roux/cube.dart';
import 'cube_net.dart';

/// An interactive 3D cube viewer with smooth animations and corrected mapping.
class Cube3D extends StatefulWidget {
  final List<List<int>> faceColors;
  final CubeColorScheme colorScheme;
  final double size;
  final String? animatingMove;
  final double animationProgress;

  const Cube3D({
    super.key,
    required this.faceColors,
    this.colorScheme = CubeColorScheme.standard,
    this.size = 200,
    this.animatingMove,
    this.animationProgress = 0,
  });

  factory Cube3D.fromCube(
    RouxCube cube, {
    CubeColorScheme colorScheme = CubeColorScheme.standard,
    double size = 200,
    String? animatingMove,
    double animationProgress = 0,
  }) {
    final colors = buildFaceColors(cube);
    return Cube3D(
      faceColors: colors,
      colorScheme: colorScheme,
      size: size,
      animatingMove: animatingMove,
      animationProgress: animationProgress,
    );
  }

  @override
  State<Cube3D> createState() => _Cube3DState();
}

class _Cube3DState extends State<Cube3D> {
  double _yaw = math.pi / 4;
  double _pitch = 0.61548;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _yaw += details.delta.dx * 0.01;
          _pitch += details.delta.dy * 0.01;
          _pitch = _pitch.clamp(-math.pi / 2 + 0.1, math.pi / 2 - 0.1);
        });
      },
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _Cube3DPainter(
          faceColors: widget.faceColors,
          colorScheme: widget.colorScheme,
          yaw: _yaw,
          pitch: _pitch,
          animatingMove: widget.animatingMove,
          animationProgress: widget.animationProgress,
        ),
      ),
    );
  }
}

class _Cube3DPainter extends CustomPainter {
  final List<List<int>> faceColors;
  final CubeColorScheme colorScheme;
  final double yaw;
  final double pitch;
  final String? animatingMove;
  final double animationProgress;

  _Cube3DPainter({
    required this.faceColors,
    required this.colorScheme,
    required this.yaw,
    required this.pitch,
    this.animatingMove,
    this.animationProgress = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 5.0;
    final center = Offset(size.width / 2, size.height / 2);
    
    final viewMatrix = Matrix4.identity()
      ..rotateX(pitch)
      ..rotateY(yaw);

    final List<_StickerData> stickers = [];

    for (int faceIdx = 0; faceIdx < 6; faceIdx++) {
      for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 3; col++) {
          stickers.add(_buildSticker(faceIdx, row, col, viewMatrix, scale, center));
        }
      }
    }

    // Sort by depth (painter's algorithm)
    stickers.sort((a, b) => a.avgZ.compareTo(b.avgZ));

    final paint = Paint()..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 1.5;

    for (final s in stickers) {
      if (s.visibility <= 0) continue;

      // Simple shading based on normal
      final baseColor = colorScheme.getByIndex(s.colorIdx);
      final shade = (s.visibility * 0.3 + 0.7).clamp(0.0, 1.0);
      
      // Handle both double (0-1) and int (0-255) color formats across Flutter versions
      int toByte(double value) => (value.clamp(0.0, 1.0) * 255).toInt();
      double r = baseColor.r > 1.0 ? baseColor.r / 255.0 : baseColor.r;
      double g = baseColor.g > 1.0 ? baseColor.g / 255.0 : baseColor.g;
      double b = baseColor.b > 1.0 ? baseColor.b / 255.0 : baseColor.b;

      paint.color = Color.fromARGB(
        255,
        toByte(r * shade),
        toByte(g * shade),
        toByte(b * shade),
      );

      final path = Path()
        ..moveTo(s.points[0].dx, s.points[0].dy);
      for (int i = 1; i < s.points.length; i++) {
        path.lineTo(s.points[i].dx, s.points[i].dy);
      }
      path.close();

      canvas.drawPath(path, paint);
      canvas.drawPath(path, borderPaint);
    }
  }

  _StickerData _buildSticker(
    int faceIdx,
    int row,
    int col,
    Matrix4 viewMatrix,
    double scale,
    Offset center,
  ) {
    final rawPoints = _getRawStickerPoints(faceIdx, row, col);
    final animating = _isStickerInLayer(faceIdx, row, col);
    
    final List<Vector3> transformed = [];
    final animMatrix = animating ? _getAnimMatrix() : Matrix4.identity();

    for (final p in rawPoints) {
      // 1. Shift to cube center (1.5, 1.5, 1.5)
      final v = Vector3(p.x - 1.5, p.y - 1.5, p.z - 1.5);
      
      // 2. Apply Move Animation
      animMatrix.transform3(v);
      
      // 3. Apply View Rotation
      viewMatrix.transform3(v);
      
      transformed.add(v);
    }

    // Visibility and shading based on normal
    final normal = _getFaceNormal(faceIdx);
    viewMatrix.transform3(normal); // Only rotate normal by view
    if (animating) animMatrix.transform3(normal);

    // Points for drawing
    final points = transformed.map((v) => Offset(v.x * scale + center.dx, -v.y * scale + center.dy)).toList();
    final avgZ = transformed.fold(0.0, (sum, v) => sum + v.z) / transformed.length;

    return _StickerData(
      points: points,
      colorIdx: faceColors[faceIdx][row * 3 + col],
      avgZ: avgZ,
      visibility: normal.z, // Use rotated Z normal for visibility
    );
  }

  Matrix4 _getAnimMatrix() {
    if (animatingMove == null) return Matrix4.identity();
    final move = animatingMove![0];
    final suffix = animatingMove!.length > 1 ? animatingMove!.substring(1) : '';
    
    double angle = (math.pi / 2) * animationProgress;
    if (suffix == "'") angle = -angle;
    if (suffix == '2') angle = math.pi * animationProgress;

    final m = Matrix4.identity();
    switch (move) {
      case 'U': m.rotateY(-angle); break;
      case 'D': m.rotateY(angle); break;
      case 'L': m.rotateX(angle); break;
      case 'R': m.rotateX(-angle); break;
      case 'F': m.rotateZ(-angle); break;
      case 'B': m.rotateZ(angle); break;
      case 'M': m.rotateX(angle); break;
      case 'E': m.rotateY(angle); break;
      case 'S': m.rotateZ(-angle); break;
      case 'x': m.rotateX(-angle); break;
      case 'y': m.rotateY(-angle); break;
      case 'z': m.rotateZ(-angle); break;
      // Wide moves
      case 'r': m.rotateX(-angle); break;
      case 'l': m.rotateX(angle); break;
      case 'u': m.rotateY(-angle); break;
      case 'd': m.rotateY(angle); break;
      case 'f': m.rotateZ(-angle); break;
      case 'b': m.rotateZ(angle); break;
    }
    return m;
  }

  bool _isStickerInLayer(int faceIdx, int row, int col) {
    if (animatingMove == null) return false;
    final move = animatingMove![0];
    
    switch (move) {
      case 'U': return faceIdx == 0 || (faceIdx >= 2 && row == 0);
      case 'D': return faceIdx == 1 || (faceIdx >= 2 && row == 2);
      case 'F': return faceIdx == 2 || (faceIdx == 0 && row == 2) || (faceIdx == 1 && row == 0) || (faceIdx == 4 && col == 0) || (faceIdx == 5 && col == 2);
      case 'B': return faceIdx == 3 || (faceIdx == 0 && row == 0) || (faceIdx == 1 && row == 2) || (faceIdx == 4 && col == 2) || (faceIdx == 5 && col == 0);
      case 'R': return faceIdx == 4 || (faceIdx == 0 && col == 2) || (faceIdx == 1 && col == 2) || (faceIdx == 2 && col == 2) || (faceIdx == 3 && col == 0);
      case 'L': return faceIdx == 5 || (faceIdx == 0 && col == 0) || (faceIdx == 1 && col == 0) || (faceIdx == 2 && col == 0) || (faceIdx == 3 && col == 2);
      case 'M': return (faceIdx <= 3 && col == 1) || (faceIdx == 0 && col == 1) || (faceIdx == 1 && col == 1);
      case 'x': case 'y': case 'z': return true;
      case 'r': return faceIdx == 4 || _isStickerInLayer(4, row, col) || (faceIdx <= 3 && col == 1);
      case 'l': return faceIdx == 5 || _isStickerInLayer(5, row, col) || (faceIdx <= 3 && col == 1);
      case 'u': return faceIdx == 0 || (faceIdx >= 2 && row <= 1);
      case 'd': return faceIdx == 1 || (faceIdx >= 2 && row >= 1);
      case 'f': return faceIdx == 2 || (faceIdx == 0 && row >= 1) || (faceIdx == 1 && row <= 1);
      case 'b': return faceIdx == 3 || (faceIdx == 0 && row <= 1) || (faceIdx == 1 && row >= 1);
    }
    return false; 
  }

  List<Vector3> _getRawStickerPoints(int faceIdx, int row, int col) {
    final x = col.toDouble();
    final y = (2 - row).toDouble();
    switch (faceIdx) {
      case 0: // U: y=3, x=col, z=row
        return [Vector3(x, 3, row.toDouble()), Vector3(x + 1, 3, row.toDouble()), Vector3(x + 1, 3, row.toDouble() + 1), Vector3(x, 3, row.toDouble() + 1)];
      case 1: // D: y=0, x=col, z=2-row
        final z = (2 - row).toDouble();
        return [Vector3(x, 0, z), Vector3(x + 1, 0, z), Vector3(x + 1, 0, z + 1), Vector3(x, 0, z + 1)];
      case 2: return [Vector3(x, y, 3), Vector3(x + 1, y, 3), Vector3(x + 1, y + 1, 3), Vector3(x, y + 1, 3)]; // F
      case 3: return [Vector3(2 - x, y, 0), Vector3(3 - x, y, 0), Vector3(3 - x, y + 1, 0), Vector3(2 - x, y + 1, 0)]; // B
      case 4: return [Vector3(3, y, 2 - col.toDouble()), Vector3(3, y, 3 - col.toDouble()), Vector3(3, y + 1, 3 - col.toDouble()), Vector3(3, y + 1, 2 - col.toDouble())]; // R
      case 5: return [Vector3(0, y, col.toDouble()), Vector3(0, y, col.toDouble() + 1), Vector3(0, y + 1, col.toDouble() + 1), Vector3(0, y + 1, col.toDouble())]; // L
    }
    return [];
  }

  Vector3 _getFaceNormal(int faceIdx) {
    switch (faceIdx) {
      case 0: return Vector3(0, 1, 0);
      case 1: return Vector3(0, -1, 0);
      case 2: return Vector3(0, 0, 1);
      case 3: return Vector3(0, 0, -1);
      case 4: return Vector3(1, 0, 0);
      case 5: return Vector3(-1, 0, 0);
    }
    return Vector3.zero();
  }

  @override
  bool shouldRepaint(covariant _Cube3DPainter oldDelegate) {
    return oldDelegate.faceColors != faceColors ||
        oldDelegate.yaw != yaw ||
        oldDelegate.pitch != pitch ||
        oldDelegate.animationProgress != animationProgress;
  }
}

class _StickerData {
  final List<Offset> points;
  final int colorIdx;
  final double avgZ;
  final double visibility;

  _StickerData({
    required this.points,
    required this.colorIdx,
    required this.avgZ,
    required this.visibility,
  });
}
