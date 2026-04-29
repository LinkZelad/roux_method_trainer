import 'package:flutter/material.dart';

class CubeColorScheme {
  final String name;
  final Color u;
  final Color d;
  final Color f;
  final Color b;
  final Color r;
  final Color l;

  const CubeColorScheme({
    required this.name,
    required this.u,
    required this.d,
    required this.f,
    required this.b,
    required this.r,
    required this.l,
  });

  Color getByIndex(int idx) => [u, d, f, b, r, l][idx];

  List<Color> get colors => [u, d, f, b, r, l];

  static const standard = CubeColorScheme(
    name: 'Standard',
    u: Color(0xFFFFFFFF),
    d: Color(0xFFFFFF00),
    f: Color(0xFF00FF00),
    b: Color(0xFF0000FF),
    r: Color(0xFFFF0000),
    l: Color(0xFFFFA500),
  );

  static const whiteBlueBridge = CubeColorScheme(
    name: 'White base, Blue bridge',
    u: Color(0xFFFFFFFF),
    d: Color(0xFFFFFF00),
    f: Color(0xFF00FF00),
    b: Color(0xFFFFA500),
    r: Color(0xFFFF0000),
    l: Color(0xFF0000FF),
  );

  static const whiteRedBridge = CubeColorScheme(
    name: 'White base, Red bridge',
    u: Color(0xFFFFFFFF),
    d: Color(0xFFFFFF00),
    f: Color(0xFF00FF00),
    b: Color(0xFFFFA500),
    r: Color(0xFF0000FF),
    l: Color(0xFFFF0000),
  );

  static const japanese = CubeColorScheme(
    name: 'Japanese (White base)',
    u: Color(0xFFFFFFFF),
    d: Color(0xFF0000FF),
    f: Color(0xFF00FF00),
    b: Color(0xFFFFFF00),
    r: Color(0xFFFF0000),
    l: Color(0xFFFFA500),
  );

  static const all = [standard, whiteBlueBridge, whiteRedBridge, japanese];
}

class AppSettings {
  final bool holdToStart;
  final bool startCue;
  final int inspectionSeconds;
  final int standardScrambleLength;
  final int rouxScrambleLength;
  final int lseScrambleLength;
  final bool darkTheme;
  final double timerFontScale;
  final String colorSchemeName;
  final String locale;

  const AppSettings({
    this.holdToStart = true,
    this.startCue = true,
    this.inspectionSeconds = 15,
    this.standardScrambleLength = 25,
    this.rouxScrambleLength = 25,
    this.lseScrambleLength = 12,
    this.darkTheme = true,
    this.timerFontScale = 1.0,
    this.colorSchemeName = 'Standard',
    this.locale = 'en',
  });

  CubeColorScheme get colorScheme {
    return CubeColorScheme.all.firstWhere(
      (s) => s.name == colorSchemeName,
      orElse: () => CubeColorScheme.standard,
    );
  }

  AppSettings copyWith({
    bool? holdToStart,
    bool? startCue,
    int? inspectionSeconds,
    int? standardScrambleLength,
    int? rouxScrambleLength,
    int? lseScrambleLength,
    bool? darkTheme,
    double? timerFontScale,
    String? colorSchemeName,
    String? locale,
  }) {
    return AppSettings(
      holdToStart: holdToStart ?? this.holdToStart,
      startCue: startCue ?? this.startCue,
      inspectionSeconds: inspectionSeconds ?? this.inspectionSeconds,
      standardScrambleLength:
          standardScrambleLength ?? this.standardScrambleLength,
      rouxScrambleLength: rouxScrambleLength ?? this.rouxScrambleLength,
      lseScrambleLength: lseScrambleLength ?? this.lseScrambleLength,
      darkTheme: darkTheme ?? this.darkTheme,
      timerFontScale: timerFontScale ?? this.timerFontScale,
      colorSchemeName: colorSchemeName ?? this.colorSchemeName,
      locale: locale ?? this.locale,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'holdToStart': holdToStart,
      'startCue': startCue,
      'inspectionSeconds': inspectionSeconds,
      'standardScrambleLength': standardScrambleLength,
      'rouxScrambleLength': rouxScrambleLength,
      'lseScrambleLength': lseScrambleLength,
      'darkTheme': darkTheme,
      'timerFontScale': timerFontScale,
      'colorSchemeName': colorSchemeName,
      'locale': locale,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      holdToStart: json['holdToStart'] as bool? ?? true,
      startCue: json['startCue'] as bool? ?? true,
      inspectionSeconds: json['inspectionSeconds'] as int? ?? 15,
      standardScrambleLength: json['standardScrambleLength'] as int? ?? 25,
      rouxScrambleLength: json['rouxScrambleLength'] as int? ?? 25,
      lseScrambleLength: json['lseScrambleLength'] as int? ?? 12,
      darkTheme: json['darkTheme'] as bool? ?? true,
      timerFontScale: (json['timerFontScale'] as num?)?.toDouble() ?? 1.0,
      colorSchemeName: json['colorSchemeName'] as String? ?? 'Standard',
      locale: json['locale'] as String? ?? 'en',
    );
  }
}
