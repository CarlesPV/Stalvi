/// Base class for all custom exceptions in the Stalvi application.
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() {
    final codeStr = code != null ? ' [$code]' : '';
    final detailsStr = details != null ? '\nDetails: $details' : '';
    return '$runtimeType$codeStr: $message$detailsStr';
  }
}

/// Exception thrown during database operations (e.g., query errors, decryption failures).
class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Exception thrown when data/input validation fails.
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Exception thrown during authentication or authorization processes.
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Exception thrown during network communication or API integrations (e.g., exchange rates).
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Exception thrown when a requested resource/record is not found.
class NotFoundException extends AppException {
  const NotFoundException({
    required super.message,
    super.code,
    super.details,
  });
}
