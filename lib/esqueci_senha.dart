import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:flutter_pim/config.dart'; // Importar o config.dart

class EsqueciSenha extends StatefulWidget {
  const EsqueciSenha({super.key});

  @override
  _EsqueciSenhaState createState() => _EsqueciSenhaState();
}

class _EsqueciSenhaState extends State<EsqueciSenha> {
  final TextEditingController _controllerEmail = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeConfig(); // Carregar as variáveis de ambiente
  }

  Future<void> _initializeConfig() async {
    await Config.load(); // Carrega o .env
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _hideLoading() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> _enviarEmailRecuperacao() async {
    String email = _controllerEmail.text.trim();
    if (email.isEmpty) {
      _showErrorDialog('Por favor, insira o e-mail.');
      return;
    }

    if (!_isValidEmail(email)) {
      _showErrorDialog('Por favor, insira um e-mail válido.');
      return;
    }

    // Configurações de conexão usando variáveis de ambiente
    final settings = ConnectionSettings(
      host: Config.dbHost,
      port: Config.dbPort,
      user: Config.dbUser,
      password: Config.dbPassword,
      db: Config.dbName,
    );

    _showLoading();
    try {
      // Conectar ao MySQL
      final conn = await MySqlConnection.connect(settings);

      // Verificar se o email existe na tabela usuarios
      var results = await conn.query(
        'SELECT * FROM usuarios WHERE email = ?',
        [email],
      );

      await conn.close();
      _hideLoading();

      if (results.isNotEmpty) {
        // Simular o envio de email (aqui você integraria um serviço de email real)
        _showSuccessDialog('Instruções enviadas para o seu e-mail.');
      } else {
        _showErrorDialog('E-mail não encontrado.');
      }
    } catch (e) {
      _hideLoading();
      _showErrorDialog('Erro ao conectar ao servidor: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sucesso'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fecha o diálogo
              Navigator.pop(context); // Volta para a tela anterior (opcional)
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Esqueci a Senha',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff1ebbd8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("android/imagens/fundo.png"),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Digite seu e-mail para receber as instruções de recuperação:',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _controllerEmail,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _enviarEmailRecuperacao,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1ebbd8),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Enviar E-mail',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}