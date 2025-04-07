import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static Future<void> load() async {
    await dotenv.load(fileName: ".env");
  }

  static String get dbHost => dotenv.env['DB_HOST']!;
  static int get dbPort => int.parse(dotenv.env['DB_PORT']!);
  static String get dbUser => dotenv.env['DB_USER']!;
  static String get dbPassword => dotenv.env['DB_PASSWORD']!;
  static String get dbName => dotenv.env['DB_NAME']!;
}
