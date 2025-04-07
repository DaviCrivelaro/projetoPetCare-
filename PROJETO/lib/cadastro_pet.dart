import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_pim/config.dart';
import 'package:http/http.dart' as http;

class CadastroPet extends StatefulWidget {
  const CadastroPet({super.key});

  @override
  _CadastroPetState createState() => _CadastroPetState();
}

class _CadastroPetState extends State<CadastroPet> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _idadeController = TextEditingController();
  String? _selectedEspecie;
  String? _selectedRaca;
  String? _selectedSexo;

  List<dynamic> _especies = [];
  List<dynamic> _racas = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchEspecies();
  }

  Future<void> _fetchEspecies() async {
    var url = Uri.parse('$serverIP/especie.php');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        _especies = jsonDecode(response.body);
      });
    }
  }

  Future<void> _fetchRacas(String idespecie) async {
    var url = Uri.parse('$serverIP/raca.php');
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idespecie': idespecie}),
    );
    if (response.statusCode == 200) {
      setState(() {
        _racas = jsonDecode(response.body);
      });
    }
  }

  void _salvarPet() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      var url = Uri.parse('$serverIP/cadastro_pet.php');
      var petData = {
        'nome': _nomeController.text,
        'idade': _idadeController.text,
        'sexo': _selectedSexo,
        'idespecie': _selectedEspecie,
        'idraca': _selectedRaca,
      };

      try {
        var response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(petData),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pet cadastrado com sucesso!')),
          );
          _limparCampos();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao cadastrar o pet.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro de conexão com o servidor.')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _limparCampos() {
    _nomeController.clear();
    _idadeController.clear();
    _selectedEspecie = null;
    _selectedRaca = null;
    _selectedSexo = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastro de Pet", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff1ebbd8),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("android/imagens/fundo.png"),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(_nomeController, "Nome"),
                      _buildTextField(_idadeController, "Idade"),
                      _buildDropdownSexo(),
                      _buildDropdownEspecie(),
                      _buildDropdownRaca(),
                      const SizedBox(height: 20),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _salvarPet,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff1ebbd8),
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 140),
                                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              child: const Text('Salvar', style: TextStyle(color: Colors.white)),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Informe o $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownSexo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: DropdownButtonFormField<String>(
        value: _selectedSexo,
        decoration: InputDecoration(
          hintText: "Selecione o Sexo",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onChanged: (String? newValue) {
          setState(() {
            _selectedSexo = newValue;
          });
        },
        items: ['Masculino', 'Feminino'].map((sexo) {
          return DropdownMenuItem<String>(
            value: sexo,
            child: Text(sexo),
          );
        }).toList(),
        validator: (value) {
          if (value == null) {
            return 'Selecione o sexo do pet';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownEspecie() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: DropdownButtonFormField<String>(
        value: _selectedEspecie,
        decoration: InputDecoration(
          hintText: "Selecione a Espécie",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onChanged: (String? newValue) {
          setState(() {
            _selectedEspecie = newValue;
            if (newValue != null) {
              _fetchRacas(newValue);
            }
          });
        },
        items: _especies.map((especie) {
          return DropdownMenuItem<String>(
            value: especie['idespecie'].toString(),
            child: Text(especie['descricao']),
          );
        }).toList(),
        validator: (value) {
          if (value == null) {
            return 'Selecione uma espécie';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownRaca() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: DropdownButtonFormField<String>(
        value: _selectedRaca,
        decoration: InputDecoration(
          hintText: "Selecione a Raça",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onChanged: (String? newValue) {
          setState(() {
            _selectedRaca = newValue;
          });
        },
        items: _racas.map((raca) {
          return DropdownMenuItem<String>(
            value: raca['idraca'].toString(),
            child: Text(raca['raca']),
          );
        }).toList(),
        validator: (value) {
          if (value == null) {
            return 'Selecione uma raça';
          }
          return null;
        },
      ),
    );
  }
}
