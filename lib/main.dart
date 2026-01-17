import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:game_size_manager/core/di/injection.dart';
import 'package:game_size_manager/core/logging/logger_service.dart';
import 'package:game_size_manager/core/router/app_router.dart';
import 'package:game_size_manager/core/theme/app_theme.dart';
import 'package:game_size_manager/features/games/domain/repositories/game_repository.dart';
import 'package:game_size_manager/features/games/presentation/cubit/games_cubit.dart';
import 'package:game_size_manager/features/settings/domain/repositories/settings_repository.dart';
import 'package:game_size_manager/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:game_size_manager/features/settings/presentation/cubit/settings_state.dart';
import 'package:game_size_manager/features/settings/presentation/widgets/update_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize logging
  await LoggerService.instance.init();
  
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  // Configure dependency injection
  await configureDependencies(prefs);
  
  runApp(const GameSizeManagerApp());
}

class GameSizeManagerApp extends StatelessWidget {
  const GameSizeManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => GamesCubit(getIt<GameRepository>()),
        ),
        BlocProvider(
          create: (_) => SettingsCubit(getIt<SettingsRepository>())..loadSettings(),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final themeMode = state.maybeWhen(
            loaded: (settings) => settings.themeMode,
            orElse: () => ThemeMode.dark,
          );
          
          return MaterialApp.router(
            title: 'Game Size Manager',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            routerConfig: AppRouter.router,
            builder: (context, child) => UpdateBanner(child: child ?? const SizedBox()),
          );
        },
      ),
    );
  }
}
