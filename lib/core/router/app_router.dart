import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:game_size_manager/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:game_size_manager/features/games/presentation/pages/games_page.dart';
import 'package:game_size_manager/features/games/presentation/pages/game_details_page.dart';
import 'package:game_size_manager/features/storage/presentation/pages/storage_page.dart';
import 'package:game_size_manager/features/settings/presentation/pages/settings_page.dart';
import 'package:game_size_manager/core/router/app_shell.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';

/// App navigation routes
class AppRoutes {
  static const dashboard = '/dashboard';
  static const games = '/games';
  static const gameDetails = 'details';
  static const storage = '/storage';
  static const settings = '/settings';
}

/// App router configuration using GoRouter
class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.games,
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (context, state) => const NoTransitionPage(child: DashboardPage()),
          ),
          GoRoute(
            path: AppRoutes.games,
            pageBuilder: (context, state) => const NoTransitionPage(child: GamesPage()),
            routes: [
              GoRoute(
                parentNavigatorKey: _rootNavigatorKey,
                path: AppRoutes.gameDetails,
                builder: (context, state) {
                  final game = state.extra as Game;
                  return GameDetailsPage(game: game);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.storage,
            pageBuilder: (context, state) => const NoTransitionPage(child: StoragePage()),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) => const NoTransitionPage(child: SettingsPage()),
          ),
        ],
      ),
    ],
  );
}
