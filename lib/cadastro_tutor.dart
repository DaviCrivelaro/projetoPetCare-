import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_pim/config.dart';

class CadastroTutor extends StatefulWidget {
  const CadastroTutor({super.key});

  @override
  _CadastroTutorState createState() => _CadastroTutorState();
}

class _CadastroTutorState extends State<CadastroTutor> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();
  final _cepController = TextEditingController();

  double? _latitude;
  double? _longitude;
  String _mensagemErro = "";
  int? _idTutor;
  Map<String, dynamic>? _arguments; // Armazenar os arguments aqui
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Apenas inicialização básica aqui, sem acesso ao contexto
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      _preencherCampos();
      _isInitialized = true;
    }
  }

  void _preencherCampos() {
    if (_arguments != null && _arguments!.containsKey('id')) {
      setState(() {
        _idTutor = _arguments!['id'];
        _nomeController.text = _arguments!['nome'] ?? '';
        _emailController.text = _arguments!['email'] ?? '';
        _telefoneController.text = _arguments!['telefone'] ?? '';
        _logradouroController.text = _arguments!['logradouro'] ?? '';
        _numeroController.text = _arguments!['numero'] ?? '';
        _complementoController.text = _arguments!['complemento'] ?? '';
        _bairroController.text = _arguments!['bairro'] ?? '';
        _cidadeController.text = _arguments!['cidade'] ?? '';
        _estadoController.text = _arguments!['estado'] ?? '';
        _cepController.text = _arguments!['cep'] ?? '';
        _latitude = _arguments!['latitude'];
        _longitude = _arguments!['longitude'];
      });
    }
  }

  Future<void> _preencherEnderecoPorCEP() async {
    String cep = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cep.length == 8) {
      final url = Uri.parse('https://viacep.com.br/ws/$cep/json/');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['erro'] != true) {
          setState(() {
            _logradouroController.text = data['logradouro'] ?? '';
            _bairroController.text = data['bairro'] ?? '';
            _cidadeController.text = data['localidade'] ?? '';
            _estadoController.text = data['uf'] ?? '';
          });
          await _obterLocalizacao();
        }
      }
    }
  }

  Future<void> _obterLocalizacao() async {
    String enderecoCompleto =
        '${_logradouroController.text}, ${_numeroController.text}, ${_cidadeController.text}, ${_estadoController.text}';
    try {
      List<Location> locations = await locationFromAddress(enderecoCompleto);
      if (locations.isNotEmpty) {
        setState(() {
          _latitude = locations.first.latitude;
          _longitude = locations.first.longitude;
        });
      }
    } catch (e) {
      print('Erro ao obter localização: $e');
    }
  }

  Future<void> _salvarTutor() async {
    if (_nomeController.text.isEmpty || _emailController.text.isEmpty || _telefoneController.text.isEmpty) {
      setState(() {
        _mensagemErro = "Preencha todos os campos obrigatórios!";
      });
      return;
    }

    final conn = await MySqlConnection.connect(ConnectionSettings(
      host: Config.dbHost,
      port: Config.dbPort,
      user: Config.dbUser,
      password: Config.dbPassword,
      db: Config.dbName,
    ));

    try {
      if (_idTutor == null) {
        // Cadastro novo
        var resultEndereco = await conn.query(
          'INSERT INTO endereco (logradouro, numero, complemento, bairro, cidade, estado, cep, latitude, longitude) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            _logradouroController.text,
            _numeroController.text,
            _complementoController.text,
            _bairroController.text,
            _cidadeController.text,
            _estadoController.text,
            _cepController.text,
            _latitude,
            _longitude,
          ],
        );
        int idEndereco = resultEndereco.insertId!;

        var resultTutor = await conn.query(
          'INSERT INTO tutor (nome, email, telefone, idendereco) VALUES (?, ?, ?, ?)',
          [_nomeController.text, _emailController.text, _telefoneController.text, idEndereco],
        );
        int idTutor = resultTutor.insertId!;

        if (_arguments != null && _arguments!.containsKey('idUsuario')) {
          await conn.query(
            'UPDATE usuarios SET id_relacionado = ? WHERE id = ?',
            [idTutor, _arguments!['idUsuario']],
          );
        }
      } else {
        // Edição
        await conn.query(
          'UPDATE endereco SET logradouro = ?, numero = ?, complemento = ?, bairro = ?, cidade = ?, estado = ?, cep = ?, latitude = ?, longitude = ? WHERE idendereco = ?',
          [
            _logradouroController.text,
            _numeroController.text,
            _complementoController.text,
            _bairroController.text,
            _cidadeController.text,
            _estadoController.text,
            _cepController.text,
            _latitude,
            _longitude,
            _arguments!['idendereco'], // Usamos _arguments em vez de ModalRoute
          ],
        );
        await conn.query(
          'UPDATE tutor SET nome = ?, email = ?, telefone = ? WHERE idtutor = ?',
          [_nomeController.text, _emailController.text, _telefoneController.text, _idTutor],
        );
      }

      setState(() {
        _mensagemErro = _idTutor == null ? "Tutor cadastrado com sucesso!" : "Tutor atualizado com sucesso!";
      });
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _mensagemErro = "Erro ao salvar: $e";
      });
    } finally {
      await conn.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Tutor', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff1ebbd8),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _nomeController, decoration: const InputDecoration(labelText: 'Nome')),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'E-mail')),
            TextField(controller: _telefoneController, decoration: const InputDecoration(labelText: 'Telefone')),
            TextField(controller: _cepController, decoration: const InputDecoration(labelText: 'CEP'), onChanged: (_) => _preencherEnderecoPorCEP()),
            TextField(controller: _logradouroController, decoration: const InputDecoration(labelText: 'Logradouro')),
            TextField(controller: _numeroController, decoration: const InputDecoration(labelText: 'Número')),
            TextField(controller: _complementoController, decoration: const InputDecoration(labelText: 'Complemento')),
            TextField(controller: _bairroController, decoration: const InputDecoration(labelText: 'Bairro')),
            TextField(controller: _cidadeController, decoration: const InputDecoration(labelText: 'Cidade')),
            TextField(controller: _estadoController, decoration: const InputDecoration(labelText: 'Estado')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _salvarTutor, child: const Text('Salvar')),
            Text(_mensagemErro, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}