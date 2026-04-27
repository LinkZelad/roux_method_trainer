import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/app_settings.dart';
import '../models/solve_record.dart';
import '../models/scramble_generator.dart';
import '../models/cmll_algs.dart';
import '../roux/cube.dart';
import '../roux/solver.dart';
import '../services/storage_service.dart';

enum TimerState {
  idle, // 等待开始
  ready, // 按住准备中（绿色）
  running, // 计时中
  stopped, // 停止，显示成绩
}

class TimerProvider extends ChangeNotifier {
  TimerState _state = TimerState.idle;
  DateTime? _startTime;
  DateTime? _endTime;
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  // 当前训练模式
  TrainingMode _mode = TrainingMode.standard;
  String _scramble = '';
  String? _currentCaseId;
  String? _currentCaseName;
  String? _currentCaseAlg; // 当前case的解法
  CmllCase? _selectedCmllCase;
  List<String>? _selectedCmllCategories;

  // 成绩列表
  final List<SolveRecord> _records = [];
  Penalty _currentPenalty = Penalty.none;
  AppSettings _settings = const AppSettings();

  TimerState get state => _state;
  Duration get elapsed => _elapsed;
  String get scramble => _scramble;
  TrainingMode get mode => _mode;
  String? get currentCaseId => _currentCaseId;
  String? get currentCaseName => _currentCaseName;
  String? get currentCaseAlg => _currentCaseAlg;
  List<SolveRecord> get records => List.unmodifiable(_records);
  Penalty get currentPenalty => _currentPenalty;
  AppSettings get settings => _settings;

  static final Random _rand = Random();
  static final RouxSolver _lseSolver = RouxSolver.lse();
  static final RouxSolver _eolrSolver = RouxSolver.eolr();

  TimerProvider() {
    _generateNewScramble();
    _loadRecords();
    _loadSettings();
  }

  Future<void> _loadRecords() async {
    final records = await StorageService.loadRecords();
    _records.addAll(records);
    notifyListeners();
  }

  Future<void> _saveRecords() async {
    await StorageService.saveRecords(_records);
  }

  Future<void> _loadSettings() async {
    _settings = await StorageService.loadSettings();
    _generateNewScramble();
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings settings) async {
    _settings = settings;
    await StorageService.saveSettings(_settings);
    _generateNewScramble();
    notifyListeners();
  }

  void setMode(TrainingMode mode) {
    _mode = mode;
    _selectedCmllCase = null;
    _selectedCmllCategories = null;
    _generateNewScramble();
    notifyListeners();
  }

  void selectCmllCategory(String category) {
    _mode = TrainingMode.cmll;
    _selectedCmllCase = null;
    _selectedCmllCategories = [category];
    _generateNewScramble();
    notifyListeners();
  }

  void selectCmllCase(CmllCase cmllCase) {
    _mode = TrainingMode.cmll;
    _selectedCmllCase = cmllCase;
    _selectedCmllCategories = [cmllCase.category];
    _generateNewScramble();
    notifyListeners();
  }

  void _generateNewScramble() {
    switch (_mode) {
      case TrainingMode.standard:
        _scramble = ScrambleGenerator.generateStandard(
          length: _settings.standardScrambleLength,
        );
        _currentCaseId = null;
        _currentCaseName = null;
        _currentCaseAlg = null;
        break;
      case TrainingMode.cmll:
        final case_ =
            _selectedCmllCase ??
            getRandomCmllCase(categories: _selectedCmllCategories);
        _currentCaseId = case_.id;
        _currentCaseName = '${case_.category} ${case_.name}';
        _currentCaseAlg = case_.alg;
        // CMLL训练打乱：预打乱(模拟SB完成状态) + 随机AUF + case setup
        final sbSetup = "R' U' R' U R U R U' R' U R U r'";
        final auf = ['', 'U ', "U' ", 'U2 '][_rand.nextInt(4)];
        // 使用case算法的逆作为setup，这样应用算法就能还原
        _scramble = '$sbSetup $auf${_inverseAlg(case_.alg)}';
        break;
      case TrainingMode.fb:
        _scramble = ScrambleGenerator.generateRoux(
          length: _settings.rouxScrambleLength,
        );
        _currentCaseId = null;
        _currentCaseName = null;
        _currentCaseAlg = null;
        break;
      case TrainingMode.sb:
        _scramble = ScrambleGenerator.generateRoux(
          length: _settings.rouxScrambleLength,
        );
        _currentCaseId = null;
        _currentCaseName = null;
        _currentCaseAlg = null;
        break;
      case TrainingMode.lseEOLR:
        _scramble = _generateEolrScramble();
        _currentCaseId = null;
        _currentCaseName = null;
        _currentCaseAlg = null;
        break;
      case TrainingMode.lse4C:
        _scramble = _generateLse4cScramble();
        _currentCaseId = null;
        _currentCaseName = null;
        _currentCaseAlg = null;
        break;
    }
  }

