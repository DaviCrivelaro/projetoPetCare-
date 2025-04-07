import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_pim/config.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';

class CadastroTutor extends StatefulWidget {
  const CadastroTutor({super.key});

  @override
  _CadastroTutorState createState() => _CadastroTutorState();
}

class _CadastroTutorState extends State<CadastroTutor> {
  // Controladores para os campos de texto
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

  // Função para obter latitude e longitude a partir do endereço
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível obter a localização.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao obter a localização: $e')),
      );
    }
  }

  // Função para enviar os dados para o backend
  Future<void> _cadastrarTutor() async {
    if (_nomeController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _telefoneController.text.isEmpty ||
        _logradouroController.text.isEmpty ||
        _numeroController.text.isEmpty ||
        _bairroController.text.isEmpty ||
        _cidadeController.text.isEmpty ||
        _estadoController.text.isEmpty ||
        _cepController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios!')),
      );
      return;
    }

    final Map<String, dynamic> dadosTutor = {
      'nome': _nomeController.text,
      'email': _emailController.text,
      'telefone': _telefoneController.text,
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

    final url = Uri.parse('$serverIP/cadastro_tutor.php');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dadosTutor),
      );

      final responseData = json.decode(response.body);

      if (responseData['status'] == 'sucesso') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tutor cadastrado com sucesso!')),
        );
        _nomeController.clear();
        _emailController.clear();
        _telefoneController.clear();
        _logradouroController.clear();
        _numeroController.clear();
        _complementoController.clear();
        _bairroController.clear();
        _cidadeController.clear();
        _estadoController.clear();
        _cepController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${responseData['mensagem']}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Tutor'),
        backgroundColor: const Color(0xff1ebbd8),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("android/imagens/fundo.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(_nomeController, 'Nome'),
                  _buildTextField(_emailController, 'E-mail', TextInputType.emailAddress),
                  _buildTextField(_telefoneController, 'Telefone', TextInputType.phone),
                  _buildTextField(_logradouroController, 'Logradouro'),
                  _buildTextField(_numeroController, 'Número', TextInputType.number),
                  _buildTextField(_complementoController, 'Complemento'),
                  _buildTextField(_bairroController, 'Bairro'),
                  _buildTextField(_cidadeController, 'Cidade'),
                  _buildTextField(_estadoController, 'Estado'),
                  _buildTextField(_cepController, 'CEP', TextInputType.number),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _obterLocalizacao,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1ebbd8),
                      minimumSize: const Size(200, 50),
                    ),
                    child: const Text('Obter Localização'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _cadastrarTutor,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1ebbd8),
                      minimumSize: const Size(200, 50),
                    ),
                    child: const Text('Cadastrar Tutor'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, [TextInputType? keyboardType]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: keyboardType,
      ),
    );
  }
}
