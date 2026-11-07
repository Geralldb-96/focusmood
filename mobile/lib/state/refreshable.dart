/// Contrato de los controladores que cargan datos del usuario al iniciar sesión
/// y los descartan al cerrarla. `SessionController` solo conoce esta abstracción.
abstract interface class Refreshable {
  Future<void> load();
  void clear();
}
