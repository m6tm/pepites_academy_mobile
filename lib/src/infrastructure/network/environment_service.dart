import 'package:flutter/foundation.dart';

class EnvironmentService {
  static const String _devBaseUrl = 'http://192.168.1.198:5500/v1';
  static const String _prodBaseUrl = 'https://apipepites-academy.vercel.app/v1';

  static String get baseUrl => kReleaseMode ? _prodBaseUrl : _devBaseUrl;
}
