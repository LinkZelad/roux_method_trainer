class AppSettings {
  final bool holdToStart;
  final bool startCue;
  final int inspectionSeconds;
  final int standardScrambleLength;
  final int rouxScrambleLength;
  final int lseScrambleLength;
  final bool darkTheme;
  final double timerFontScale;

  const AppSettings({
    this.holdToStart = true,
    this.startCue = true,
    this.inspectionSeconds = 15,
    this.standardScrambleLength = 25,
    this.rouxScrambleLength = 25,
    this.lseScrambleLength = 12,
    this.darkTheme = true,
    this.timerFontScale = 1.0,
  });

  AppSettings copyWith({
    bool? holdToStart,
    bool? startCue,
    int? inspectionSeconds,
    int? standardScrambleLength,
    int? rouxScrambleLength,
    int? lseScrambleLength,
    bool? darkTheme,
    double? timerFontScale,
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
    );
  }
}
