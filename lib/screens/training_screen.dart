import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../models/solve_record.dart';
import '../models/cmll_algs.dart';
import 'cmll_reference_screen.dart';

class TrainingScreen extends StatelessWidget {
  final VoidCallback onModeSelected;

  const TrainingScreen({super.key, required this.onModeSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Training Modes',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('Timer Modes', [
            _ModeCard(
              title: 'Standard Roux',
              subtitle: 'Full solve with standard scramble',
              icon: Icons.timer,
              color: Colors.blue,
              mode: TrainingMode.standard,
              onSelected: onModeSelected,
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection('Block Building', [
            _ModeCard(
              title: 'First Block (FB)',
              subtitle: 'Practice FB recognition and execution',
              icon: Icons.view_column,
              color: Colors.green,
              mode: TrainingMode.fb,
              onSelected: onModeSelected,
            ),
            _ModeCard(
              title: 'Second Block (SB)',
              subtitle: 'Practice SB with partial solve',
              icon: Icons.view_column_outlined,
              color: Colors.teal,
              mode: TrainingMode.sb,
              onSelected: onModeSelected,
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection('CMLL', [
            _ModeCard(
              title: 'CMLL Random',
              subtitle: 'Random CMLL cases',
              icon: Icons.shuffle,
              color: Colors.orange,
              mode: TrainingMode.cmll,
              onSelected: onModeSelected,
            ),
            _buildCmllCategoryCard(context, onModeSelected),
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
              title: const Text(
                'CMLL Reference',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'View all CMLL algorithms',
                style: TextStyle(color: Colors.white54, fontSize: 13),
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
          ]),
          const SizedBox(height: 24),
          _buildSection('LSE', [
            _ModeCard(
              title: 'EOLR',
              subtitle: 'Edge Orientation + LR edges',
              icon: Icons.sync_alt,
              color: Colors.purple,
              mode: TrainingMode.lseEOLR,
              onSelected: onModeSelected,
            ),
            _ModeCard(
              title: '4C',
              subtitle: 'Last 4 corners (UL/UR edges)',
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
  ) {
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
        title: const Text(
          'CMLL by Category',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        subtitle: const Text(
          'Select specific CMLL categories',
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
        children: getCmllCategories().map((cat) {
          return ListTile(
            title: Text(
              '$cat (${getCmllByCategory(cat).length} cases)',
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.play_arrow, color: Colors.green),
              onPressed: () {
                context.read<TimerProvider>().selectCmllCategory(cat);
                onModeSelected();
              },
            ),
            onTap: () => _showCmllCases(context, cat, onModeSelected),
          );
        }).toList(),
      ),
    );
  }

  void _showCmllCases(
    BuildContext context,
    String category,
    VoidCallback onModeSelected,
  ) {
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
                    '$category Cases',
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
