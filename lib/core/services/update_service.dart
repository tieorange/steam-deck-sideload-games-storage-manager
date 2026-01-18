import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:version/version.dart';
import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/core/logging/logger_service.dart';

class UpdateInfo {
  final bool hasUpdate;
  final String latestVersion;
  final String downloadUrl;
  final String changelog;

  UpdateInfo({
    required this.hasUpdate,
    required this.latestVersion,
    required this.downloadUrl,
    required this.changelog,
  });
}

class UpdateService {
  final http.Client _client;

  UpdateService(this._client);

  Future<UpdateInfo> checkForUpdates() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = Version.parse(packageInfo.version);

      final url = Uri.parse(
        'https://api.github.com/repos/${AppConstants.githubOwner}/${AppConstants.githubRepo}/releases/latest',
      );

      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final String tagName = json['tag_name'] as String;
        // Remove 'v' prefix if present
        final String versionStr = tagName.startsWith('v') ? tagName.substring(1) : tagName;
        final latestVersion = Version.parse(versionStr);

        if (latestVersion > currentVersion) {
          final List<dynamic> assets = json['assets'];
          final String? downloadUrl = assets.firstWhere(
            (asset) => (asset['name'] as String).endsWith('linux.zip'),
            orElse: () => null,
          )?['browser_download_url'];

          if (downloadUrl != null) {
            return UpdateInfo(
              hasUpdate: true,
              latestVersion: versionStr,
              downloadUrl: downloadUrl,
              changelog: json['body'] ?? '',
            );
          }
        }
      }
      return UpdateInfo(
        hasUpdate: false,
        latestVersion: currentVersion.toString(),
        downloadUrl: '',
        changelog: '',
      );
    } catch (e) {
      LoggerService.instance.error('Error checking for updates', error: e);
      // On error, assume no update to avoid blocking user
      return UpdateInfo(hasUpdate: false, latestVersion: '', downloadUrl: '', changelog: '');
    }
  }

  Future<File> downloadUpdate(String url, Function(double) onProgress) async {
    final request = http.Request('GET', Uri.parse(url));
    final response = await _client.send(request);

    if (response.statusCode != 200) {
      throw Exception('Failed to download update');
    }

    final contentLength = response.contentLength ?? 0;
    final tempDir = await getTemporaryDirectory();
    final file = File(path.join(tempDir.path, 'update.zip'));
    final sink = file.openWrite();

    int received = 0;
    await response.stream.listen((chunk) {
      sink.add(chunk);
      received += chunk.length;
      if (contentLength > 0) {
        onProgress(received / contentLength);
      }
    }).asFuture();

    await sink.close();
    return file;
  }

  Future<void> applyUpdate(File zipFile) async {
    final tempDir = await getTemporaryDirectory();
    final extractDir = Directory(path.join(tempDir.path, 'update_extracted'));

    // Clean previous extraction
    if (await extractDir.exists()) {
      await extractDir.delete(recursive: true);
    }
    await extractDir.create();

    // Decode zip
    // Note: 'archive' package decoding can be slow for large files on main thread.
    // For a smoother UI, this could be moved to an isolate.
    // But for simplicity, we do it here.
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        File(path.join(extractDir.path, filename))
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory(path.join(extractDir.path, filename)).createSync(recursive: true);
      }
    }

    // Locate the inner bundle content
    // Typically the zip might contain a folder like 'steam-deck-release' or just the files.
    // We look for 'game_size_manager' executable.
    Directory sourceDir = extractDir;
    final nestedDir = Directory(path.join(extractDir.path, 'steam-deck-release'));
    if (await nestedDir.exists()) {
      sourceDir = nestedDir;
    }

    // Now execute the shell script to swap directories and restart
    // We assume the app is installed in ~/Applications/GameSizeManager
    // or wherever the current executable is running from.
    final executablePath = Platform.resolvedExecutable;
    final currentAppDir = File(executablePath).parent.path;
    final executableName = path.basename(executablePath);

    final scriptPath = path.join(tempDir.path, 'update_helper.sh');
    final scriptContent =
        '''
#!/bin/bash
PID=$pid
NEW_DIR="${sourceDir.path}"
TARGET_DIR="$currentAppDir"
EXECUTABLE_NAME="$executableName"

# Wait for app to exit
while kill -0 \$PID 2>/dev/null; do sleep 0.5; done

# Replace
rm -rf "\$TARGET_DIR"/*
cp -r "\$NEW_DIR"/* "\$TARGET_DIR"

# Cleanup
rm -rf "\$NEW_DIR"
rm "\$0"

# Restart
nohup "\$TARGET_DIR/\$EXECUTABLE_NAME" > /dev/null 2>&1 &
''';

    final scriptFile = File(scriptPath);
    await scriptFile.writeAsString(scriptContent);

    // chmod +x
    await Process.run('chmod', ['+x', scriptPath]);

    // Run detached
    await Process.start(scriptPath, [], mode: ProcessStartMode.detached);

    // Exit app
    exit(0);
  }
}
