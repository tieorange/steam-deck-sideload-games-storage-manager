#!/usr/bin/env dart

/// 🎮 Steam Deck Deploy & Debug CLI Tool
///
/// A beautiful CLI for deploying and debugging Flutter apps on Steam Deck.
///
/// Usage:
///   dart scripts/steamdeck_deploy.dart         # Interactive menu
///   dart scripts/steamdeck_deploy.dart deploy  # Direct command

import 'dart:io';
import 'dart:async';

// ═══════════════════════════════════════════════════════════════════════════
// CONFIGURATION - Edit these values for your setup
// ═══════════════════════════════════════════════════════════════════════════

class Config {
  static const host = 'steamdeck.local';
  static const user = 'deck';
  static const appDir = '~/Applications/GameSizeManager';
  static const appName = 'game_size_manager';
  static const localBuildDir = 'build/steam-deck-release';

  static String get ssh => '$user@$host';
  static String get sshKeyPath => '${Platform.environment['HOME']}/.ssh/steamdeck_rsa';
}

// ═══════════════════════════════════════════════════════════════════════════
// TERMINAL COLORS & STYLING
// ═══════════════════════════════════════════════════════════════════════════

class Style {
  // Colors
  static const reset = '\x1B[0m';
  static const bold = '\x1B[1m';
  static const dim = '\x1B[2m';

  static const red = '\x1B[31m';
  static const green = '\x1B[32m';
  static const yellow = '\x1B[33m';
  static const blue = '\x1B[34m';
  static const magenta = '\x1B[35m';
  static const cyan = '\x1B[36m';
  static const white = '\x1B[37m';

  static const bgBlue = '\x1B[44m';
  static const bgGreen = '\x1B[42m';
  static const bgRed = '\x1B[41m';

  // Styled text helpers
  static String success(String text) => '$green✓ $text$reset';
  static String error(String text) => '$red✗ $text$reset';
  static String warning(String text) => '$yellow⚠ $text$reset';
  static String info(String text) => '$blue→ $text$reset';
  static String step(String text) => '$cyan▶ $text$reset';
  static String header(String text) => '$bold$magenta$text$reset';
}

// ═══════════════════════════════════════════════════════════════════════════
// UI COMPONENTS
// ═══════════════════════════════════════════════════════════════════════════

class UI {
  static void banner() {
    print('''
${Style.cyan}
    ╔═══════════════════════════════════════════════════════════╗
    ║  ${Style.bold}🎮 Steam Deck Deploy Tool${Style.reset}${Style.cyan}                              ║
    ║  ${Style.dim}Fast iteration for Flutter desktop debugging${Style.reset}${Style.cyan}            ║
    ╚═══════════════════════════════════════════════════════════╝
${Style.reset}''');
  }

  static void menu() {
    print('''
  ${Style.bold}Commands:${Style.reset}

    ${Style.green}1${Style.reset}  ${Style.bold}setup${Style.reset}     Setup SSH keys ${Style.dim}(run once)${Style.reset}
    ${Style.green}2${Style.reset}  ${Style.bold}deploy${Style.reset}    Build & deploy to Steam Deck
    ${Style.green}3${Style.reset}  ${Style.bold}debug${Style.reset}     Build, deploy & run with live logs
    ${Style.green}4${Style.reset}  ${Style.bold}run${Style.reset}       Quick run ${Style.dim}(skip build, background)${Style.reset}
    ${Style.green}5${Style.reset}  ${Style.bold}debug-run${Style.reset} Quick debug ${Style.dim}(skip build, live logs)${Style.reset}
    ${Style.green}6${Style.reset}  ${Style.bold}logs${Style.reset}      Stream logs from Steam Deck
    ${Style.green}7${Style.reset}  ${Style.bold}shell${Style.reset}     SSH into Steam Deck

    ${Style.dim}q  exit${Style.reset}

''');
  }

  static void section(String title) {
    print('');
    print('  ${Style.bgBlue}${Style.white}${Style.bold} $title ${Style.reset}');
    print('');
  }

