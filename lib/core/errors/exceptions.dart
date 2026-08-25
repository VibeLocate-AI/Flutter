class ApiException implements Exception {
  const ApiException(
      this.message, {
        this.statusCode,
      });

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  const NetworkException(this.message);

  final String message;

  @override
  String toString() => message;
}

class UnauthorizedException
    extends ApiException {
  const UnauthorizedException(
      super.message,
      );
}

class ValidationException
    extends ApiException {
  const ValidationException(
      super.message, {
        this.errors,
      });

  final dynamic errors;
}

class ServerException
    extends ApiException {
  const ServerException(
      super.message, {
        super.statusCode,
      });
}