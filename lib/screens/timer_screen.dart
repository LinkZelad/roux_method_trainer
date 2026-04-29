import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../models/solve_record.dart';
import '../l10n/app_localizations.dart';
import '../widgets/cube_net.dart';
import '../widgets/cube_net_highlight.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  bool _isHolding = false;
  DateTime? _holdStartTime;
  static const _minHoldDuration = Duration(milliseconds: 350);

  String _formatTime(Duration duration) {
    final ms = duration.inMilliseconds;
    final seconds = ms ~/ 1000;
    final millis = ms % 1000;
    if (seconds >= 60) {
      final minutes = seconds ~/ 60;
      final secs = seconds % 60;
      return '$minutes:${secs.toString().padLeft(2, '0')}.${millis.toString().padLeft(3, '0')}';
    }
    return '${seconds.toString()}.${millis.toString().padLeft(3, '0')}';
  }

  Color _getTimerColor(TimerState state) {
    switch (state) {
      case TimerState.ready:
        return Colors.green;
      case TimerState.running:
        return Colors.white;
      case TimerState.stopped:
        return Colors.orange;
      default:
        return Colors.white70;
    }
  }

  void _onPointerDown(PointerDownEvent event, TimerProvider timer) {
    if (timer.state == TimerState.idle) {
      if (!timer.settings.holdToStart) {
        timer.startImmediately();
        return;
      }
      setState(() {
        _isHolding = true;
        _holdStartTime = DateTime.now();
      });
      timer.prepareStart();
    } else if (timer.state == TimerState.running) {
      timer.stop();
    }
  }

  void _onPointerUp(PointerUpEvent event, TimerProvider timer) {
    if (timer.state == TimerState.ready && _isHolding) {
      final holdDuration = DateTime.now().difference(_holdStartTime!);
      if (holdDuration >= _minHoldDuration) {
        if (timer.settings.startCue) {
          HapticFeedback.mediumImpact();
        }
        timer.start();
      } else {
        timer.cancelPrepare();
      }
      setState(() {
        _isHolding = false;
        _holdStartTime = null;
      });
    }
  }

  void _onPointerCancel(PointerCancelEvent event, TimerProvider timer) {
    if (timer.state == TimerState.ready) {
      timer.cancelPrepare();
      setState(() {
        _isHolding = false;
        _holdStartTime = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timer, child) {
        final isRunning = timer.state == TimerState.running;
        final isStopped = timer.state == TimerState.stopped;
        final l10n = AppLocalizations(timer.settings.locale);

        return Container(
          color: Colors.black,
          child: SafeArea(
            child: Column(
              children: [
                // 顶部信息栏（计时中隐藏）
                if (!isRunning) _buildTopBar(context, timer),
                // 打乱显示 + 统计栏（计时中隐藏）
                if (!isRunning)
                  Flexible(
                    flex: 2,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Scramble text - compact
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
                              child: Text(
                                timer.scramble,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: timer.isGeneratingScramble
                                      ? Colors.white38
                                      : Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            // Cube net - auto-scales to fit remaining space
                            if (!timer.isGeneratingScramble &&
                                timer.scramble != 'Generating scramble...' &&
                                timer.scramble.isNotEmpty)
                              Expanded(
                                child: Center(
                                  child: CubeNet.fromScramble(
                                    timer.scramble,
                                    colorScheme: timer.settings.colorScheme,
                                    highlightMask: highlightMaskForMode(
                                      timer.mode,
                                    ),
                                    stickerSize: 26,
                                  ),
                                ),
                              ),
                            // Stats bar - compact
                            _buildStatsBar(timer),
                          ],
                        );
                      },
                    ),
                  ),
                // 计时器主显示 - 触摸区域
                Expanded(
                  child: Listener(
                    onPointerDown: (event) => _onPointerDown(event, timer),
                    onPointerUp: (event) => _onPointerUp(event, timer),
                    onPointerCancel: (event) => _onPointerCancel(event, timer),
                    child: Container(
                      color: Colors.transparent,
                      width: double.infinity,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final baseFontSize =
                              (isRunning ? 120.0 : 96.0) *
                              timer.settings.timerFontScale;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: constraints.maxWidth,
                                  maxHeight: constraints.maxHeight * 0.72,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    _formatTime(timer.elapsed),
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: baseFontSize,
                                      fontWeight: FontWeight.w300,
                                      color: _getTimerColor(timer.state),
                                      fontFamily: 'RobotoMono',
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              if (timer.state == TimerState.ready)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    l10n['releaseToStart'],
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              if (timer.state == TimerState.idle)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    timer.settings.holdToStart
                                        ? l10n['holdToStart']
                                        : l10n['tapToStart'],
                                    style: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                // 底部成绩列表（计时中隐藏）
                if (!isRunning) Flexible(child: _buildSessionSolves(timer)),
                // 底部惩罚按钮（仅停止时显示）
                if (isStopped) _buildPenaltyBar(context, timer),
                if (isStopped && timer.currentCaseAlg != null)
                  _buildSolutionDisplay(timer),

              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, TimerProvider timer) {
    final modeText = localizedModeLabel(timer.mode, timer.settings.locale);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            modeText,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (timer.currentCaseName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                timer.currentCaseName!,
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Scramble display is now inlined in the main build for better layout control.

  Widget _buildStatsBar(TimerProvider timer) {
    final records = timer.records;
    final avg5 = StatsCalculator.calculateTrimmedAverage(records, 5);
    final avg12 = StatsCalculator.calculateTrimmedAverage(records, 12);
    final best = StatsCalculator.calculateBest(records);
    final l10n = AppLocalizations(timer.settings.locale);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem(l10n['ao5'], StatsCalculator.formatDuration(avg5)),
          _statItem(l10n['ao12'], StatsCalculator.formatDuration(avg12)),
          _statItem(l10n['best'], StatsCalculator.formatDuration(best)),
          _statItem(l10n['count'], '${records.length}'),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSessionSolves(TimerProvider timer) {
    final records = timer.records.take(12).toList();
    if (records.isEmpty) {
      return const SizedBox(height: 60);
    }

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        reverse: true,
        scrollDirection: Axis.horizontal,
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          final isLatest = index == 0;
          return Container(
            width: 80,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: isLatest ? Colors.white10 : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '#${timer.records.length - index}',
                  style: TextStyle(
                    color: isLatest ? Colors.amber : Colors.white54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  record.timeString,
                  style: TextStyle(
                    color: record.penalty == Penalty.dnf
                        ? Colors.red
                        : (isLatest ? Colors.white : Colors.white70),
                    fontSize: 16,
                    fontWeight: isLatest ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (record.penalty != Penalty.none)
                  Text(
                    record.penaltyString,
                    style: TextStyle(
                      color: record.penalty == Penalty.dnf
                          ? Colors.red
                          : Colors.orange,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSolutionDisplay(TimerProvider timer) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations(timer.settings.locale)['solution'],
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            timer.currentCaseAlg!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'RobotoMono',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPenaltyBar(BuildContext context, TimerProvider timer) {
    final l10n = AppLocalizations(timer.settings.locale);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _penaltyButton(
            l10n['ok'],
            timer.currentPenalty == Penalty.none
                ? Colors.green
                : Colors.white24,
            () => timer.setPenalty(Penalty.none),
          ),
          _penaltyButton(
            l10n['penaltyPlus2'],
            timer.currentPenalty == Penalty.plus2
                ? Colors.orange
                : Colors.white24,
            () => timer.setPenalty(Penalty.plus2),
          ),
          _penaltyButton(
            l10n['penaltyDNF'],
            timer.currentPenalty == Penalty.dnf ? Colors.red : Colors.white24,
            () => timer.setPenalty(Penalty.dnf),
          ),
          _penaltyButton(l10n['next'], Colors.blue, () => timer.saveSolve()),
        ],
      ),
    );
  }

  Widget _penaltyButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
