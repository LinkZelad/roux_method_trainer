import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/cmll_algs.dart';
import '../providers/timer_provider.dart';
import '../roux/cube.dart';
import '../l10n/app_localizations.dart';
import '../widgets/cube_net_highlight.dart';
import '../widgets/cube_top_view.dart';

class CmllReferenceScreen extends StatelessWidget {
  const CmllReferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations(context.watch<TimerProvider>().settings.locale);
    final categories = getCmllCategories();
    final colorScheme = context.watch<TimerProvider>().settings.colorScheme;

    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: Text(
            l10n['cmllReference'],
            style: const TextStyle(color: Colors.white),
          ),
          bottom: TabBar(
            isScrollable: true,
            labelColor: Colors.orange,
            unselectedLabelColor: Colors.white54,
            indicatorColor: Colors.orange,
            tabs: categories.map((c) => Tab(text: c)).toList(),
          ),
        ),
        body: TabBarView(
          children: categories.map((category) {
            final cases = getCmllByCategory(category);
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cases.length,
              itemBuilder: (context, index) {
                final case_ = cases[index];
                // Generate the cube state for this case
                final scramble = RouxMoveSeq.parse(case_.alg).inverse().toString();
                final caseCube = RouxCube.solved().applyAlg(scramble);
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
                            Text(
                              case_.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                case_.category,
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Top-down 2D cube view for CMLL recognition
                        Center(
                          child: CubeTopView.fromCube(
                            caseCube,
                            colorScheme: colorScheme,
                            stickerSize: 28,
                            highlightMask: cmllHighlightMask(),
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
                              color: Colors.green,
                              fontSize: 16,
                              fontFamily: 'RobotoMono',
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
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
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
