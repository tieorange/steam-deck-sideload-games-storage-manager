import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steam_deck_games_detector/steam_deck_games_detector.dart';

import 'package:game_size_manager/core/database/game_database.dart';
import 'package:game_size_manager/core/services/disk_size_service.dart';
import 'package:game_size_manager/core/services/update_service.dart';
import 'package:game_size_manager/core/platform/platform_service.dart';
import 'package:game_size_manager/features/games/data/datasources/game_local_datasource.dart';

import 'package:game_size_manager/features/games/data/repositories/game_repository_impl.dart';
import 'package:game_size_manager/features/games/data/repositories/mock_game_repository.dart';
import 'package:game_size_manager/features/games/domain/repositories/game_repository.dart';
import 'package:game_size_manager/features/games/domain/usecases/calculate_game_size_usecase.dart';
import 'package:game_size_manager/features/games/domain/usecases/get_all_games_usecase.dart';
import 'package:game_size_manager/features/games/domain/usecases/refresh_games_usecase.dart';
import 'package:game_size_manager/features/games/domain/usecases/search_games_usecase.dart';
import 'package:game_size_manager/features/games/domain/usecases/uninstall_game_usecase.dart';
import 'package:game_size_manager/features/games/presentation/cubit/games_cubit.dart';
import 'package:game_size_manager/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:game_size_manager/features/settings/domain/repositories/settings_repository.dart';
import 'package:game_size_manager/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:game_size_manager/features/settings/presentation/cubit/update_cubit.dart';
import 'package:game_size_manager/features/storage/presentation/cubit/storage_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton(() => http.Client(), dispose: (client) => client.close());
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Database
  sl.registerLazySingleton(() => GameDatabase.instance);

  // Services
  sl.registerLazySingleton(() => PlatformService.instance);
  sl.registerLazySingleton(() => DiskSizeService.instance);
  sl.registerLazySingleton(() => UpdateService(sl()));

  // Data Sources
  sl.registerLazySingleton<GameLocalDatasource>(
    () => GameLocalDatasourceImpl(sl()),
  ); // Register Local Datasource

  // Package: SteamDeckGamesDetector
  sl.registerLazySingleton(() => SteamDeckGamesDetector());

  // Repositories
  if (!PlatformService.instance.shouldUseMockData) {
    sl.registerLazySingleton<GameRepository>(
      () => GameRepositoryImpl(detector: sl(), diskSizeService: sl(), localDatasource: sl()),
    );
  } else {
    // Use Mock Repository for macOS development if not strictly testing full integration
    sl.registerLazySingleton<GameRepository>(() => MockGameRepository());
  }

  sl.registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl(sl()));

  // Use Cases
  sl.registerLazySingleton(() => GetAllGamesUsecase(sl()));
  sl.registerLazySingleton(() => RefreshGamesUsecase(sl()));
  sl.registerLazySingleton(() => CalculateGameSizeUsecase(sl()));
  sl.registerLazySingleton(() => UninstallGameUsecase(sl()));
  sl.registerLazySingleton(() => SearchGamesUsecase());

  // BloC / Cubit
  sl.registerFactory(
    () => GamesCubit(
      getAllGames: sl(),
      refreshGames: sl(),
      uninstallGame: sl(),
      calculateGameSize: sl(),
      searchGames: sl(),
    ),
  );

  sl.registerFactory(() => SettingsCubit(sl()));
  sl.registerFactory(() => UpdateCubit(sl()));

  sl.registerFactory(() => StorageCubit(sl(), sl()));
}
