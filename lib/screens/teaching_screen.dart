import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_settings.dart';
import '../models/cmll_algs.dart';
import '../models/fb_sb_algs.dart';
import '../providers/timer_provider.dart';
import '../roux/cube.dart';
import '../widgets/cube_3d.dart';
import 'demo_screen.dart';

/// Teaching mode screen: browse Roux formulas with 3D cube visualization.
/// Supports FB, SB, and CMLL steps.
class TeachingScreen extends StatefulWidget {
  const TeachingScreen({super.key});

  @override
  State<TeachingScreen> createState() => _TeachingScreenState();
}

class _TeachingScreenState extends State<TeachingScreen> {
  String _currentStep = 'CMLL'; // 'FB', 'SB', or 'CMLL'
  String? _selectedCategory;
  dynamic _selectedCase; // Can be CmllCase or RouxTeachingCase

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.watch<TimerProvider>().settings.colorScheme;
    
    List<String> categories;
    if (_currentStep == 'CMLL') {
      categories = getCmllCategories();
    } else {
      categories = getSubCategoriesByStep(_currentStep);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Teaching Mode',
          style: TextStyle(color: Colors.white),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['FB', 'SB', 'CMLL'].map((step) {
                final isSelected = _currentStep == step;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentStep = step;
                      _selectedCategory = null;
                      _selectedCase = null;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.orange : Colors.grey[900],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      step,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: Row(
        children: [
          // Left sidebar: category list
          SizedBox(
            width: 90,
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat;
                      _selectedCase = null;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.orange.withValues(alpha: 0.8)
                          : Colors.grey[900],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      cat,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Divider
          Container(width: 1, color: Colors.white.withValues(alpha: 0.1)),
          // Middle: case list
          if (_selectedCategory != null)
            SizedBox(
              width: 140,
              child: _buildCaseList(_selectedCategory!, colorScheme),
            )
          else
            const Expanded(
              child: Center(
                child: Text(
                  'Select a category',
                  style: TextStyle(color: Colors.white38),
                ),
              ),
            ),
          // Divider
          if (_selectedCategory != null)
            Container(width: 1, color: Colors.white.withValues(alpha: 0.1)),
          // Right: case detail with 3D cube
          if (_selectedCase != null)
            Expanded(child: _buildCaseDetail(_selectedCase!, colorScheme))
          else if (_selectedCategory != null)
            const Expanded(
              child: Center(
                child: Text(
                  'Select a case',
                  style: TextStyle(color: Colors.white38),
                ),
              ),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildCaseList(String category, CubeColorScheme colorScheme) {
    List<dynamic> cases;
    if (_currentStep == 'CMLL') {
      cases = getCmllByCategory(category);
    } else {
      cases = getTeachingCasesByStep(_currentStep)
          .where((c) => c.subCategory == category)
          .toList();
    }

    return ListView.builder(
      itemCount: cases.length,
      itemBuilder: (context, index) {
        final case_ = cases[index];
        final id = _currentStep == 'CMLL' ? (case_ as CmllCase).id : (case_ as RouxTeachingCase).id;
        final name = _currentStep == 'CMLL' ? (case_ as CmllCase).name : (case_ as RouxTeachingCase).name;
        final isSelected = (_currentStep == 'CMLL' && _selectedCase is CmllCase && _selectedCase.id == id) ||
                           (_currentStep != 'CMLL' && _selectedCase is RouxTeachingCase && _selectedCase.id == id);
        
        return ListTile(
          dense: true,
          title: Text(
            name,
            style: TextStyle(
              color: isSelected ? Colors.orange : Colors.white70,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          selected: isSelected,
          onTap: () => setState(() => _selectedCase = case_),
        );
      },
    );
  }

  Widget _buildCaseDetail(dynamic case_, CubeColorScheme colorScheme) {
    final String name = _currentStep == 'CMLL' ? (case_ as CmllCase).name : (case_ as RouxTeachingCase).name;
    final String category = _currentStep == 'CMLL' ? (case_ as CmllCase).category : (case_ as RouxTeachingCase).subCategory;
    final String id = _currentStep == 'CMLL' ? (case_ as CmllCase).id : (case_ as RouxTeachingCase).id;
    final String alg = _currentStep == 'CMLL' ? (case_ as CmllCase).alg : (case_ as RouxTeachingCase).alg;
    final String scramble = _currentStep == 'CMLL' 
        ? RouxMoveSeq.parse(alg).inverse().toString()
        : (case_ as RouxTeachingCase).scramble;
    
    final caseCube = RouxCube.solved().applyAlg(scramble);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Case name
          Text(
            '$category - $name',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            id,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 24),
          // 3D Cube showing the case state
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Cube3D.fromCube(
              caseCube,
              colorScheme: colorScheme,
              size: 220,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Setup: $scramble',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Algorithm
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
                const Text(
                  'Algorithm / Solution',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                SelectableText(
                  alg,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'RobotoMono',
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Demo button
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DemoScreen(
                    title: '$category - $name',
                    scramble: scramble,
                    algorithm: alg,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.play_circle_outline),
            label: const Text('Play Demo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

