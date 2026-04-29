import 'package:flutter_test/flutter_test.dart';
import 'package:roux_trainer/roux/cube.dart';
import 'package:roux_trainer/widgets/cube_net.dart';

void main() {
  test('solved cube has uniform colors on each face', () {
    final cube = RouxCube.solved();
    final faces = buildFaceColors(cube);

    for (int face = 0; face < 6; face++) {
      for (int i = 0; i < 9; i++) {
        expect(
          faces[face][i],
          face,
          reason: 'Face $face sticker $i should be color $face',
        );
      }
    }
  });

  test('R move changes R face and adjacent stickers', () {
    final cube = RouxCube.solved().applyAlg("R");
    final faces = buildFaceColors(cube);

    // R face should remain all red (color 4) because it was solved
    var allRed = true;
    for (int i = 0; i < 9; i++) {
      if (faces[4][i] != 4) allRed = false;
    }
    expect(allRed, isTrue, reason: 'R face should remain all red if started solved');

    // U face right column (positions 2,5,8) should change
    expect(faces[0][2], isNot(0), reason: 'U pos 2 (UBR) should change');
    expect(faces[0][5], isNot(0), reason: 'U pos 5 (UR) should change');
    expect(faces[0][8], isNot(0), reason: 'U pos 8 (UFR) should change');

    // F face right column (positions 2,5,8) should change
    expect(faces[2][2], isNot(2), reason: 'F pos 2 (UFR) should change');
    expect(faces[2][5], isNot(2), reason: 'F pos 5 (FR) should change');
    expect(faces[2][8], isNot(2), reason: 'F pos 8 (DFR) should change');
  });

  test('F move changes F face and adjacent stickers', () {
    final cube = RouxCube.solved().applyAlg("F");
    final faces = buildFaceColors(cube);

    // F face should remain all green (color 2)
    var allGreen = true;
    for (int i = 0; i < 9; i++) {
      if (faces[2][i] != 2) allGreen = false;
    }
    expect(allGreen, isTrue, reason: 'F face should remain all green if started solved');

    // U face bottom row (positions 6,7,8) should change
    expect(faces[0][6], isNot(0), reason: 'U pos 6 (UFL) should change');
    expect(faces[0][7], isNot(0), reason: 'U pos 7 (UF) should change');
    expect(faces[0][8], isNot(0), reason: 'U pos 8 (UFR) should change');
  });

  test('scramble and inverse restore solved colors', () {
    final scramble = "R U R' U'";
    final cube = RouxCube.solved().applyAlg(scramble);

    final inverseCube = cube.applyAlg("U R U' R'");
    final restored = buildFaceColors(inverseCube);

    for (int f = 0; f < 6; f++) {
      for (int s = 0; s < 9; s++) {
        expect(
          restored[f][s],
          f,
          reason: 'Face $f sticker $s should be restored after inverse',
        );
      }
    }
  });

  test('U move rotates U face stickers among themselves', () {
    final cube = RouxCube.solved().applyAlg("U");
    final faces = buildFaceColors(cube);

    // U face center stays white
    expect(faces[0][4], 0);

    // After U move, F top row becomes R top row (all red = 4)
    expect(faces[2][0], 4, reason: 'F pos 0 should be red after U (from R)');
    expect(faces[2][1], 4, reason: 'F pos 1 should be red after U (from R)');
    expect(faces[2][2], 4, reason: 'F pos 2 should be red after U (from R)');
  });

  test('CubeNet widget builds without error', () {
    final cube = RouxCube.solved().applyAlg("R U R'");
    final faces = buildFaceColors(cube);
    final widget = CubeNet(faceColors: faces, stickerSize: 20);
    expect(widget, isA<CubeNet>());
  });
}
