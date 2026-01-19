import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:game_size_manager/core/di/injection.dart';
import 'package:game_size_manager/core/logging/logger_service.dart';
import 'package:game_size_manager/core/platform/platform_service.dart';
import 'package:game_size_manager/core/router/app_router.dart';
import 'package:game_size_manager/core/theme/app_theme.dart';
import 'package:game_size_manager/features/games/presentation/cubit/games_cubit.dart';
import 'package:game_size_manager/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:game_size_manager/features/settings/presentation/cubit/settings_state.dart';
import 'package:game_size_manager/features/settings/presentation/cubit/update_cubit.dart';
import 'package:game_size_manager/features/settings/presentation/widgets/update_widgets.dart';
import 'package:game_size_manager/core/widgets/global_error_boundary.dart';

import 'dart:async';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize FFI for SQLite on desktop
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }

      // Initialize logging
      await LoggerService.instance.init();
      await PlatformService.instance.init();

      // Configure dependency injection
      await init();

      runApp(const GameSizeManagerApp());
    },
    (error, stack) {
      LoggerService.instance.error(
        'Uncaught Async Error',
        error: error,
        stackTrace: stack,
        tag: 'Main',
      );
    },
  );
}

class GameSizeManagerApp extends StatelessWidget {
  const GameSizeManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<GamesCubit>()),
        BlocProvider(create: (_) => sl<SettingsCubit>()..loadSettings()),
        BlocProvider(create: (_) => sl<UpdateCubit>()..checkForUpdates()),
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
            builder: (context, child) =>
                GlobalErrorBoundary(child: UpdateBanner(child: child ?? const SizedBox())),
          );
        },
      ),
    );
  }
}
