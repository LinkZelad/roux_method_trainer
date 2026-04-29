import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/app_settings.dart';
import '../models/lse_algs.dart';
import '../providers/timer_provider.dart';
import '../widgets/cube_net.dart';
import '../widgets/cube_top_view.dart';

/// LSE (Last Six Edges) Reference Screen
/// Contains EO, LR, and 4C algorithms for Roux method with cube diagrams.
class LseReferenceScreen extends StatelessWidget {
  const LseReferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations(context.watch<TimerProvider>().settings.locale);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: const Text(
            'LSE Reference',
            style: TextStyle(color: Colors.white),
          ),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.purple,
            unselectedLabelColor: Colors.white54,
            indicatorColor: Colors.purple,
            tabs: [
              Tab(text: 'EO'),
              Tab(text: 'LR'),
              Tab(text: '4C'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildEoTab(context, l10n),
            _buildLrTab(context, l10n),
            _buildFourCTab(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildEoTab(BuildContext context, AppLocalizations l10n) {
    final colorScheme = context.watch<TimerProvider>().settings.colorScheme;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: eoCases.length,
      itemBuilder: (context, index) {
        final case_ = eoCases[index];
        return _buildAlgCard(
          context,
          l10n,
          colorScheme: colorScheme,
          case_: case_,
          showTopView: true,
        );
      },
    );
  }

  Widget _buildLrTab(BuildContext context, AppLocalizations l10n) {
    final colorScheme = context.watch<TimerProvider>().settings.colorScheme;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lrCases.length,
      itemBuilder: (context, index) {
        final case_ = lrCases[index];
        return _buildAlgCard(
          context,
          l10n,
          colorScheme: colorScheme,
          case_: case_,
          showTopView: false,
        );
      },
    );
  }

  Widget _buildFourCTab(BuildContext context, AppLocalizations l10n) {
    final colorScheme = context.watch<TimerProvider>().settings.colorScheme;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: fourCCases.length,
      itemBuilder: (context, index) {
        final case_ = fourCCases[index];
        return _buildAlgCard(
          context,
          l10n,
          colorScheme: colorScheme,
          case_: case_,
          showTopView: false,
        );
      },
    );
  }

  Widget _buildAlgCard(
    BuildContext context,
    AppLocalizations l10n, {
    required CubeColorScheme colorScheme,
    required LseCase case_,
    required bool showTopView,
  }) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        case_.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        case_.description,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Cube diagram
            Center(
              child: showTopView
                  ? CubeTopView.fromScramble(
                      case_.setup,
                      colorScheme: colorScheme,
                      stickerSize: 22,
                    )
                  : CubeNet.fromScramble(
                      case_.setup,
                      colorScheme: colorScheme,
                      stickerSize: 18,
                    ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                case_.alg,
                style: const TextStyle(
                  color: Colors.purple,
                  fontSize: 16,
                  fontFamily: 'RobotoMono',
                  letterSpacing: 0.5,
                ),
              ),
            ),
            if (case_.mirror != null) ...[
              const SizedBox(height: 6),
              Text(
                'Mirror: ${case_.mirror}',
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 13,
                  fontFamily: 'RobotoMono',
                ),
              ),
            ],
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: case_.alg));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n['algorithmCopied']),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.copy,
                  size: 16,
                  color: Colors.white54,
                ),
                label: Text(
                  l10n['copy'],
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