  static void box(String title, List<String> lines) {
    final maxLen = lines.fold(title.length, (max, line) => line.length > max ? line.length : max);
    final border = '─' * (maxLen + 2);

    print('  ${Style.dim}┌$border┐${Style.reset}');
    print(
      '  ${Style.dim}│${Style.reset} ${Style.bold}$title${Style.reset}${' ' * (maxLen - title.length)} ${Style.dim}│${Style.reset}',
    );
    print('  ${Style.dim}├$border┤${Style.reset}');
    for (final line in lines) {
      print(
        '  ${Style.dim}│${Style.reset} $line${' ' * (maxLen - _stripAnsi(line).length)} ${Style.dim}│${Style.reset}',
      );
    }
    print('  ${Style.dim}└$border┘${Style.reset}');
  }

  static Future<void> spinner(String message, Future<void> Function() action) async {
    final frames = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];
    var i = 0;
    var running = true;

    // Start spinner
    final timer = Timer.periodic(Duration(milliseconds: 80), (_) {
      if (running) {
        stdout.write('\r  ${Style.cyan}${frames[i++ % frames.length]}${Style.reset} $message');
      }
    });

    try {
      await action();
      running = false;
      timer.cancel();
      stdout.write('\r  ${Style.success(message)}${' ' * 10}\n');
    } catch (e) {
      running = false;
      timer.cancel();
      stdout.write('\r  ${Style.error(message)}${' ' * 10}\n');
      rethrow;
    }
  }

  static void progress(String message) {
    print('  ${Style.step(message)}');
  }

  static void success(String message) {
    print('  ${Style.success(message)}');
  }

  static void error(String message) {
    print('  ${Style.error(message)}');
  }

  static void warning(String message) {
    print('  ${Style.warning(message)}');
  }

  static void info(String message) {
    print('  ${Style.info(message)}');
  }

  static void dim(String message) {
    print('  ${Style.dim}$message${Style.reset}');
  }

  static String? prompt(String message) {
    stdout.write('  ${Style.yellow}?${Style.reset} $message ');
    return stdin.readLineSync();
  }

  static String _stripAnsi(String text) {
    return text.replaceAll(RegExp(r'\x1B\[[0-9;]*m'), '');
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MAIN ENTRY POINT
// ═══════════════════════════════════════════════════════════════════════════

void main(List<String> args) async {
  // Map number shortcuts to commands
  final shortcuts = {
    '1': 'setup',
    '2': 'deploy',
    '3': 'debug',
    '4': 'run',
    '5': 'debug-run',
    '6': 'logs',
    '7': 'shell',
    '8': 'hot-setup',
    '9': 'hot-start',
    '10': 'hot-attach',
  };

  if (args.isEmpty) {
    // Interactive mode
    UI.banner();
    UI.menu();

    final input = UI.prompt('Select command (1-6 or name):');
    if (input == null || input.isEmpty || input.toLowerCase() == 'q') {
      print('');
      exit(0);
    }

    final command = shortcuts[input] ?? input;
    await runCommand(command);
  } else {
    // Direct command mode
    final command = shortcuts[args.first] ?? args.first;
    await runCommand(command);
  }
}

Future<void> runCommand(String command) async {
  try {
    switch (command) {
      case 'setup':
        await cmdSetup();
      case 'deploy':
        await cmdDeploy(build: true);
      case 'debug':
        await cmdDeploy(build: true, run: true, debug: true);
      case 'run':
        await cmdDeploy(build: false, run: true);
      case 'debug-run':
        await cmdDeploy(build: false, run: true, debug: true);
      case 'logs':
        await cmdLogs();
      case 'shell':
        await cmdShell();
      case 'help':
      case '--help':
      case '-h':
        UI.banner();
        UI.menu();
      case 'hot-setup':
        await cmdHotSetup();
      case 'hot-start':
        await cmdHotStart();
      case 'hot-attach':
        await cmdHotAttach();
      default:
        UI.error('Unknown command: $command');
        print('');
        print(
          '  Run ${Style.bold}dart scripts/steamdeck_deploy.dart${Style.reset} to see available commands.',
        );
        exit(1);
    }
  } catch (e) {
    print('');
    UI.error('$e');
    exit(1);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// COMMANDS
// ═══════════════════════════════════════════════════════════════════════════

Future<void> cmdSetup() async {
  UI.section('SSH Key Setup');

  final keyFile = File(Config.sshKeyPath);
  final pubKeyFile = File('${Config.sshKeyPath}.pub');

  // Generate key if needed
  if (!keyFile.existsSync()) {
    await UI.spinner('Generating SSH key', () async {
      await shell('ssh-keygen', [
        '-t',
        'rsa',
        '-b',
        '4096',
        '-f',
        Config.sshKeyPath,
        '-N',
        '',
        '-C',
        'steamdeck-deploy',
      ]);
    });
  } else {
    UI.success('SSH key already exists');
  }
  UI.dim('Key location: ${Config.sshKeyPath}');

  // Copy to Steam Deck
  print('');
  UI.info('Copying key to Steam Deck...');
  UI.dim('You will be prompted for your Steam Deck password.');
  print('');

  final copyResult = await Process.run('ssh-copy-id', [
    '-i',
    pubKeyFile.path,
    Config.ssh,
  ], workingDirectory: projectDir);

  print(copyResult.stdout);
  if (copyResult.stderr.toString().isNotEmpty) {
    print(copyResult.stderr);
  }

  if (copyResult.exitCode != 0) {
    print('');
    UI.error('Failed to copy SSH key to Steam Deck');
    print('');
    UI.box('Troubleshooting', [
      '1. Is Steam Deck powered on?',
      '2. Is SSH enabled? (Gaming Mode → Settings → Developer)',
      '3. Are you on the same WiFi network?',
      '4. Try: ${Style.cyan}ping steamdeck.local${Style.reset}',
    ]);
    exit(1);
  }

  // Test connection
  print('');
  await UI.spinner('Testing connection', () async {
    final testResult = await sshExec('echo connected');
    if (testResult.exitCode != 0) {
      throw Exception('Connection test failed');
    }
  });

  print('');
  UI.box('Setup Complete! 🎉', [
    'SSH key configured for ${Style.cyan}${Config.ssh}${Style.reset}',
    '',
    'Next steps:',
    '  ${Style.green}make deck-deploy${Style.reset}',
    '  ${Style.green}make deck-debug${Style.reset}',
  ]);
  print('');
}

Future<void> cmdDeploy({bool build = false, bool run = false, bool debug = false}) async {
  final startTime = DateTime.now();

  UI.section(debug ? 'Debug Mode' : (build ? 'Build & Deploy' : 'Quick Run'));

  // Connection check
  await UI.spinner('Connecting to Steam Deck', () async {
    if (!await checkConnection()) {
      throw Exception('Cannot connect to ${Config.ssh}');
    }
  });

  // Build
  if (build) {
    print('');
    UI.progress('Building Linux release (Docker)...');
    UI.dim('This may take a minute on first run.');
    print('');

    await shell('./build_linux_docker.sh', [], workingDir: projectDir, showOutput: true);
    UI.success('Build complete');
  }

  // Check build exists
  final buildDir = Directory('$projectDir/${Config.localBuildDir}');
  if (!buildDir.existsSync()) {
    throw Exception('No build found. Run with deploy command first.');
  }

  // Deploy
  print('');
  await UI.spinner('Creating app directory', () async {
    await sshExec('mkdir -p ${Config.appDir}');
  });

  UI.progress('Syncing files to Steam Deck...');
  await shell('rsync', [
    '-avz',
    '--delete',
    '--progress',
    '-e',
    'ssh -i ${Config.sshKeyPath}',
    '${buildDir.path}/',
    '${Config.ssh}:${Config.appDir}/',
  ], showOutput: true);

  await sshExec('chmod +x ${Config.appDir}/${Config.appName}');
  UI.success('Deploy complete');

  // Run
  if (run) {
    // Kill existing and allow X display access
    await sshExec('pkill -f ${Config.appName} || true');

    // Try to enable X access (may fail if not in desktop session)
    await sshExec(
      'export DISPLAY=:0 && export XAUTHORITY=\$(ls /run/user/1000/.mutter-Xwaylandauth.* 2>/dev/null | head -1) && xhost + 2>/dev/null || true',
    );

    if (debug) {
      UI.progress('Starting app with live logs...');
      UI.dim('Press Ctrl+C to stop');
      UI.dim('Note: Make sure you are in Desktop Mode on Steam Deck');
      print('');
      print('  ${Style.dim}${'─' * 50}${Style.reset}');

      await shell('ssh', [
        '-i',
        Config.sshKeyPath,
        Config.ssh,
        '''
export DISPLAY=:0
export XAUTHORITY=\$(ls /run/user/1000/.mutter-Xwaylandauth.* 2>/dev/null | head -1 || echo /run/user/1000/xauth_*)
cd ${Config.appDir} && ./${Config.appName} 2>&1
''',
      ], interactive: true);
    } else {
      await UI.spinner('Starting app', () async {
        await sshExec('''
export DISPLAY=:0
export XAUTHORITY=\$(ls /run/user/1000/.mutter-Xwaylandauth.* 2>/dev/null | head -1 || echo /run/user/1000/xauth_*)
cd ${Config.appDir} && nohup ./${Config.appName} > /tmp/gsm.log 2>&1 &
''');
      });
      UI.dim('View logs: make deck-logs');
    }
  }

  // Summary
  final duration = DateTime.now().difference(startTime);
  print('');
  UI.box('Done! ⚡', [
    'Time: ${duration.inSeconds}s',
    'App:  ${Style.cyan}${Config.ssh}:${Config.appDir}${Style.reset}',
  ]);
  print('');
}

Future<void> cmdLogs() async {
  UI.section('Log Stream');
  UI.dim('Streaming from /tmp/gsm.log (Ctrl+C to stop)');
  print('');
  print('  ${Style.dim}${'─' * 50}${Style.reset}');

  await shell('ssh', [
    '-i',
    Config.sshKeyPath,
    Config.ssh,
    'tail -f /tmp/gsm.log 2>/dev/null || echo "No logs found. Is the app running?"',
  ], interactive: true);
}

Future<void> cmdShell() async {
  UI.section('SSH Shell');
  UI.info('Connecting to ${Config.ssh}...');
  print('');

  await shell('ssh', ['-i', Config.sshKeyPath, Config.ssh], interactive: true);
}

// ═══════════════════════════════════════════════════════════════════════════
// HOT RELOAD COMMANDS
// ═══════════════════════════════════════════════════════════════════════════

const hotReloadPort = 46567;

Future<void> cmdHotSetup() async {
  UI.section('Fast Iteration Setup');

  UI.progress('Building release version...');
  UI.dim('Note: True hot reload requires Flutter on Steam Deck.');
  UI.dim('This setup enables fast deploy + restart workflow instead.');
  print('');

  // Build release version using Docker
  await shell('./build_linux_docker.sh', [], workingDir: projectDir, showOutput: true);

  // Check connection
  await UI.spinner('Connecting to Steam Deck', () async {
    if (!await checkConnection()) {
      throw Exception('Cannot connect to ${Config.ssh}');
    }
  });

  // Deploy release build
  final buildDir = Directory('$projectDir/${Config.localBuildDir}');
  if (!buildDir.existsSync()) {
    throw Exception('Build failed - no artifacts found');
  }

  await UI.spinner('Creating app directory', () async {
    await sshExec('mkdir -p ${Config.appDir}');
  });

  UI.progress('Syncing build to Steam Deck...');
  await shell('rsync', [
    '-avz',
    '--delete',
    '--progress',
    '-e',
    'ssh -i ${Config.sshKeyPath}',
    '${buildDir.path}/',
    '${Config.ssh}:${Config.appDir}/',
  ], showOutput: true);

  await sshExec('chmod +x ${Config.appDir}/${Config.appName}');

  print('');
  UI.box('Ready for Fast Iteration! ⚡', [
    'Release build deployed to Steam Deck',
    '',
    'Workflow:',
    '  ${Style.green}Terminal 1:${Style.reset} make deck-hot-start  (keeps app running)',
    '  ${Style.green}Terminal 2:${Style.reset} make deck-hot-attach (rebuild + sync)',
    '',
    'After code changes, just run deck-hot-attach again!',
  ]);
  print('');
}

Future<void> cmdHotStart() async {
  UI.section('Hot Reload - Start App');

  // Kill existing
  await sshExec('pkill -f ${Config.appName} || true');

  UI.progress('Starting app on Steam Deck with hot reload enabled...');
  UI.dim('Keep this terminal running!');
  UI.dim('Open another terminal and run: make deck-hot-attach');
  print('');
  print('  ${Style.dim}${'─' * 50}${Style.reset}');

  // Start app with observatory port enabled for hot reload
  await shell('ssh', [
    '-i',
    Config.sshKeyPath,
    Config.ssh,
    '''
export DISPLAY=:0
export XAUTHORITY=\$(ls /run/user/1000/.mutter-Xwaylandauth.* 2>/dev/null | head -1 || echo /run/user/1000/xauth_*)
cd ${Config.appDir} && ./${Config.appName} 2>&1
''',
  ], interactive: true);
}

Future<void> cmdHotAttach() async {
  final startTime = DateTime.now();
  UI.section('Fast Rebuild & Deploy');

  // Build
  UI.progress('Building release...');
  await shell('./build_linux_docker.sh', [], workingDir: projectDir, showOutput: false);
  UI.success('Build complete');

  // Check connection
  await UI.spinner('Connecting', () async {
    if (!await checkConnection()) {
      throw Exception('Cannot connect to ${Config.ssh}');
    }
  });

  // Sync only changed files (rsync is very fast for this)
  final buildDir = Directory('$projectDir/${Config.localBuildDir}');
  UI.progress('Syncing changes...');
  await shell('rsync', [
    '-avz',
    '--delete',
    '-e',
    'ssh -i ${Config.sshKeyPath}',
    '${buildDir.path}/',
    '${Config.ssh}:${Config.appDir}/',
  ], showOutput: false);
  UI.success('Synced');

  // Kill and restart app
  UI.progress('Restarting app...');
  await sshExec('pkill -f ${Config.appName} || true');

  // Start app in background
  await sshExec('''
export DISPLAY=:0
export XAUTHORITY=\$(ls /run/user/1000/.mutter-Xwaylandauth.* 2>/dev/null | head -1 || echo /run/user/1000/xauth_*)
cd ${Config.appDir} && nohup ./${Config.appName} > /tmp/gsm.log 2>&1 &
''');

  final duration = DateTime.now().difference(startTime);
  print('');
  UI.box('Reloaded! ⚡ (${duration.inSeconds}s)', [
    'App restarted with your changes.',
    'View logs: ${Style.cyan}make deck-logs${Style.reset}',
  ]);
  print('');
}

// ═══════════════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════════════

String get projectDir {
  final scriptDir = File(Platform.script.toFilePath()).parent;
  return scriptDir.parent.path;
}

Future<bool> checkConnection() async {
  try {
    final result = await Process.run('ssh', [
      '-i',
      Config.sshKeyPath,
      '-o',
      'ConnectTimeout=5',
      Config.ssh,
      'echo ok',
    ], workingDirectory: projectDir).timeout(Duration(seconds: 10));
    return result.exitCode == 0;
  } catch (e) {
    return false;
  }
}

Future<ProcessResult> sshExec(String command) async {
  return Process.run('ssh', [
    '-i',
    Config.sshKeyPath,
    Config.ssh,
    command,
  ], workingDirectory: projectDir);
}

Future<void> shell(
  String executable,
  List<String> args, {
  String? workingDir,
  bool interactive = false,
  bool showOutput = false,
}) async {
  if (interactive || showOutput) {
    final process = await Process.start(
      executable,
      args,
      workingDirectory: workingDir ?? projectDir,
      mode: interactive ? ProcessStartMode.inheritStdio : ProcessStartMode.normal,
    );

    if (!interactive) {
      process.stdout.listen((data) => stdout.add(data));
      process.stderr.listen((data) => stderr.add(data));
    }

    final exitCode = await process.exitCode;
    if (exitCode != 0 && !interactive) {
      throw Exception('$executable exited with code $exitCode');
    }
  } else {
    final result = await Process.run(executable, args, workingDirectory: workingDir ?? projectDir);
    if (result.exitCode != 0) {
      throw Exception('$executable failed: ${result.stderr}');
    }
  }
}
