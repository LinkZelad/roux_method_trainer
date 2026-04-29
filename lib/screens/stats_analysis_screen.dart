import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../models/solve_record.dart';
import '../models/cmll_algs.dart';

class StatsAnalysisScreen extends StatelessWidget {
  const StatsAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Weakness Analysis', style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<TimerProvider>(
        builder: (context, timer, _) {
          final records = timer.records;
          if (records.isEmpty) {
            return const Center(
              child: Text('No solve records found.', style: TextStyle(color: Colors.white54)),
            );
          }

          final analysis = _analyzeRecords(records);

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: analysis.length,
            itemBuilder: (context, index) {
              final group = analysis[index];
              return _buildAnalysisGroup(group);
            },
          );
        },
      ),
    );
  }

  List<_AnalysisGroup> _analyzeRecords(List<SolveRecord> records) {
    final groups = <TrainingMode, Map<String?, List<SolveRecord>>>{};

    for (final record in records) {
      groups.putIfAbsent(record.mode, () => {});
      groups[record.mode]!.putIfAbsent(record.caseId, () => []);
      groups[record.mode]![record.caseId]!.add(record);
    }

    final result = <_AnalysisGroup>[];
    groups.forEach((mode, caseGroups) {
      final caseAnalysis = <_CaseStats>[];
      caseGroups.forEach((caseId, solves) {
        final validSolves = solves.where((s) => s.penalty != Penalty.dnf).toList();
        if (validSolves.isEmpty) return;

        final avgMs = validSolves.fold<int>(0, (sum, s) => sum + s.effectiveTime.inMilliseconds) ~/ validSolves.length;
        
        String name = 'General';
        if (mode == TrainingMode.cmll && caseId != null) {
          final cmllCase = cmllAlgs.firstWhere((c) => c.id == caseId, orElse: () => cmllAlgs.first);
          name = '${cmllCase.category} ${cmllCase.name}';
        } else if (caseId != null) {
          name = caseId;
        }

        caseAnalysis.add(_CaseStats(
          id: caseId ?? 'unknown',
          name: name,
          avg: Duration(milliseconds: avgMs),
          count: solves.length,
          dnfCount: solves.length - validSolves.length,
        ));
      });

      // Sort by slowest average
      caseAnalysis.sort((a, b) => b.avg.compareTo(a.avg));
      result.add(_AnalysisGroup(mode: mode, stats: caseAnalysis));
    });

    return result;
  }

  Widget _buildAnalysisGroup(_AnalysisGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            group.mode.toString().split('.').last.toUpperCase(),
            style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        ...group.stats.map((stat) => Card(
          color: Colors.grey[900],
          child: ListTile(
            title: Text(stat.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text('${stat.count} solves, ${stat.dnfCount} DNF', style: const TextStyle(color: Colors.white54)),
            trailing: Text(
              StatsCalculator.formatDuration(stat.avg),
              style: TextStyle(
                color: stat.avg > const Duration(seconds: 15) ? Colors.redAccent : Colors.greenAccent,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        )),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _AnalysisGroup {
  final TrainingMode mode;
  final List<_CaseStats> stats;
  const _AnalysisGroup({required this.mode, required this.stats});
}

class _CaseStats {
  final String id;
  final String name;
  final Duration avg;
  final int count;
  final int dnfCount;
  const _CaseStats({required this.id, required this.name, required this.avg, required this.count, required this.dnfCount});
}
