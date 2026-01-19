import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:game_size_manager/core/di/injection.dart';
import 'package:game_size_manager/core/theme/steam_deck_constants.dart';
import 'package:game_size_manager/core/widgets/animated_card.dart';
import 'package:game_size_manager/features/storage/presentation/cubit/storage_cubit.dart';
import 'package:game_size_manager/features/storage/presentation/cubit/storage_state.dart';
import 'package:game_size_manager/features/storage/presentation/widgets/drive_info_card.dart';
import 'package:game_size_manager/features/storage/presentation/widgets/storage_overview_card.dart';

/// Storage page showing disk usage details
class StoragePage extends StatelessWidget {
  const StoragePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StorageCubit>()..loadStorageInfo(),
      child: const StorageView(),
    );
  }
}

class StorageView extends StatefulWidget {
  const StorageView({super.key});

  @override
  State<StorageView> createState() => _StorageViewState();
}

class _StorageViewState extends State<StorageView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<StorageCubit>().loadStorageInfo(),
          ),
        ],
      ),
      body: BlocBuilder<StorageCubit, StorageState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (msg) => Center(child: Text('Error: $msg')),
            loaded: (total, used, free, drives) => ListView(
              padding: const EdgeInsets.all(SteamDeckConstants.pagePadding),
              children: [
                StorageOverviewCard(
                  controller: _controller,
                  totalBytes: total,
                  usedBytes: used,
                  freeBytes: free,
                ),
                const SizedBox(height: 24),
                Text(
                  'Drives',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                ...drives.asMap().entries.map((entry) {
                  return AnimatedCard(
                    controller: _controller,
                    delay: 0.1 * (entry.key + 1),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DriveInfoCard(drive: entry.value),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
