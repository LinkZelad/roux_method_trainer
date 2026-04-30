// Cube net highlight masks for Roux stages.

import '../models/solve_record.dart';
// Face order: U=0, D=1, F=2, B=3, R=4, L=5
// Sticker indices per face (3x3):
//   0 1 2
//   3 4 5
//   6 7 8

/// Highlight mask for First Block stage.
/// Highlights the left-bottom 1x2x3 block stickers.
List<List<bool>> fbHighlightMask() {
  return [
    // U: no FB stickers
    [false, false, false, false, false, false, false, false, false],
    // D: left column (DFL, DL, DBL)
    [true, false, false, true, false, false, true, false, false],
    // F: bottom-left (DFL)
    [false, false, false, false, false, false, true, false, false],
    // B: bottom-right (DBL)
    [false, false, false, false, false, false, false, false, true],
    // R: no FB stickers
    [false, false, false, false, false, false, false, false, false],
    // L: left column + middle column (FL, L center, BL, DFL, DL, DBL)
    [true, true, true, true, true, true, true, true, true],
  ];
}

/// Highlight mask for Second Block stage.
/// Highlights the right-bottom 1x2x3 block stickers.
List<List<bool>> sbHighlightMask() {
  return [
    // U: no SB stickers
    [false, false, false, false, false, false, false, false, false],
    // D: right column (DFR, DR, DBR)
    [false, false, true, false, false, true, false, false, true],
    // F: bottom-right (DFR)
    [false, false, false, false, false, false, false, false, true],
    // B: bottom-left (DBR)
    [false, false, false, false, false, false, true, false, false],
    // R: entire R face
    [true, true, true, true, true, true, true, true, true],
    // L: no SB stickers
    [false, false, false, false, false, false, false, false, false],
  ];
}

/// Highlight mask for LSE stage.
/// Highlights the M-slice edges and centers (UF, UL, UB, UR, DF, DB + U,D,F,B centers).
List<List<bool>> lseHighlightMask() {
  return [
    // U: M-slice (UB, UL, center, UR, UF)
    [false, true, false, true, true, true, false, true, false],
    // D: M-slice (DF, center, DB)
    [false, true, false, false, true, false, false, true, false],
    // F: M-slice (UF, center, DF)
    [false, true, false, false, true, false, false, true, false],
    // B: M-slice (UB, center, DB)
    [false, true, false, false, true, false, false, true, false],
    // R: no LSE stickers
    [false, false, false, false, false, false, false, false, false],
    // L: no LSE stickers
    [false, false, false, false, false, false, false, false, false],
  ];
}

/// Highlight mask for CMLL stage.
/// Highlights the U-layer stickers and side corners.
List<List<bool>> cmllHighlightMask() {
  return [
    // U: all U layer stickers
    [true, true, true, true, true, true, true, true, true],
    // D: no CMLL stickers
    [false, false, false, false, false, false, false, false, false],
    // F: top corners
    [true, false, true, false, false, false, false, false, false],
    // B: top corners
    [true, false, true, false, false, false, false, false, false],
    // R: top corners
    [true, false, true, false, false, false, false, false, false],
    // L: top corners
    [true, false, true, false, false, false, false, false, false],
  ];
}

/// Highlight mask for EOLR stage.
/// Same as LSE but with focus on edge orientation.
List<List<bool>> eolrHighlightMask() => lseHighlightMask();

/// Highlight mask for 4C stage.
/// Same as LSE.
List<List<bool>> lse4cHighlightMask() => lseHighlightMask();

/// Highlight mask for FB+DR stage.
/// Highlights FB block + DR edge.
List<List<bool>> fbdrHighlightMask() => fbHighlightMask();

/// Highlight mask for FS stage.
/// Highlights the 2x2x1 square (DFL, DL, FL, L center).
List<List<bool>> fsHighlightMask() {
  return [
    // U: no FS stickers
    [false, false, false, false, false, false, false, false, false],
    // D: bottom-left (DFL)
    [true, false, false, false, false, false, false, false, false],
    // F: bottom-left (DFL)
    [false, false, false, false, false, false, true, false, false],
    // B: no FS stickers
    [false, false, false, false, false, false, false, false, false],
    // R: no FS stickers
    [false, false, false, false, false, false, false, false, false],
    // L: left column + center (FL, L center, DFL)
    [true, true, true, true, true, true, true, true, true],
  ];
}

/// Returns the appropriate highlight mask for a training mode.
List<List<bool>>? highlightMaskForMode(TrainingMode mode) {
  return switch (mode) {
    TrainingMode.fb => fbHighlightMask(),
    TrainingMode.sb => sbHighlightMask(),
    TrainingMode.cmll => cmllHighlightMask(),
    TrainingMode.lseEOLR => eolrHighlightMask(),
    TrainingMode.lse4C => lse4cHighlightMask(),
    TrainingMode.fbdr => fbdrHighlightMask(),
    TrainingMode.fs => fsHighlightMask(),
    _ => null,
  };
}
