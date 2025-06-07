import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
 static String get baseUrl => dotenv.env['BASE_URL'] ?? 'Default Base URL'; // Provide a fallback
  static String get baseAuthUrl => dotenv.env['BASE_AUTH_URL'] ?? 'Default Base Auth URL';
}
