import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/app_settings.dart';
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
            title: Text(
              AppLocalizations(timer.settings.locale)['settings'],
              style: const TextStyle(color: Colors.white),
            ),
          ),
          body: ListView(
            children: [
              _buildSection(AppLocalizations(timer.settings.locale)['timerSettings']),
              _buildSwitchTile(
                AppLocalizations(timer.settings.locale)['holdToStartTimer'],
                settings.holdToStart,
                (value) =>
                    timer.updateSettings(settings.copyWith(holdToStart: value)),
              ),
              _buildSwitchTile(
                AppLocalizations(timer.settings.locale)['startCueSound'],
                settings.startCue,
                (value) =>
                    timer.updateSettings(settings.copyWith(startCue: value)),
              ),
              _buildSliderTile(
                AppLocalizations(timer.settings.locale)['inspectionTime'],
                settings.inspectionSeconds.toDouble(),
                0,
                30,
                AppLocalizations(timer.settings.locale)['seconds'],
                (value) => timer.updateSettings(
                  settings.copyWith(inspectionSeconds: value.round()),
                ),
              ),
              const Divider(color: Colors.white12),
              _buildSection(AppLocalizations(timer.settings.locale)['scrambleLength']),
              _buildSliderTile(
                AppLocalizations(timer.settings.locale)['standard'],
                settings.standardScrambleLength.toDouble(),
                15,
                30,
                AppLocalizations(timer.settings.locale)['moves'],
                (value) => timer.updateSettings(
                  settings.copyWith(standardScrambleLength: value.round()),
                ),
              ),
              _buildSliderTile(
                AppLocalizations(timer.settings.locale)['rouxMethod'],
                settings.rouxScrambleLength.toDouble(),
                15,
                30,
                AppLocalizations(timer.settings.locale)['moves'],
                (value) => timer.updateSettings(
                  settings.copyWith(rouxScrambleLength: value.round()),
                ),
              ),
              _buildSliderTile(
                'LSE',
                settings.lseScrambleLength.toDouble(),
                8,
                20,
                AppLocalizations(timer.settings.locale)['moves'],
                (value) => timer.updateSettings(
                  settings.copyWith(lseScrambleLength: value.round()),
                ),
              ),
              const Divider(color: Colors.white12),
              _buildSection(AppLocalizations(timer.settings.locale)['appearance']),
              _buildLanguageTile(context, settings, timer),
              _buildColorSchemeTile(context, settings, timer),
              _buildSwitchTile(
                AppLocalizations(timer.settings.locale)['darkTheme'],
                settings.darkTheme,
                (value) =>
                    timer.updateSettings(settings.copyWith(darkTheme: value)),
              ),
              _buildSliderTile(
                AppLocalizations(timer.settings.locale)['timerFontScale'],
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

  Widget _buildLanguageTile(
    BuildContext context,
    AppSettings settings,
    TimerProvider timer,
  ) {
    final l10n = AppLocalizations(settings.locale);
    return ListTile(
      title: Text(l10n['language'], style: const TextStyle(color: Colors.white)),
      subtitle: Text(
        settings.locale == 'zh' ? l10n['chinese'] : l10n['english'],
        style: const TextStyle(color: Colors.white54),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: () => _showLanguagePicker(context, settings, timer),
    );
  }

  void _showLanguagePicker(
    BuildContext context,
    AppSettings settings,
    TimerProvider timer,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  AppLocalizations(settings.locale)['language'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: const Text('English', style: TextStyle(color: Colors.white)),
                trailing: settings.locale == 'en'
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () {
                  timer.updateSettings(settings.copyWith(locale: 'en'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('中文', style: TextStyle(color: Colors.white)),
                trailing: settings.locale == 'zh'
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () {
                  timer.updateSettings(settings.copyWith(locale: 'zh'));
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildColorSchemeTile(
    BuildContext context,
    AppSettings settings,
    TimerProvider timer,
  ) {
    final l10n = AppLocalizations(settings.locale);
    return ListTile(
      title: Text(l10n['cubeColorScheme'], style: const TextStyle(color: Colors.white)),
      subtitle: Text(
        settings.colorScheme.name,
        style: const TextStyle(color: Colors.white54),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final c in [settings.colorScheme.u, settings.colorScheme.f, settings.colorScheme.r])
            Container(
              width: 16,
              height: 16,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: Colors.white24),
              ),
            ),
          const Icon(Icons.chevron_right, color: Colors.white54),
        ],
      ),
      onTap: () => _showColorSchemePicker(context, settings, timer),
    );
  }

  void _showColorSchemePicker(
    BuildContext context,
    AppSettings settings,
    TimerProvider timer,
  ) {
    final l10n = AppLocalizations(settings.locale);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n['cubeColorScheme'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...CubeColorScheme.all.map((scheme) {
                final isSelected = scheme.name == settings.colorSchemeName;
                return ListTile(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final c in [scheme.u, scheme.d, scheme.f, scheme.b, scheme.r, scheme.l])
                        Container(
                          width: 18,
                          height: 18,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: c,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: Colors.white24),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    scheme.name,
                    style: TextStyle(
                      color: isSelected ? Colors.green : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  onTap: () {
                    timer.updateSettings(
                      settings.copyWith(colorSchemeName: scheme.name),
                    );
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white70)),
      trailing: Text(value, style: const TextStyle(color: Colors.white54)),
    );
  }
}
