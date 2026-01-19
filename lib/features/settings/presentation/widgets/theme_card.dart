import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:game_size_manager/features/settings/presentation/cubit/settings_cubit.dart';

/// Theme selection card with system/light/dark buttons
class ThemeCard extends StatelessWidget {
  const ThemeCard({super.key, required this.currentMode});

  final ThemeMode currentMode;

  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Following system preference';
      case ThemeMode.light:
        return 'Always light';
      case ThemeMode.dark:
        return 'Always dark';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.brightness_6_rounded, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Theme', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        _getThemeModeName(currentMode),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                _ThemeButton(
                  icon: Icons.settings_suggest_rounded,
                  label: 'System',
                  mode: ThemeMode.system,
                  isSelected: currentMode == ThemeMode.system,
                ),
                const SizedBox(width: 12),
                _ThemeButton(
                  icon: Icons.light_mode_rounded,
                  label: 'Light',
                  mode: ThemeMode.light,
                  isSelected: currentMode == ThemeMode.light,
                ),
                const SizedBox(width: 12),
                _ThemeButton(
                  icon: Icons.dark_mode_rounded,
                  label: 'Dark',
                  mode: ThemeMode.dark,
                  isSelected: currentMode == ThemeMode.dark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeButton extends StatelessWidget {
  const _ThemeButton({
    required this.icon,
    required this.label,
    required this.mode,
    required this.isSelected,
  });

  final IconData icon;
  final String label;
  final ThemeMode mode;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Material(
        color: isSelected
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => context.read<SettingsCubit>().setThemeMode(mode),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: isSelected ? Border.all(color: theme.colorScheme.primary, width: 2) : null,
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
