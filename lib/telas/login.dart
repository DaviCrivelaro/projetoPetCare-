import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:crypto/crypto.dart'; // Para gerar o hash
import 'dart:convert'; // Para converter a senha em bytes
import 'package:flutter_pim/esqueci_senha.dart';
import 'package:flutter_pim/home_tutor.dart'; // Nova tela para Tutor
import 'package:flutter_pim/home_clinica.dart'; // Nova tela para Clínica

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerSenha = TextEditingController();

  Future<void> _login() async {
    String email = _controllerEmail.text.trim();
    String senha = _controllerSenha.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      _showErrorDialog("Por favor, preencha todos os campos.");
      return;
    }

    // Gerar o hash da senha usando SHA-256
    String senhaHash = sha256.convert(utf8.encode(senha)).toString();

    // Configurações de conexão com o Cloud SQL
    final settings = ConnectionSettings(
      host: '34.46.224.119',
      port: 3306,
      user: 'root',
      password: '{;&AOd):6YT]~7j9',
      db: 'flutter_pim',
    );

    try {
      // Conectar ao MySQL
      final conn = await MySqlConnection.connect(settings);

      // Consulta ao banco com o hash da senha
      var results = await conn.query(
        'SELECT id, tipo, id_relacionado FROM usuarios WHERE email = ? AND senha = ?',
        [email, senhaHash],
      );

      if (results.isNotEmpty) {
        var usuario = {
          'id': results.first['id_relacionado'], // ID do tutor ou clínica
          'tipo': results.first['tipo'],
        };
        await conn.close();

        // Redirecionar com base no tipo
        if (usuario['tipo'] == 'tutor') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeTutor(usuario: usuario)),
          );
        } else if (usuario['tipo'] == 'clinica') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeClinica(usuario: usuario)),
          );
        }
      } else {
        await conn.close();
        _showErrorDialog('Email ou senha inválidos.');
      }
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("android/imagens/fundo.png"),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Image.asset(
                    "android/imagens/logo.png",
                    width: 200,
                    height: 150,
                  ),
                ),
                TextField(
                  controller: _controllerEmail,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                    hintText: "e-mail",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _controllerSenha,
                  obscureText: true,
                  style: const TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                    hintText: "senha",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 10),
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1ebbd8),
                    ),
                    child: const Text(
                      "Entrar",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
                Center(
                  child: GestureDetector(
                    child: const Text(
                      "Não tem conta? Cadastre-se!",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, "/cadastroUsuario");
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    child: const Text(
                      "Esqueci a senha?",
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EsqueciSenha()),
                      );
                    },
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