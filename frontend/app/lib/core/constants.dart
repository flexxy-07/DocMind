import 'package:flutter/foundation.dart';

class AppConstants {
  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;

    if (kIsWeb) return 'http://localhost:8000';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000';
      case TargetPlatform.iOS:
        return 'http://127.0.0.1:8000';
      default:
        return 'http://localhost:8000';
    }
  }

  static String get ingestUrl   => '$baseUrl/ingest';
  static String get queryUrl    => '$baseUrl/query';
  static String get streamUrl   => '$baseUrl/query/stream';
  static String get multiUrl    => '$baseUrl/query/multi';
  static String get docsUrl     => '$baseUrl/history/docs';
  static String get sessionsUrl => '$baseUrl/history/sessions';
  static String get statsUrl    => '$baseUrl/history/stats';
  static String get healthUrl   => '$baseUrl/health';

  static const double maxFileSizeMB = 20.0;
  static const List<String> allowedExtensions = [
    'pdf', 'jpg', 'jpeg', 'png', 'webp', 'txt', 'md'
  ];

  static const Map<String, _CategoryMeta> categories = {
    'legal':      _CategoryMeta('Legal',      0xFF5B7CF7, '⚖️'),
    'health':     _CategoryMeta('Health',     0xFF2ECC71, '🏥'),
    'finance':    _CategoryMeta('Finance',    0xFFFFB347, '💰'),
    'education':  _CategoryMeta('Education',  0xFF4FC3F7, '📚'),
    'research':   _CategoryMeta('Research',   0xFFCE93D8, '🔬'),
    'hobbies':    _CategoryMeta('Hobbies',    0xFFFF7043, '🎯'),
    'technology': _CategoryMeta('Technology', 0xFF26C6DA, '⚙️'),
    'general':    _CategoryMeta('General',    0xFF9999BB, '📄'),
  };

  static _CategoryMeta categoryMeta(String category) {
    return categories[category] ?? categories['general']!;
  }
}

class _CategoryMeta {
  final String label;
  final int color;
  final String icon;
  const _CategoryMeta(this.label, this.color, this.icon);
}