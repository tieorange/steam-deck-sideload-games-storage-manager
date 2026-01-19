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
          final String assetName = Platform.isMacOS ? 'macos.zip' : 'linux.zip';
          final String? downloadUrl = assets.firstWhere(
            (asset) => (asset['name'] as String).toLowerCase().endsWith(assetName),
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

    // Determine Source and Target Paths
    String sourcePath = extractDir.path;
    String targetPath;
    String executableName;

    if (Platform.isMacOS) {
      // MacOS: Target is the .app bundle
      // Executable: .../GameSizeManager.app/Contents/MacOS/game_size_manager
      // We want to replace .../GameSizeManager.app

      // Target: Go up 3 levels from executable
      // executable -> MacOS -> Contents -> .app
      final executablePath = Platform.resolvedExecutable;
      targetPath = File(executablePath).parent.parent.parent.path;

      // Source: Find .app in extracted files
      // Zip might contain "macos/GameSizeManager.app" or just "GameSizeManager.app"
      final entries = extractDir.listSync(recursive: true);
      final appBundle = entries.firstWhere(
        (e) => e.path.endsWith('.app') && e is Directory,
        orElse: () => extractDir, // Fallback (dangerous?)
      );
      sourcePath = appBundle.path;

      // Determine app name for 'open' command
      executableName = path.basename(targetPath); // e.g., app_name.app
    } else {
      // Linux: Target is the directory containing the executable
      final executablePath = Platform.resolvedExecutable;
      targetPath = File(executablePath).parent.path;
      executableName = path.basename(executablePath);

      // Source: Look for inner folder (e.g. steam-deck-release) or use root
      final nestedDir = Directory(path.join(extractDir.path, 'steam-deck-release'));
      if (await nestedDir.exists()) {
        sourcePath = nestedDir.path;
      }
    }

    final scriptPath = path.join(tempDir.path, 'update_helper.sh');

    // Script Content
    String scriptContent;

    if (Platform.isMacOS) {
      scriptContent =
          '''
#!/bin/bash
PID=$pid
SOURCE="$sourcePath"
TARGET="$targetPath"
APP_NAME="$executableName"

# Wait for exit
while kill -0 \$PID 2>/dev/null; do sleep 0.5; done

# Remove old app and copy new one
rm -rf "\$TARGET"
cp -R "\$SOURCE" "\$TARGET"

# Remove quarantine (fix for "damaged" or secinit crash)
xattr -cr "\$TARGET"

# Cleanup
rm -rf "\$SOURCE"
rm "\$0"

# Relaunch
open "\$TARGET"
''';
    } else {
      // Linux Logic
      scriptContent =
          '''
#!/bin/bash
PID=$pid
SOURCE="$sourcePath"
TARGET="$targetPath"
EXECUTABLE="$executableName"

# Wait for exit
while kill -0 \$PID 2>/dev/null; do sleep 0.5; done

# Replace content
rm -rf "\$TARGET"/*
cp -r "\$SOURCE"/* "\$TARGET"

# Cleanup
rm -rf "\$SOURCE"
rm "\$0"

# Relaunch
nohup "\$TARGET/\$EXECUTABLE" > /dev/null 2>&1 &
''';
    }

    final scriptFile = File(scriptPath);
    await scriptFile.writeAsString(scriptContent);

    // chmod +x (optional if running with bash, but good practice)
    try {
      await Process.run('chmod', ['+x', scriptPath]);
    } catch (e) {
      LoggerService.instance.warning('Failed to chmod update script: $e');
    }

    // Run detached via bash to avoid permission issues
    if (Platform.isMacOS || Platform.isLinux) {
      await Process.start('/bin/bash', [scriptPath], mode: ProcessStartMode.detached);
    } else {
      await Process.start(scriptPath, [], mode: ProcessStartMode.detached);
    }

    // Exit app
    exit(0);
  }
}
