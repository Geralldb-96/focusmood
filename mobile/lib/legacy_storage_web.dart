import 'package:web/web.dart' as web;

String? readLegacy(String key) => web.window.localStorage.getItem(key);

void clearLegacy() {
  for (final key in [
    'user',
    'habits',
    'sessions',
    'record',
    'reminders',
    'bookmark',
    'notifications',
    'personalization',
    'feedback',
    'dark',
  ]) {
    web.window.localStorage.removeItem('mood-$key');
  }
}
