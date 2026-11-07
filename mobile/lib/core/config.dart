import 'package:flutter/foundation.dart';

/// Configuración de entorno. Sobrescribe con `--dart-define=API_URL=https://...`.
class AppConfig {
  static const _override = String.fromEnvironment('API_URL');

  static String get apiBase {
    if (_override.isNotEmpty) return _override;
    // En el emulador de Android, 10.0.2.2 es el localhost de la máquina anfitriona.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }
}
