import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timer, child) {
        final settings = timer.settings;
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            title: const Text(
              'Settings',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: ListView(
            children: [
              _buildSection('Timer'),
              _buildSwitchTile(
                'Hold to start',
                settings.holdToStart,
                (value) =>
                    timer.updateSettings(settings.copyWith(holdToStart: value)),
              ),
              _buildSwitchTile(
                'Start cue (vibration)',
                settings.startCue,
                (value) =>
                    timer.updateSettings(settings.copyWith(startCue: value)),
              ),
              _buildSliderTile(
                'Inspection time',
                settings.inspectionSeconds.toDouble(),
                0,
                30,
                'seconds',
                (value) => timer.updateSettings(
                  settings.copyWith(inspectionSeconds: value.round()),
                ),
              ),
              const Divider(color: Colors.white12),
              _buildSection('Scramble'),
              _buildSliderTile(
                'Standard length',
                settings.standardScrambleLength.toDouble(),
                15,
                30,
                'moves',
                (value) => timer.updateSettings(
                  settings.copyWith(standardScrambleLength: value.round()),
                ),
              ),
              _buildSliderTile(
                'Roux length',
                settings.rouxScrambleLength.toDouble(),
                15,
                30,
                'moves',
                (value) => timer.updateSettings(
                  settings.copyWith(rouxScrambleLength: value.round()),
                ),
              ),
              _buildSliderTile(
                'LSE length',
                settings.lseScrambleLength.toDouble(),
                8,
                20,
                'moves',
                (value) => timer.updateSettings(
                  settings.copyWith(lseScrambleLength: value.round()),
                ),
              ),
              const Divider(color: Colors.white12),
              _buildSection('Appearance'),
              _buildSwitchTile(
                'Dark theme',
                settings.darkTheme,
                (value) =>
                    timer.updateSettings(settings.copyWith(darkTheme: value)),
              ),
              _buildSliderTile(
                'Timer font size',
                settings.timerFontScale,
                0.75,
                1.25,
                'x',
                (value) => timer.updateSettings(
                  settings.copyWith(timerFontScale: value),
                ),
                divisions: 10,
              ),
              const Divider(color: Colors.white12),
              _buildSection('About'),
              _buildInfoTile('App', 'Roux Trainer'),
              _buildInfoTile('Version', '1.0.0'),
              _buildInfoTile('Inspired by', 'Dctimer & roux-trainers'),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title, style: const TextStyle(color: Colors.white)),
      activeThumbColor: Colors.green,
    );
  }

  Widget _buildSliderTile(
    String title,
    double value,
    double min,
    double max,
    String unit,
    ValueChanged<double> onChanged, {
    int? divisions,
  }) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions ?? (max - min).toInt(),
        onChanged: onChanged,
        activeColor: Colors.green,
      ),
      trailing: Text(
        unit == 'x' ? '${value.toStringAsFixed(2)}x' : '${value.toInt()} $unit',
        style: const TextStyle(color: Colors.white54),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white70)),
      trailing: Text(value, style: const TextStyle(color: Colors.white54)),
    );
  }
}
