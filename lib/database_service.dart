// database_service.dart
import 'package:mysql1/mysql1.dart';
import 'config_database.dart';

class DatabaseService {
  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Método para obter a conexão com o banco de dados
  Future<MySqlConnection> _getConnection() async {
    var settings = ConnectionSettings(
      host: dbHost,
      port: dbPort,
      user: dbUser,
      password: dbPassword,
      db: dbName,
    );
    return await MySqlConnection.connect(settings);
  }

  // Função para cadastrar um novo usuário
  Future<bool> cadastrarUsuario(String nome, String email, String senha) async {
    try {
      final conn = await _getConnection();
      var result = await conn.query(
        'INSERT INTO usuarios (nome, email, senha) VALUES (?, ?, ?)',
        [nome, email, senha],
      );
      await conn.close();
      return result.affectedRows == 1;
    } catch (e) {
      print('Erro ao cadastrar usuário: $e');
      return false;
    }
  }
}
