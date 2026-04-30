import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/timer_provider.dart';
import '../models/solve_record.dart';
import '../models/cmll_algs.dart';
import '../roux/scramble_isolate.dart';
import '../roux/solver.dart';
import '../roux/cube.dart';
import 'cmll_reference_screen.dart';
import 'demo_screen.dart';
import 'lse_reference_screen.dart';
import 'practice_screen.dart';
import 'teaching_screen.dart';

class TrainingScreen extends StatelessWidget {
  final VoidCallback onModeSelected;

  const TrainingScreen({super.key, required this.onModeSelected});

  Future<void> _startFullSolveDemo(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating full solve...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final result = await compute(generateFullRouxSolve, DateTime.now().millisecondsSinceEpoch);
      
      if (context.mounted) {
        Navigator.pop(context); // Remove loading dialog
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DemoScreen(
              title: 'Full Roux Solve',
              scramble: result.scramble,
              algorithm: result.algorithm,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate solve: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations(context.watch<TimerProvider>().settings.locale);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          l10n['trainingModes'],
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(l10n['practiceMode'], [
            Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.indigo.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.lightbulb, color: Colors.indigo),
                ),
                title: Text(
                  l10n['practiceTrainer'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  l10n['practiceTrainerSubtitle'],
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.white54,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PracticeScreen(
                        initialMode: TrainingMode.fb,
                      ),
                    ),
                  );
                },
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection('Learn', [
            Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.menu_book, color: Colors.purple),
                ),
                title: const Text(
                  'Teaching Mode',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Learn CMLL cases with 3D visualization',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.white54,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TeachingScreen(),
                    ),
                  );
                },
              ),
            ),
            Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.view_in_ar, color: Colors.amber),
                ),
                title: const Text(
                  'Demo Mode',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Step-by-step 3D algorithm playback',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.white54,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DemoScreen(
                        title: 'Example: FB Build',
                        scramble: "R2 U R U' R' U' R' U R'",
                        algorithm: "R U R' U' R' F R2 U' R' U' R U R' F'",
                      ),
                    ),
                  );
                },
              ),
            ),
            Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.model_training, color: Colors.redAccent),
                ),
                title: const Text(
                  'Full Roux Solve Demo',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Watch a complete end-to-end Roux solve',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.white54,
                ),
                onTap: () => _startFullSolveDemo(context),
              ),
            ),

          ]),
          const SizedBox(height: 24),
          _buildSection(l10n['timerModes'], [
            _ModeCard(
              title: l10n['standardRoux'],
              subtitle: l10n['standardRouxSubtitle'],
              icon: Icons.timer,
              color: Colors.blue,
              mode: TrainingMode.standard,
              onSelected: onModeSelected,
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection(l10n['blockBuilding'], [
            _ModeCard(
              title: l10n['firstBlockFb'],
              subtitle: l10n['firstBlockSubtitle'],
              icon: Icons.view_column,
              color: Colors.green,
              mode: TrainingMode.fb,
              onSelected: onModeSelected,
            ),
            _ModeCard(
              title: l10n['secondBlockSb'],
              subtitle: l10n['secondBlockSubtitle'],
              icon: Icons.view_column_outlined,
              color: Colors.teal,
              mode: TrainingMode.sb,
              onSelected: onModeSelected,
            ),
            _ModeCard(
              title: l10n['doubleBridge'],
              subtitle: l10n['doubleBridgeSubtitle'],
              icon: Icons.view_sidebar,
              color: Colors.cyan,
              mode: TrainingMode.doubleBridge,
              onSelected: onModeSelected,
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection('CMLL', [
            _ModeCard(
              title: l10n['cmllRandom'],
              subtitle: l10n['cmllRandomSubtitle'],
              icon: Icons.shuffle,
              color: Colors.orange,
              mode: TrainingMode.cmll,
              onSelected: onModeSelected,
            ),
            _buildCmllCategoryCard(context, onModeSelected, l10n.locale),
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.menu_book, color: Colors.orange),
              ),
              title: Text(
                l10n['cmllReference'],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                l10n['cmllReferenceSubtitle'],
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.white54),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CmllReferenceScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.linear_scale, color: Colors.purple),
              ),
              title: const Text(
                'LSE Reference',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'EO / LR / 4C algorithms',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.white54),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LseReferenceScreen(),
                  ),
                );
              },
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection('LSE', [
            _ModeCard(
              title: 'EOLR',
              subtitle: l10n['eolrSubtitle'],
              icon: Icons.sync_alt,
              color: Colors.purple,
              mode: TrainingMode.lseEOLR,
              onSelected: onModeSelected,
            ),
            _ModeCard(
              title: '4C',
              subtitle: l10n['fourCSubtitle'],
              icon: Icons.last_page,
              color: Colors.pink,
              mode: TrainingMode.lse4C,
              onSelected: onModeSelected,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildCmllCategoryCard(
    BuildContext context,
    VoidCallback onModeSelected,
    String locale,
  ) {
    final l10n = AppLocalizations(locale);
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.category, color: Colors.orange),
        ),
        title: Text(
          l10n['cmllByCategory'],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          l10n['cmllByCategorySubtitle'],
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        children: getCmllCategories().map((cat) {
          return ListTile(
            title: Text(
              '$cat (${getCmllByCategory(cat).length} ${l10n['cases']})',
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.play_arrow, color: Colors.green),
              onPressed: () {
                context.read<TimerProvider>().selectCmllCategory(cat);
                onModeSelected();
              },
            ),
            onTap: () => _showCmllCases(context, cat, onModeSelected, locale),
          );
        }).toList(),
      ),
    );
  }

  void _showCmllCases(
    BuildContext context,
    String category,
    VoidCallback onModeSelected,
    String locale,
  ) {
    final l10n = AppLocalizations(locale);
    final cases = getCmllByCategory(category);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.7,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '$category ${l10n['cases']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: cases.length,
                    itemBuilder: (context, index) {
                      final case_ = cases[index];
                      return ListTile(
                        title: Text(
                          case_.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          case_.alg,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.play_arrow,
                            color: Colors.green,
                          ),
                          onPressed: () {
                            final timer = context.read<TimerProvider>();
                            timer.selectCmllCase(case_);
                            Navigator.pop(context);
                            onModeSelected();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final TrainingMode mode;
  final VoidCallback onSelected;

  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.mode,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: () {
          context.read<TimerProvider>().setMode(mode);
          onSelected();
        },
      ),
    );
  }
}
