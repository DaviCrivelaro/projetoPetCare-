import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:crypto/crypto.dart'; // Para hash da senha
import 'dart:convert'; // Para converter a senha em bytes

class CadastroUsuario extends StatefulWidget {
  const CadastroUsuario({super.key});

  @override
  _CadastroState createState() => _CadastroState();
}

class _CadastroState extends State<CadastroUsuario> {
  final TextEditingController _controllerNome = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerSenha = TextEditingController();
  String _tipoUsuario = 'tutor'; // Valor padrão
  String _mensagemErro = "";

  Future<void> _cadastrarUsuario() async {
    String nome = _controllerNome.text.trim();
    String email = _controllerEmail.text.trim();
    String senha = _controllerSenha.text.trim();

    if (nome.isEmpty) {
      setState(() {
        _mensagemErro = "O nome não pode estar vazio!";
      });
      return;
    }
    if (email.isEmpty || !email.contains("@")) {
      setState(() {
        _mensagemErro = "Digite um e-mail válido!";
      });
      return;
    }
    if (senha.isEmpty || senha.length <= 6) {
      setState(() {
        _mensagemErro = "A senha deve ter mais de 6 caracteres!";
      });
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

      // Inserir o novo usuário com tipo e id_relacionado
      var result = await conn.query(
        'INSERT INTO usuarios (nome, email, senha, tipo, id_relacionado) VALUES (?, ?, ?, ?, 0)',
        [nome, email, senhaHash, _tipoUsuario],
      );

      int idUsuario = result.insertId!;
      await conn.close();

      // Redirecionar com base no tipo
      if (_tipoUsuario == 'tutor') {
        Navigator.pushReplacementNamed(
          context,
          '/cadastroTutor',
          arguments: {'idUsuario': idUsuario},
        );
      } else if (_tipoUsuario == 'clinica') {
        Navigator.pushReplacementNamed(
          context,
          '/cadastroClinica',
          arguments: {'idUsuario': idUsuario},
        );
      }
    } catch (e) {
      setState(() {
        _mensagemErro = "Erro ao cadastrar: $e";
        if (e.toString().contains('Duplicate entry')) {
          _mensagemErro = "Este e-mail já está cadastrado!";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastro de Usuário", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff1ebbd8),
      ),
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
                const SizedBox(height: 50),
                TextField(
                  controller: _controllerNome,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(32, 10, 32, 10),
                    hintText: "Nome completo",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controllerEmail,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(32, 10, 32, 10),
                    hintText: "E-mail",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controllerSenha,
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(32, 10, 32, 10),
                    hintText: "Senha",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _tipoUsuario,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(32, 10, 32, 10),
                    hintText: "Tipo de Usuário",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'tutor', child: Text('Tutor')),
                    DropdownMenuItem(value: 'clinica', child: Text('Clínica')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _tipoUsuario = value!;
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1ebbd8),
                      padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                    ),
                    onPressed: _cadastrarUsuario,
                    child: const Text(
                      "Cadastrar",
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Center(
                    child: Text(
                      _mensagemErro,
                      style: const TextStyle(color: Colors.red, fontSize: 20),
                    ),
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