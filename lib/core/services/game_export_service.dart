import 'dart:convert';
import 'dart:io';

import 'package:game_size_manager/core/extensions/size_formatter.dart';
import 'package:game_size_manager/core/logging/logger_service.dart';
import 'package:game_size_manager/core/theme/game_colors.dart';
import 'package:game_size_manager/features/games/domain/entities/game_entity.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

/// Service for importing and exporting game lists
class GameExportService {
  final _logger = LoggerService.instance;

  /// Export games to JSON
  Future<File> exportToJson(List<Game> games) async {
    final data = {
      'exported_at': DateTime.now().toIso8601String(),
      'game_count': games.length,
      'total_size_bytes': games.fold<int>(0, (sum, g) => sum + g.sizeBytes),
      'games': games.map((g) => {
        'id': g.id,
        'title': g.title,
        'source': g.source.name,
        'install_path': g.installPath,
        'size_bytes': g.sizeBytes,
        'size_human': g.sizeBytes.toHumanReadableSize(),
        'storage_location': g.storageLocation.name,
        'tag': g.tag?.name,
      }).toList(),
    };

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/game_library_$timestamp.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));

    _logger.info('Exported ${games.length} games to ${file.path}', tag: 'Export');
    return file;
  }

  /// Export games to CSV
  Future<File> exportToCsv(List<Game> games) async {
    final buffer = StringBuffer();
    buffer.writeln('Title,Source,Size (Bytes),Size (Human),Install Path,Storage Location,Tag');

    for (final game in games) {
      final title = game.title.contains(',') ? '"${game.title}"' : game.title;
      final path = game.installPath.contains(',') ? '"${game.installPath}"' : game.installPath;
      buffer.writeln(
        '$title,'
        '${GameColors.nameForSource(game.source)},'
        '${game.sizeBytes},'
        '${game.sizeBytes.toHumanReadableSize()},'
        '$path,'
        '${game.storageLocation.name},'
        '${game.tag?.name ?? ""}',
      );
    }

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/game_library_$timestamp.csv');
    await file.writeAsString(buffer.toString());

    _logger.info('Exported ${games.length} games to ${file.path}', tag: 'Export');
    return file;
  }
}
