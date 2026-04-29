
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cmll_algs.dart';
import '../models/solve_record.dart';
import '../providers/timer_provider.dart';
import '../l10n/app_localizations.dart';
import '../roux/scramble_isolate.dart';
import '../roux/cube.dart';
import '../widgets/cube_3d.dart';

class PracticeScreen extends StatefulWidget {
  final TrainingMode initialMode;

  const PracticeScreen({super.key, required this.initialMode});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> with TickerProviderStateMixin {
  late TrainingMode _mode;
  String _scramble = '';
  String? _recommendedSolution;
  List<String> _solutionMoves = [];
  int _currentSolutionStep = 0;
  bool _showSolution = false;
  bool _isLoading = false;
  final Random _random = Random();

  late RouxCube _currentCube;
  
  late AnimationController _animController;
  String? _animatingMove;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _currentCube = RouxCube.solved();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _generateNewCase();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _generateNewCase() {
    setState(() {
      _isLoading = true;
      _showSolution = false;
      _recommendedSolution = null;
      _solutionMoves = [];
      _currentSolutionStep = 0;
      _animatingMove = null;
      _isAnimating = false;
    });

    final seed = _random.nextInt(1 << 31);
    String? cmllAlg;
    if (_mode == TrainingMode.cmll) {
      cmllAlg = getRandomCmllCase().alg;
    }

    compute(generatePracticeScramble, IsolatePracticeRequest(
      mode: _mode.index,
      seed: seed,
      cmllAlg: cmllAlg,
    )).then((result) {
      if (mounted) {
        setState(() {
          _scramble = result.scramble;
          _recommendedSolution = result.solution;
          if (_recommendedSolution != null) {
            _solutionMoves = RouxMoveSeq.parse(_recommendedSolution!).moves.map((m) => m.name).toList();
          }
          _currentCube = RouxCube.solved().applyAlg(_scramble);
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _stepSolution(int direction) async {
    if (_isAnimating || _recommendedSolution == null) return;
    
    if (direction > 0 && _currentSolutionStep < _solutionMoves.length) {
      final move = _solutionMoves[_currentSolutionStep];
      setState(() {
        _animatingMove = move;
        _isAnimating = true;
      });
      await _animController.forward(from: 0);
      setState(() {
        _currentCube = _currentCube.applyAlg(move);
        _currentSolutionStep++;
        _animatingMove = null;
        _isAnimating = false;
      });
      _animController.reset();
    } else if (direction < 0 && _currentSolutionStep > 0) {
      final move = _solutionMoves[_currentSolutionStep - 1];
      final inverseMove = RouxMoveSeq.parse(move).inverse().moves.first.name;
      setState(() {
        _animatingMove = inverseMove;
        _isAnimating = true;
      });
      await _animController.forward(from: 0);
      setState(() {
        _currentCube = _currentCube.applyAlg(inverseMove);
        _currentSolutionStep--;
        _animatingMove = null;
        _isAnimating = false;
      });
      _animController.reset();
    }
  }

  String _modeLabel(TrainingMode mode) {
    return localizedModeLabel(mode, context.read<TimerProvider>().settings.locale);
  }

  void _changeMode(TrainingMode mode) {
    if (_mode == mode) return;
    setState(() => _mode = mode);
    _generateNewCase();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations(context.watch<TimerProvider>().settings.locale);
    final colorScheme = context.watch<TimerProvider>().settings.colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(l10n['practiceMode'], style: const TextStyle(color: Colors.white)),
        actions: [
          PopupMenuButton<TrainingMode>(
            icon: const Icon(Icons.settings, color: Colors.white54),
            onSelected: _changeMode,
            itemBuilder: (context) => [
              for (final mode in TrainingMode.values)
                PopupMenuItem(value: mode, child: Text(_modeLabel(mode))),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Mode selector chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final mode in TrainingMode.values)
                  ChoiceChip(
                    label: Text(_modeLabel(mode)),
                    selected: _mode == mode,
                    onSelected: (_) => _changeMode(mode),
                    selectedColor: Colors.green,
                    backgroundColor: Colors.grey[900],
                    labelStyle: TextStyle(
                      color: _mode == mode ? Colors.black : Colors.white70,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 3D Cube Display
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
              ),
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Colors.green))
                : AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      return Cube3D.fromCube(
                        _currentCube,
                        colorScheme: colorScheme,
                        size: 240,
                        animatingMove: _animatingMove,
                        animationProgress: _animController.value,
                      );
                    },
                  ),
            ),
            
            const SizedBox(height: 16),
            // Scramble text
            if (!_isLoading)
              Text(
                _scramble,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontFamily: 'RobotoMono',
                ),
              ),

            const SizedBox(height: 24),
            // Solution section
            if (!_isLoading && _recommendedSolution != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      l10n['recommendedSolution'],
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_showSolution)
                      Column(
                        children: [
                          Text(
                            _recommendedSolution!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'RobotoMono',
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Step $_currentSolutionStep / ${_solutionMoves.length} (${_solutionMoves.length} moves)',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Step Controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
                                onPressed: _currentSolutionStep > 0 ? () => _stepSolution(-1) : null,
                              ),
                              const SizedBox(width: 20),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
                                onPressed: _currentSolutionStep < _solutionMoves.length ? () => _stepSolution(1) : null,
                              ),
                              const SizedBox(width: 20),
                              IconButton(
                                icon: const Icon(Icons.refresh, color: Colors.white70),
                                onPressed: () {
                                  setState(() {
                                    _currentCube = RouxCube.solved().applyAlg(_scramble);
                                    _currentSolutionStep = 0;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      )
                    else
                      GestureDetector(
                        onTap: () => setState(() => _showSolution = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.orange.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.visibility_off,
                                color: Colors.orange,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n['tapToReveal'],
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 32),
            // Next button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _generateNewCase,
              icon: const Icon(Icons.skip_next),
              label: Text(l10n['nextCase']),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

