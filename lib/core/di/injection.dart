import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:game_size_manager/core/platform/platform_service.dart';
import 'package:game_size_manager/core/services/disk_size_service.dart';
import 'package:game_size_manager/features/games/data/datasources/heroic_datasource.dart';
import 'package:game_size_manager/features/games/data/datasources/lutris_datasource.dart';
import 'package:game_size_manager/features/games/data/datasources/ogi_datasource.dart';
import 'package:game_size_manager/features/games/data/datasources/steam_datasource.dart';
import 'package:game_size_manager/features/games/data/repositories/game_repository_impl.dart';
import 'package:game_size_manager/features/games/data/repositories/mock_game_repository.dart';
import 'package:game_size_manager/features/games/domain/repositories/game_repository.dart';
import 'package:game_size_manager/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:game_size_manager/features/settings/domain/repositories/settings_repository.dart';

final getIt = GetIt.instance;

/// Configure dependency injection
Future<void> configureDependencies(SharedPreferences prefs) async {
  // Core services
  getIt.registerSingleton<PlatformService>(PlatformService.instance);
  getIt.registerSingleton<DiskSizeService>(DiskSizeService.instance);
  
  // SharedPreferences
  getIt.registerSingleton<SharedPreferences>(prefs);
  
  // Datasources
  getIt.registerLazySingleton<HeroicDatasource>(() => HeroicDatasource());
  getIt.registerLazySingleton<OgiDatasource>(() => OgiDatasource());
  getIt.registerLazySingleton<LutrisDatasource>(() => LutrisDatasource());
  getIt.registerLazySingleton<SteamDatasource>(() => SteamDatasource());
  
  // Repositories
  final platform = getIt<PlatformService>();
  
  // Use mock repository on macOS for development
  if (platform.shouldUseMockData) {
    getIt.registerLazySingleton<GameRepository>(() => MockGameRepository());
  } else {
    getIt.registerLazySingleton<GameRepository>(() => GameRepositoryImpl(
      heroicDatasource: getIt<HeroicDatasource>(),
      ogiDatasource: getIt<OgiDatasource>(),
      lutrisDatasource: getIt<LutrisDatasource>(),
      steamDatasource: getIt<SteamDatasource>(),
      diskSizeService: getIt<DiskSizeService>(),
    ));
  }
  
  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(getIt<SharedPreferences>()),
  );
  
  // Log platform info
  platform.logPlatformInfo();
}
