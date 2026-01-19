import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:game_size_manager/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:game_size_manager/features/settings/presentation/widgets/switch_tile.dart';

/// Behavior settings card with toggle switches
class BehaviorCard extends StatelessWidget {
  const BehaviorCard({
    super.key,
    required this.confirmBeforeUninstall,
    required this.sortBySizeDescending,
  });

  final bool confirmBeforeUninstall;
  final bool sortBySizeDescending;

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
          SwitchTile(
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFF59E0B),
            title: 'Confirm before uninstall',
            subtitle: 'Show confirmation dialog before deleting games',
            value: confirmBeforeUninstall,
            onChanged: (_) => context.read<SettingsCubit>().toggleConfirmBeforeUninstall(),
          ),
          Divider(height: 1, indent: 72, color: theme.colorScheme.outline.withValues(alpha: 0.1)),
          SwitchTile(
            icon: Icons.sort_rounded,
            iconColor: theme.colorScheme.secondary,
            title: 'Sort largest first',
            subtitle: 'Show biggest games at the top of the list',
            value: sortBySizeDescending,
            onChanged: (_) => context.read<SettingsCubit>().toggleSortBySizeDescending(),
          ),
        ],
      ),
    );
  }
}