  String _generateEolrScramble() {
    return _eolrSolver
            .generateScramble(
              randomState: (random) =>
                  RouxCubeUtil.getRandomLse(random: random),
              random: _rand,
              maxDepth: 10,
              maxAttempts: 30,
            )
            ?.toString() ??
        'M2 U M2';
  }

  String _generateLse4cScramble() {
    return _lseSolver
            .generateScramble(
              randomState: (random) =>
                  RouxCubeUtil.getRandomLse4c(random: random),
              random: _rand,
              maxDepth: 8,
              maxAttempts: 30,
            )
            ?.toString() ??
        'M2';
  }

  /// 计算算法的逆
  String _inverseAlg(String alg) {
    return RouxMoveSeq.parse(alg).inverse().toString();
  }

  /// 准备开始（按住屏幕）
  void prepareStart() {
    if (_state == TimerState.idle) {
      _state = TimerState.ready;
      _elapsed = Duration.zero;
      notifyListeners();
    }
  }

  /// 取消准备
  void cancelPrepare() {
    if (_state == TimerState.ready) {
      _state = TimerState.idle;
      notifyListeners();
    }
  }

  /// 开始计时
  void start() {
    if (_state == TimerState.ready) {
      _state = TimerState.running;
      _startTime = DateTime.now();
      _currentPenalty = Penalty.none;
      _timer = Timer.periodic(const Duration(milliseconds: 10), (_) {
        _updateElapsed();
      });
      notifyListeners();
    }
  }

  void startImmediately() {
    if (_state == TimerState.idle) {
      prepareStart();
      start();
    }
  }

  /// 停止计时
  void stop() {
    if (_state == TimerState.running) {
      _timer?.cancel();
      _endTime = DateTime.now();
      _updateElapsed();
      _state = TimerState.stopped;
      notifyListeners();
    }
  }

  void _updateElapsed() {
    if (_startTime != null) {
      _elapsed = DateTime.now().difference(_startTime!);
      notifyListeners();
    }
  }

  /// 保存当前成绩
  void saveSolve() {
    if (_state == TimerState.stopped &&
        _startTime != null &&
        _endTime != null) {
      final record = SolveRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        time: _elapsed,
        penalty: _currentPenalty,
        scramble: _scramble,
        mode: _mode,
        caseId: _currentCaseId,
      );
      _records.insert(0, record);
      _saveRecords();
      _generateNewScramble();
      _state = TimerState.idle;
      notifyListeners();
    }
  }

  /// 设置当前成绩的惩罚
  void setPenalty(Penalty penalty) {
    _currentPenalty = penalty;
    notifyListeners();
  }

  /// 删除成绩
  void deleteRecord(String id) {
    _records.removeWhere((r) => r.id == id);
    _saveRecords();
    notifyListeners();
  }

  Future<void> clearRecords() async {
    _records.clear();
    await StorageService.clearRecords();
    notifyListeners();
  }

  /// 给指定成绩加惩罚
  void setRecordPenalty(String id, Penalty penalty) {
    final idx = _records.indexWhere((r) => r.id == id);
    if (idx >= 0) {
      final old = _records[idx];
      _records[idx] = SolveRecord(
        id: old.id,
        timestamp: old.timestamp,
        time: old.time,
        penalty: penalty,
        scramble: old.scramble,
        mode: old.mode,
        caseId: old.caseId,
        comment: old.comment,
      );
      _saveRecords();
      notifyListeners();
    }
  }

  /// 获取下一次打乱（不保存当前成绩）
  void nextScramble() {
    _generateNewScramble();
    _state = TimerState.idle;
    _elapsed = Duration.zero;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
