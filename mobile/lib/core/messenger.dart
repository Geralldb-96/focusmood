import 'package:flutter/material.dart';

/// Permite mostrar avisos (SnackBar) desde cualquier parte sin depender de un BuildContext.
final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();

void toast(String message) {
  final m = messengerKey.currentState;
  if (m == null) return;
  m.hideCurrentSnackBar();
  m.showSnackBar(
    SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
  );
}
