import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/app_settings.dart';
import '../models/solve_record.dart';

class StorageService {
  static const String _recordsKey = 'solve_records';
  static const String _settingsKey = 'app_settings';

  static Future<void> saveRecords(List<SolveRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = SolveRecord.listToJson(records);
    await prefs.setString(_recordsKey, jsonStr);
  }

  static Future<List<SolveRecord>> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_recordsKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      return SolveRecord.listFromJson(jsonStr);
    } catch (e) {
      return [];
    }
  }

  static Future<void> clearRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recordsKey);
  }

  static Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  static Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_settingsKey);
    if (jsonStr == null || jsonStr.isEmpty) return const AppSettings();
    try {
      return AppSettings.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    } catch (_) {
      return const AppSettings();
    }
  }
}
