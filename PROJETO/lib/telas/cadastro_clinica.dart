import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_pim/config.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class CadastroClinica extends StatefulWidget {
  const CadastroClinica({super.key});
  
    @override
  _CadastroClinicaState createState() => _CadastroClinicaState();
}

class _CadastroClinicaState extends State<CadastroClinica> {
  final TextEditingController _controllerRazaoSocial = TextEditingController();
  final TextEditingController _controllerCNPJ = TextEditingController();
  final TextEditingController _controllerTelefone = TextEditingController();
  final TextEditingController _controllerRua = TextEditingController();
  final TextEditingController _controllerNumero = TextEditingController();
  final TextEditingController _controllerBairro = TextEditingController();
  final TextEditingController _controllerComplemento = TextEditingController();
  final TextEditingController _controllerCidade = TextEditingController();
  final TextEditingController _controllerEstado = TextEditingController();
  final TextEditingController _controllerCep = TextEditingController();

  double? _latitude;
  double? _longitude;

  // Função para obter latitude e longitude a partir do endereço
  Future<void> _obterLocalizacao() async {
    // Obter o endereço completo
    String enderecoCompleto = '${_controllerRua.text}, ${_controllerNumero.text}, ${_controllerBairro.text}, ${_controllerCidade.text}, ${_controllerEstado.text}, ${_controllerCep.text}';

    try {
      // Usando a API de Geocoding do Google para obter as coordenadas
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

  Future<void> _cadastrarClinica() async {
    
   if (_controllerRazaoSocial.text.isEmpty ||
       _controllerCNPJ.text.isEmpty ||
       _controllerTelefone.text.isEmpty ||
       _controllerRua.text.isEmpty ||
       _controllerNumero.text.isEmpty ||
       _controllerBairro.text.isEmpty ||
       _controllerComplemento.text.isEmpty ||
       _controllerCidade.text.isEmpty ||
       _controllerEstado.text.isEmpty ||
       _controllerCep.text.isEmpty ||
       _latitude == null ||
       _longitude == null) 
        {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preencha todos os campos Obrigatorios!')),
      );
      return;
        }

     //Montar os dados a serem enviados
    final Map<String,dynamic> dadosClinica = {
      'razao_social': _controllerRazaoSocial.text,
      'cnpj': _controllerCNPJ.text,
      'telefone': _controllerTelefone.text,
      'logradouro': _controllerRua.text,
      'numero': _controllerNumero.text,
      'bairro':_controllerBairro.text,
      'complemento': _controllerComplemento.text,
      'cidade':  _controllerCidade.text,
      'estado': _controllerEstado.text,
      'cep': _controllerCep.text,
      'latitude': _latitude,
      'longitude': _longitude,
    };

  
      final url = Uri.parse('$serverIP/cadastro_clinica.php');

      try {
        final response = await http.post(
          url,
          headers: {'content-type': 'application/json'},
          body: jsonEncode(dadosClinica),
          );

    final responseData =json.decode(response.body);

      
      if (responseData['status'] == 'sucewsso') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clinica Cadastrada com Sucesso!')),
          );
      

   // limpar os campos 

    _controllerRazaoSocial.clear();
    _controllerCNPJ.clear();
    _controllerTelefone.clear();
    _controllerRua.clear();
    _controllerNumero.clear();
    _controllerBairro.clear();
    _controllerComplemento.clear();
    _controllerCidade.clear();
    _controllerCep.clear();
    _controllerEstado.clear();

  }else{

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro: ${responseData['mensagem']}')),
      );
  }
      }catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao cadastrar: $error')),
      );

      }
    
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cadastro de Clínica',
          style: TextStyle(color: Colors.white),
        ),
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
                const SizedBox(height: 32),
                TextField(
                  controller: _controllerRazaoSocial,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(32, 8, 32, 8),
                    hintText: "Razão Social",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controllerCNPJ,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(32, 8, 32, 8),
                    hintText: "CNPJ",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controllerTelefone,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(32, 8, 32, 8),
                    hintText: "Telefone",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controllerRua,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(32, 8, 32, 8),
                    hintText: "Rua",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controllerNumero,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(32, 8, 32, 8),
                    hintText: "Número",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controllerBairro,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(32, 8, 32, 8),
                    hintText: "Bairro",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controllerComplemento,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(32, 8, 32, 8),
                    hintText: "Complemento",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                TextField(
                  controller: _controllerCidade,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(32, 8, 32, 8),
                    hintText: "Cidade",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                TextField(
                  controller: _controllerEstado,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(32, 8, 32, 8),
                    hintText: "Estado",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                TextField(
                  controller: _controllerCep,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(32, 8, 32, 8),
                    hintText: "CEP",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _obterLocalizacao, 
                  child: const Text('obter Localização')
                  ),

               const SizedBox(height: 20),                               
                    ElevatedButton(
                        onPressed: _cadastrarClinica,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff1ebbd8),
                          padding: const EdgeInsets.symmetric(vertical: 02, horizontal: 50),
                        ),
                        child: const Text('Salvar',
                          style: TextStyle(fontSize: 20, color: Colors.white),
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
