import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:game_size_manager/core/theme/steam_deck_constants.dart';
import 'package:game_size_manager/core/widgets/animated_card.dart';
import 'package:game_size_manager/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:game_size_manager/features/settings/presentation/cubit/settings_state.dart';
import 'package:game_size_manager/features/settings/presentation/widgets/about_card.dart';
import 'package:game_size_manager/features/settings/presentation/widgets/behavior_card.dart';
import 'package:game_size_manager/features/settings/presentation/widgets/section_header.dart';
import 'package:game_size_manager/features/settings/presentation/widgets/theme_card.dart';

/// Settings page for app configuration with animations
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (message) => Center(child: Text('Error: $message')),
            loaded: (settings) => ListView(
              padding: const EdgeInsets.all(SteamDeckConstants.pagePadding),
              children: [
                // Theme Section
                AnimatedCard(
                  controller: _controller,
                  delay: 0.0,
                  slideOffset: const Offset(0.05, 0),
                  child: const SectionHeader(icon: Icons.palette_rounded, title: 'Appearance'),
                ),
                const SizedBox(height: 12),
                AnimatedCard(
                  controller: _controller,
                  delay: 0.1,
                  slideOffset: const Offset(0.05, 0),
                  child: ThemeCard(currentMode: settings.themeMode),
                ),

                const SizedBox(height: SteamDeckConstants.sectionGap),

                // Behavior Section
                AnimatedCard(
                  controller: _controller,
                  delay: 0.15,
                  slideOffset: const Offset(0.05, 0),
                  child: const SectionHeader(icon: Icons.tune_rounded, title: 'Behavior'),
                ),
                const SizedBox(height: 12),
                AnimatedCard(
                  controller: _controller,
                  delay: 0.2,
                  slideOffset: const Offset(0.05, 0),
                  child: BehaviorCard(
                    confirmBeforeUninstall: settings.confirmBeforeUninstall,
                    sortBySizeDescending: settings.sortBySizeDescending,
                  ),
                ),

                const SizedBox(height: SteamDeckConstants.sectionGap),

                // About Section
                AnimatedCard(
                  controller: _controller,
                  delay: 0.25,
                  slideOffset: const Offset(0.05, 0),
                  child: const SectionHeader(icon: Icons.info_rounded, title: 'About'),
                ),
                const SizedBox(height: 12),
                AnimatedCard(
                  controller: _controller,
                  delay: 0.3,
                  slideOffset: const Offset(0.05, 0),
                  child: const AboutCard(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
