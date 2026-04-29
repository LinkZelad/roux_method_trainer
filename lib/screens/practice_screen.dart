
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cmll_algs.dart';
import '../models/solve_record.dart';
import '../providers/timer_provider.dart';
import '../l10n/app_localizations.dart';
import '../roux/scramble_isolate.dart';
import '../widgets/cube_net.dart';
import '../widgets/cube_net_highlight.dart';

class PracticeScreen extends StatefulWidget {
  final TrainingMode initialMode;

  const PracticeScreen({super.key, required this.initialMode});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late TrainingMode _mode;
  String _scramble = '';
  String? _recommendedSolution;
  bool _showSolution = false;
  bool _isLoading = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _generateNewCase();
  }

  void _generateNewCase() {
    setState(() {
      _isLoading = true;
      _showSolution = false;
      _recommendedSolution = null;
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
          _isLoading = false;
        });
      }
    });
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
            // Scramble display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    l10n['scramble'],
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_isLoading)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n['generating'],
                          style: const TextStyle(color: Colors.white38, fontSize: 16),
                        ),
                      ],
                    )
                  else
                    Text(
                      _scramble,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Cube net
            if (!_isLoading && _scramble.isNotEmpty)
              Consumer<TimerProvider>(
                builder: (context, timer, child) {
                  return CubeNet.fromScramble(
                    _scramble,
                    colorScheme: timer.settings.colorScheme,
                    highlightMask: highlightMaskForMode(_mode),
                    stickerSize: 26,
                  );
                },
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
