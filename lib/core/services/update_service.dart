import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:game_size_manager/core/constants.dart';
import 'package:game_size_manager/core/logging/logger_service.dart';

/// Service for checking and managing app updates
class UpdateService {
  UpdateService._();
  static final UpdateService instance = UpdateService._();
  
  final _logger = LoggerService.instance;
  
  /// Current app version
  static const String currentVersion = '1.0.0';
  
  /// Check for updates from GitHub releases
  Future<UpdateStatus> checkForUpdate() async {
    try {
      _logger.info('Checking for updates...', tag: 'Update');
      
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/${AppConstants.githubOwner}/${AppConstants.githubRepo}/releases/latest'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final latestVersion = (data['tag_name'] as String?)?.replaceFirst('v', '') ?? currentVersion;
        final releaseNotes = data['body'] as String? ?? '';
        final downloadUrl = _getDownloadUrl(data);
        
        final isNewer = _isNewerVersion(latestVersion, currentVersion);
        
        _logger.info('Latest version: $latestVersion, Current: $currentVersion, Newer: $isNewer', tag: 'Update');
        
        return UpdateStatus(
          currentVersion: currentVersion,
          latestVersion: latestVersion,
          isUpdateAvailable: isNewer,
          releaseNotes: releaseNotes,
          downloadUrl: downloadUrl,
        );
      } else {
        _logger.warning('Failed to check for updates: ${response.statusCode}', tag: 'Update');
        return UpdateStatus.noUpdate(currentVersion);
      }
    } catch (e, s) {
      _logger.error('Error checking for updates', error: e, stackTrace: s, tag: 'Update');
      return UpdateStatus.error(currentVersion, e.toString());
    }
  }
  
  /// Extract download URL for Linux AppImage from release assets
  String? _getDownloadUrl(Map<String, dynamic> releaseData) {
    final assets = releaseData['assets'] as List<dynamic>? ?? [];
    
    for (final asset in assets) {
      final name = asset['name'] as String? ?? '';
      if (name.endsWith('.AppImage') || name.endsWith('.tar.gz')) {
        return asset['browser_download_url'] as String?;
      }
    }
    
    return releaseData['html_url'] as String?; // Fallback to release page
  }
  
  /// Compare semantic versions
  bool _isNewerVersion(String latest, String current) {
    try {
      final latestParts = latest.split('.').map(int.parse).toList();
      final currentParts = current.split('.').map(int.parse).toList();
      
      for (int i = 0; i < 3; i++) {
        final l = i < latestParts.length ? latestParts[i] : 0;
        final c = i < currentParts.length ? currentParts[i] : 0;
        
        if (l > c) return true;
        if (l < c) return false;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
}

/// Status of update check
class UpdateStatus {
  const UpdateStatus({
    required this.currentVersion,
    required this.latestVersion,
    required this.isUpdateAvailable,
    this.releaseNotes = '',
    this.downloadUrl,
    this.error,
  });
  
  factory UpdateStatus.noUpdate(String version) => UpdateStatus(
    currentVersion: version,
    latestVersion: version,
    isUpdateAvailable: false,
  );
  
  factory UpdateStatus.error(String version, String error) => UpdateStatus(
    currentVersion: version,
    latestVersion: version,
    isUpdateAvailable: false,
    error: error,
  );
  
  final String currentVersion;
  final String latestVersion;
  final bool isUpdateAvailable;
  final String releaseNotes;
  final String? downloadUrl;
  final String? error;
  
  bool get hasError => error != null;
}
