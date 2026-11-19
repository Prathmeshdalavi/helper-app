/// Domain-level error surfaced to the UI. Repositories translate transport
/// errors (DioException, API error envelope) into this type.
class AppException implements Exception {
  const AppException(this.code, this.message);

  /// Matches shared/contracts/error-codes.json, e.g. "VALIDATION_FAILED".
  final String code;
  final String message;

  @override
  String toString() => 'AppException($code): $message';
}
