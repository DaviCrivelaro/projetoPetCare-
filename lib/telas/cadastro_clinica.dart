import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CadastroClinica extends StatefulWidget {
  const CadastroClinica({super.key});

  @override
  _CadastroClinicaState createState() => _CadastroClinicaState();
}

class _CadastroClinicaState extends State<CadastroClinica> {
  final _nomeController = TextEditingController();
  final _cnpjController = TextEditingController();
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
  Map<String, dynamic>? _dadosCadastrados; // Armazenar os dados após o cadastro
  bool _modoEdicao = false; // Controlar se está editando

  Future<void> _preencherEnderecoPorCEP() async {
    String cep = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cep.length == 8) {
      final url = Uri.parse('https://viacep.com.br/ws/$cep/json/');
      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['erro'] == true) {
            return;
          }
          setState(() {
            _logradouroController.text = data['logradouro'] ?? '';
            _bairroController.text = data['bairro'] ?? '';
            _cidadeController.text = data['localidade'] ?? '';
            _estadoController.text = data['uf'] ?? '';
          });
          await _obterLocalizacao();
        }
      } catch (e) {
        print('Erro ao buscar endereço: $e');
      }
    }
  }

  Future<void> _obterLocalizacao() async {
    String enderecoCompleto =
        '${_logradouroController.text}, ${_numeroController.text}, ${_bairroController.text}, ${_cidadeController.text}, ${_estadoController.text}, ${_cepController.text}';
    try {
      List<Location> locations = await locationFromAddress(enderecoCompleto);
      if (locations.isNotEmpty) {
        setState(() {
          _latitude = locations.first.latitude;
          _longitude = locations.first.longitude;
        });
      } else {
        setState(() {
          _mensagemErro = 'Não foi possível obter a localização.';
        });
      }
    } catch (e) {
      setState(() {
        _mensagemErro = 'Erro ao obter a localização: $e';
      });
    }
  }

  Future<void> _cadastrarOuAtualizarClinica() async {
    if (_nomeController.text.isEmpty ||
        _cnpjController.text.isEmpty ||
        _telefoneController.text.isEmpty ||
        _logradouroController.text.isEmpty ||
        _numeroController.text.isEmpty ||
        _bairroController.text.isEmpty ||
        _cidadeController.text.isEmpty ||
        _estadoController.text.isEmpty ||
        _cepController.text.isEmpty) {
      setState(() {
        _mensagemErro = "Preencha todos os campos obrigatórios!";
      });
      return;
    }

    final settings = ConnectionSettings(
      host: '34.46.224.119',
      port: 3306,
      user: 'root',
      password: '{;&AOd):6YT]~7j9',
      db: 'flutter_pim',
    );

    try {
      final conn = await MySqlConnection.connect(settings);

      if (_modoEdicao && _dadosCadastrados != null) {
        // Atualizar endereço usando idendereco
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
            _dadosCadastrados!['idendereco'],
          ],
        );

        // Atualizar clínica usando idclinica
        await conn.query(
          'UPDATE clinica SET razao = ?, cnpj = ?, telefone = ?, idendereco = ? WHERE idclinica = ?',
          [
            _nomeController.text,
            _cnpjController.text,
            _telefoneController.text,
            _dadosCadastrados!['idendereco'],
            _dadosCadastrados!['idclinica'],
          ],
        );

        // Atualizar os dados locais com os valores editados
        setState(() {
          _dadosCadastrados = {
            'idclinica': _dadosCadastrados!['idclinica'],
            'razao': _nomeController.text,
            'cnpj': _cnpjController.text,
            'telefone': _telefoneController.text,
            'idendereco': _dadosCadastrados!['idendereco'],
            'logradouro': _logradouroController.text,
            'numero': _numeroController.text,
            'complemento': _complementoController.text,
            'bairro': _bairroController.text,
            'cidade': _cidadeController.text,
            'estado': _estadoController.text,
            'cep': _cepController.text,
            'latitude': _latitude,
            'longitude': _longitude,
          };
          _mensagemErro = "Clínica atualizada com sucesso!";
          _modoEdicao = false;
        });
      } else {
        // Inserir na tabela endereco
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

        // Inserir na tabela clinica
        var resultClinica = await conn.query(
          'INSERT INTO clinica (razao, cnpj, telefone, idendereco) VALUES (?, ?, ?, ?)',
          [
            _nomeController.text,
            _cnpjController.text,
            _telefoneController.text,
            idEndereco,
          ],
        );
        int idClinica = resultClinica.insertId!;

        setState(() {
          _mensagemErro = "Clínica cadastrada com sucesso!";
          _dadosCadastrados = {
            'idclinica': idClinica,
            'razao': _nomeController.text,
            'cnpj': _cnpjController.text,
            'telefone': _telefoneController.text,
            'idendereco': idEndereco,
            'logradouro': _logradouroController.text,
            'numero': _numeroController.text,
            'complemento': _complementoController.text,
            'bairro': _bairroController.text,
            'cidade': _cidadeController.text,
            'estado': _estadoController.text,
            'cep': _cepController.text,
            'latitude': _latitude,
            'longitude': _longitude,
          };
        });
      }

      await conn.close();
    } catch (e) {
      setState(() {
        _mensagemErro = "Erro: $e";
      });
      if (e.toString().contains('Duplicate entry')) {
        setState(() {
          _mensagemErro = "Este CNPJ já está cadastrado!";
        });
      }
    }
  }

  void _limparCampos() {
    _nomeController.clear();
    _cnpjController.clear();
    _telefoneController.clear();
    _logradouroController.clear();
    _numeroController.clear();
    _complementoController.clear();
    _bairroController.clear();
    _cidadeController.clear();
    _estadoController.clear();
    _cepController.clear();
    setState(() {
      _latitude = null;
      _longitude = null;
      _dadosCadastrados = null;
      _modoEdicao = false;
      _mensagemErro = "";
    });
  }

  void _editarDados() {
    setState(() {
      _nomeController.text = _dadosCadastrados!['razao'];
      _cnpjController.text = _dadosCadastrados!['cnpj'];
      _telefoneController.text = _dadosCadastrados!['telefone'];
      _logradouroController.text = _dadosCadastrados!['logradouro'];
      _numeroController.text = _dadosCadastrados!['numero'];
      _complementoController.text = _dadosCadastrados!['complemento'] ?? '';
      _bairroController.text = _dadosCadastrados!['bairro'];
      _cidadeController.text = _dadosCadastrados!['cidade'];
      _estadoController.text = _dadosCadastrados!['estado'];
      _cepController.text = _dadosCadastrados!['cep'];
      _latitude = _dadosCadastrados!['latitude'];
      _longitude = _dadosCadastrados!['longitude'];
      _modoEdicao = true;
      _mensagemErro = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Clínica', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff1ebbd8),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_dadosCadastrados == null || _modoEdicao) ...[
              _buildTextField(_nomeController, 'Razão Social'),
              _buildTextField(_cnpjController, 'CNPJ'),
              _buildTextField(_telefoneController, 'Telefone'),
              _buildTextField(_cepController, 'CEP', onChanged: (_) => _preencherEnderecoPorCEP()),
              _buildTextField(_logradouroController, 'Logradouro'),
              _buildTextField(_numeroController, 'Número'),
              _buildTextField(_complementoController, 'Complemento'),
              _buildTextField(_bairroController, 'Bairro'),
              _buildTextField(_cidadeController, 'Cidade'),
              _buildTextField(_estadoController, 'Estado'),
            ],
            if (_dadosCadastrados != null && !_modoEdicao) ...[
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("ID Clínica: ${_dadosCadastrados!['idclinica']}", style: const TextStyle(fontSize: 16)),
                      Text("Razão Social: ${_dadosCadastrados!['razao']}", style: const TextStyle(fontSize: 16)),
                      Text("CNPJ: ${_dadosCadastrados!['cnpj']}", style: const TextStyle(fontSize: 16)),
                      Text("Telefone: ${_dadosCadastrados!['telefone']}", style: const TextStyle(fontSize: 16)),
                      Text("Logradouro: ${_dadosCadastrados!['logradouro']}", style: const TextStyle(fontSize: 16)),
                      Text("Número: ${_dadosCadastrados!['numero']}", style: const TextStyle(fontSize: 16)),
                      Text("Complemento: ${_dadosCadastrados!['complemento'] ?? 'N/A'}", style: const TextStyle(fontSize: 16)),
                      Text("Bairro: ${_dadosCadastrados!['bairro']}", style: const TextStyle(fontSize: 16)),
                      Text("Cidade: ${_dadosCadastrados!['cidade']}", style: const TextStyle(fontSize: 16)),
                      Text("Estado: ${_dadosCadastrados!['estado']}", style: const TextStyle(fontSize: 16)),
                      Text("CEP: ${_dadosCadastrados!['cep']}", style: const TextStyle(fontSize: 16)),
                      Text("Latitude: ${_dadosCadastrados!['latitude'] ?? 'N/A'}", style: const TextStyle(fontSize: 16)),
                      Text("Longitude: ${_dadosCadastrados!['longitude'] ?? 'N/A'}", style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _editarDados,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(200, 50),
                ),
                child: const Text('Alterar', style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
            ],
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Center(
                child: Text(
                  _mensagemErro,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _cadastrarOuAtualizarClinica,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff1ebbd8),
                minimumSize: const Size(200, 50),
              ),
              child: Text(
                _modoEdicao ? 'Salvar Alterações' : 'Cadastrar Clínica',
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            if (_dadosCadastrados != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _limparCampos,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  minimumSize: const Size(200, 50),
                ),
                child: const Text('Novo Cadastro', style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}