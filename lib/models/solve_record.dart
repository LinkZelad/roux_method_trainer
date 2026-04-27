// 成绩记录模型

import 'dart:convert';

enum Penalty { none, plus2, dnf }

enum TrainingMode { standard, cmll, fb, sb, lseEOLR, lse4C }

class SolveRecord {
  final String id;
  final DateTime timestamp;
  final Duration time;
  final Penalty penalty;
  final String scramble;
  final TrainingMode mode;
  final String? caseId; // 训练特定case时的ID
  final String? comment;

  SolveRecord({
    required this.id,
    required this.timestamp,
    required this.time,
    this.penalty = Penalty.none,
    required this.scramble,
    this.mode = TrainingMode.standard,
    this.caseId,
    this.comment,
  });

  /// 获取有效时间（考虑+2惩罚）
  Duration get effectiveTime {
    if (penalty == Penalty.dnf) return Duration.zero;
    if (penalty == Penalty.plus2) {
      return time + const Duration(seconds: 2);
    }
    return time;
  }

  /// 时间显示字符串
  String get timeString {
    if (penalty == Penalty.dnf) return 'DNF';
    final ms = effectiveTime.inMilliseconds;
    final seconds = ms ~/ 1000;
    final millis = ms % 1000;
    if (seconds >= 60) {
      final minutes = seconds ~/ 60;
      final secs = seconds % 60;
      return '${minutes}m${secs.toString().padLeft(2, '0')}.${millis.toString().padLeft(3, '0')}';
    }
    return '$seconds.${millis.toString().padLeft(3, '0')}';
  }

  /// 原始时间字符串
  String get rawTimeString {
    final ms = time.inMilliseconds;
    final seconds = ms ~/ 1000;
    final millis = ms % 1000;
    if (seconds >= 60) {
      final minutes = seconds ~/ 60;
      final secs = seconds % 60;
      return '${minutes}m${secs.toString().padLeft(2, '0')}.${millis.toString().padLeft(3, '0')}';
    }
    return '$seconds.${millis.toString().padLeft(3, '0')}';
  }

  String get penaltyString {
    switch (penalty) {
      case Penalty.plus2:
        return '+';
      case Penalty.dnf:
        return 'DNF';
      default:
        return '';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'timeMs': time.inMilliseconds,
      'penalty': penalty.index,
      'scramble': scramble,
      'mode': mode.index,
      'caseId': caseId,
      'comment': comment,
    };
  }

  factory SolveRecord.fromJson(Map<String, dynamic> json) {
    return SolveRecord(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      time: Duration(milliseconds: json['timeMs'] as int),
      penalty: Penalty.values[json['penalty'] as int],
      scramble: json['scramble'] as String,
      mode: TrainingMode.values[json['mode'] as int],
      caseId: json['caseId'] as String?,
      comment: json['comment'] as String?,
    );
  }

  static List<SolveRecord> listFromJson(String jsonStr) {
    final List<dynamic> list = jsonDecode(jsonStr);
    return list
        .map((e) => SolveRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String listToJson(List<SolveRecord> records) {
    return jsonEncode(records.map((r) => r.toJson()).toList());
  }
}

/// 统计工具类
class StatsCalculator {
  /// 计算平均
  static Duration? calculateAverage(List<SolveRecord> records, int count) {
    if (records.length < count) return null;
    final recent = records.sublist(0, count);
    final valid = recent.where((r) => r.penalty != Penalty.dnf).toList();
    if (valid.isEmpty) return null;
    final sum = valid.fold<int>(
      0,
      (s, r) => s + r.effectiveTime.inMilliseconds,
    );
    return Duration(milliseconds: sum ~/ valid.length);
  }

  /// 计算去头尾平均 (如ao5, ao12)
  static Duration? calculateTrimmedAverage(
    List<SolveRecord> records,
    int count,
  ) {
    if (records.length < count) return null;
    final recent = records.sublist(0, count).toList();
    final valid = recent.where((r) => r.penalty != Penalty.dnf).toList();
    final dnfCount = recent.length - valid.length;
    if (dnfCount > 1) return null;

    final times = valid
        .map<int?>((r) => r.effectiveTime.inMilliseconds)
        .toList();
    if (dnfCount == 1) times.add(null);
    times.sort((a, b) {
      if (a == null && b == null) return 0;
      if (a == null) return 1;
      if (b == null) return -1;
      return a.compareTo(b);
    });
    if (times.length <= 2) return null;

    final trimmed = times.sublist(1, times.length - 1);
    if (trimmed.any((time) => time == null)) return null;
    final sum = trimmed.cast<int>().reduce((a, b) => a + b);
    return Duration(milliseconds: sum ~/ trimmed.length);
  }

  /// 计算最佳单次
  static Duration? calculateBest(List<SolveRecord> records) {
    final valid = records.where((r) => r.penalty != Penalty.dnf).toList();
    if (valid.isEmpty) return null;
    return valid.map((r) => r.effectiveTime).reduce((a, b) => a < b ? a : b);
  }

  /// 计算最佳平均
  static Duration? calculateBestAverage(List<SolveRecord> records, int count) {
    if (records.length < count) return null;
    Duration? best;
    for (int i = 0; i <= records.length - count; i++) {
      final avg = calculateTrimmedAverage(records.sublist(i, i + count), count);
      if (avg != null && (best == null || avg < best)) {
        best = avg;
      }
    }
    return best;
  }

  static String formatDuration(Duration? d) {
    if (d == null) return '--.--';
    final ms = d.inMilliseconds;
    final seconds = ms ~/ 1000;
    final millis = ms % 1000;
    if (seconds >= 60) {
      final minutes = seconds ~/ 60;
      final secs = seconds % 60;
      return '${minutes}m${secs.toString().padLeft(2, '0')}.${millis.toString().padLeft(3, '0')}';
    }
    return '$seconds.${millis.toString().padLeft(3, '0')}';
  }
}
