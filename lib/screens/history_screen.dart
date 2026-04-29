import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../models/solve_record.dart';
import '../l10n/app_localizations.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  String _formatDuration(Duration? d) {
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

  String _modeName(TrainingMode mode, String locale) {
    return localizedModeLabel(mode, locale);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Consumer<TimerProvider>(
          builder: (context, timer, _) => Text(
            AppLocalizations(timer.settings.locale)['sessionHistory'],
            style: const TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white70),
            onPressed: () {
              _showClearConfirm(context);
            },
          ),
        ],
      ),
      body: Consumer<TimerProvider>(
        builder: (context, timer, child) {
          final records = timer.records;
          final l10n = AppLocalizations(timer.settings.locale);

          if (records.isEmpty) {
            return Center(
              child: Text(
                l10n['noSolvesYet'],
                style: const TextStyle(color: Colors.white54, fontSize: 18),
              ),
            );
          }

          // 计算统计
          final avg5 = StatsCalculator.calculateTrimmedAverage(records, 5);
          final avg12 = StatsCalculator.calculateTrimmedAverage(records, 12);
          final avg100 = StatsCalculator.calculateTrimmedAverage(records, 100);
          final best = StatsCalculator.calculateBest(records);
          final bestAvg5 = StatsCalculator.calculateBestAverage(records, 5);
          final bestAvg12 = StatsCalculator.calculateBestAverage(records, 12);

          return Column(
            children: [
              // 统计面板
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatBox(l10n['currentAo5'], _formatDuration(avg5)),
                        _buildStatBox(l10n['currentAo12'], _formatDuration(avg12)),
                        _buildStatBox(l10n['currentAo100'], _formatDuration(avg100)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatBox(l10n['best'], _formatDuration(best)),
                        _buildStatBox(l10n['bestAo5'], _formatDuration(bestAvg5)),
                        _buildStatBox(l10n['bestAo12'], _formatDuration(bestAvg12)),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12),
              // 成绩列表
              Expanded(
                child: ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    final isDNF = record.penalty == Penalty.dnf;

                    return Dismissible(
                      key: Key(record.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        timer.deleteRecord(record.id);
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isDNF
                              ? Colors.red.withValues(alpha: 0.2)
                              : Colors.white10,
                          child: Text(
                            '${records.length - index}',
                            style: TextStyle(
                              color: isDNF ? Colors.red : Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              record.timeString,
                              style: TextStyle(
                                color: isDNF ? Colors.red : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            if (record.penalty == Penalty.plus2)
                              Text(
                                ' ${l10n['penaltyPlus2']}',
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _modeName(record.mode, timer.settings.locale),
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              record.scramble,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white54,
                          ),
                          color: Colors.grey[900],
                          onSelected: (value) {
                            if (value == 'ok') {
                              timer.setRecordPenalty(record.id, Penalty.none);
                            } else if (value == 'plus2') {
                              timer.setRecordPenalty(record.id, Penalty.plus2);
                            } else if (value == 'dnf') {
                              timer.setRecordPenalty(record.id, Penalty.dnf);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'ok',
                              child: Text(
                                l10n['ok'],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'plus2',
                              child: Text(
                                l10n['penaltyPlus2'],
                                style: const TextStyle(color: Colors.orange),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'dnf',
                              child: Text(
                                l10n['penaltyDNF'],
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showClearConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          AppLocalizations(context.read<TimerProvider>().settings.locale)['clearSession'],
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          AppLocalizations(context.read<TimerProvider>().settings.locale)['clearSessionConfirm'],
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations(context.read<TimerProvider>().settings.locale)['cancel'],
              style: const TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              final timer = context.read<TimerProvider>();
              timer.clearRecords();
              Navigator.pop(context);
            },
            child: Text(AppLocalizations(context.read<TimerProvider>().settings.locale)['clear'], style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
