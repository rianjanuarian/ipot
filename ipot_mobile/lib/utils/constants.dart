import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._();

  static String get baseUrl => dotenv.env['API_URL'] ?? "";

  static const String qrScheme = 'ipot';
  static const String qrTablePath = 'table';

  static const Duration pollInterval = Duration(seconds: 5);
}
