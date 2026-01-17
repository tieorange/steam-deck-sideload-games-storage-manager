import 'package:dartz/dartz.dart';

/// Type alias for functional error handling
typedef Result<T> = Either<Failure, T>;

/// Base failure class
abstract class Failure {
  const Failure(this.message, [this.stackTrace]);
  
  final String message;
  final StackTrace? stackTrace;
  
  @override
  String toString() => '$runtimeType: $message';
}

/// File system related failures
class FileSystemFailure extends Failure {
  const FileSystemFailure(super.message, [super.stackTrace]);
}

/// Launcher not found or not installed
class LauncherNotFoundFailure extends Failure {
  const LauncherNotFoundFailure(super.message, [super.stackTrace]);
}

/// Game uninstall failed
class UninstallFailure extends Failure {
  const UninstallFailure(super.message, [super.stackTrace]);
}

/// Database related failures
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, [super.stackTrace]);
}

/// Parse errors
class ParseFailure extends Failure {
  const ParseFailure(super.message, [super.stackTrace]);
}

/// Generic unexpected failure
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message, [super.stackTrace]);
}
