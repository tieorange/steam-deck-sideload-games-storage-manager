#!/usr/bin/env dart

/// 🎮 Steam Deck Deploy & Debug CLI Tool
///
/// A beautiful CLI for deploying and debugging Flutter apps on Steam Deck.
///
/// Usage:
///   dart scripts/deck.dart         # Interactive menu
///   dart scripts/deck.dart deploy  # Direct command

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
    ${Style.green}4${Style.reset}  ${Style.bold}run${Style.reset}       Quick run ${Style.dim}(skip build)${Style.reset}
    ${Style.green}5${Style.reset}  ${Style.bold}logs${Style.reset}      Stream logs from Steam Deck
    ${Style.green}6${Style.reset}  ${Style.bold}shell${Style.reset}     SSH into Steam Deck

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
    '5': 'logs',
    '6': 'shell',
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
      case 'logs':
        await cmdLogs();
      case 'shell':
        await cmdShell();
      case 'help':
      case '--help':
      case '-h':
        UI.banner();
        UI.menu();
      default:
        UI.error('Unknown command: $command');
        print('');
        print('  Run ${Style.bold}dart scripts/deck.dart${Style.reset} to see available commands.');
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

  await shell('ssh-copy-id', ['-i', pubKeyFile.path, Config.ssh], interactive: true);

  // Test connection
  print('');
  await UI.spinner('Testing connection', () async {
    await sshExec('echo connected');
  });

  print('');
  UI.box('Setup Complete! 🎉', [
    'SSH key configured for ${Style.cyan}${Config.ssh}${Style.reset}',
    '',
    'Next steps:',
    '  ${Style.green}dart scripts/deck.dart deploy${Style.reset}',
    '  ${Style.green}dart scripts/deck.dart debug${Style.reset}',
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
    '--info=progress2',
    '-e',
    'ssh -i ${Config.sshKeyPath}',
    '${buildDir.path}/',
    '${Config.ssh}:${Config.appDir}/',
  ], showOutput: true);

  await sshExec('chmod +x ${Config.appDir}/${Config.appName}');
  UI.success('Deploy complete');

  // Run
  if (run) {
    print('');
    await sshExec('pkill -f ${Config.appName} || true');

    if (debug) {
      UI.progress('Starting app with live logs...');
      UI.dim('Press Ctrl+C to stop');
      print('');
      print('  ${Style.dim}${'─' * 50}${Style.reset}');

      await shell('ssh', [
        '-i',
        Config.sshKeyPath,
        Config.ssh,
        'cd ${Config.appDir} && DISPLAY=:0 ./${Config.appName} 2>&1',
      ], interactive: true);
    } else {
      await UI.spinner('Starting app', () async {
        await sshExec(
          'cd ${Config.appDir} && DISPLAY=:0 nohup ./${Config.appName} > /tmp/gsm.log 2>&1 &',
        );
      });
      UI.dim('View logs: dart scripts/deck.dart logs');
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
