class ApiException implements Exception {
  const ApiException(
      this.message, {
        this.statusCode,
        this.errors,
      });

  final String message;
  final int? statusCode;
  final dynamic errors;

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException(
      super.message,
      );
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException(
      super.message,
      );
}

class ValidationException extends ApiException {
  const ValidationException(
      super.message, {
        super.errors,
      });
}

class ServerException extends ApiException {
  const ServerException(
      super.message, {
        super.statusCode,
      });
}