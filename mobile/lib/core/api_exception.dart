/// Error de la API con un mensaje listo para mostrar al usuario (RNF-25).
class ApiException implements Exception {
  ApiException(this.message, {this.status = 0});

  final String message;

  /// 0 = sin conexión; en otro caso, el código HTTP.
  final int status;

  bool get isUnauthorized => status == 401;
  bool get isConflict => status == 409;

  @override
  String toString() => message;
}
