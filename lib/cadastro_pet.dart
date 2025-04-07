import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

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
  int? _idPet;
  bool _isInitialized = false;

  List<dynamic> _especies = [];
  List<dynamic> _racas = [];
  bool _isLoading = false;

  final _settings = ConnectionSettings(
    host: '34.46.224.119',
    port: 3306,
    user: 'root',
    password: '{;&AOd):6YT]~7j9',
    db: 'flutter_pim',
  );

  @override
  void initState() {
    super.initState();
    _fetchEspecies();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _preencherCampos();
      _isInitialized = true;
    }
  }

  Future<void> _fetchEspecies() async {
    try {
      final conn = await MySqlConnection.connect(_settings);
      var results = await conn.query('SELECT idespecie, descricao FROM especie');
      setState(() {
        _especies = results.map((row) => {'idespecie': row[0], 'descricao': row[1]}).toList();
      });
      await conn.close();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar espécies: $e')),
      );
    }
  }

  Future<void> _fetchRacas(String idespecie) async {
    try {
      final conn = await MySqlConnection.connect(_settings);
      var results = await conn.query(
        'SELECT idraca, raca FROM raca WHERE idespecie = ?',
        [idespecie],
      );
      setState(() {
        _racas = results.map((row) => {'idraca': row[0], 'raca': row[1]}).toList();
      });
      await conn.close();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar raças: $e')),
      );
    }
  }

  void _preencherCampos() {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (arguments != null && arguments.containsKey('idpet')) {
      setState(() {
        _idPet = arguments['idpet'];
        _nomeController.text = arguments['nome'] ?? '';
        _idadeController.text = arguments['idade'].toString();
        _selectedSexo = arguments['sexo'];
        _selectedEspecie = arguments['idespecie'].toString();
        _selectedRaca = arguments['idraca'].toString();
        _fetchRacas(_selectedEspecie!);
      });
    }
  }

  Future<void> _salvarPet() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      final idTutor = arguments?['id_tutor'];

      if (idTutor == null && _idPet == null) {
        setState(() {
          _isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro: ID do tutor não fornecido!')),
          );
        });
        return;
      }

      try {
        final conn = await MySqlConnection.connect(_settings);
        if (_idPet == null) {
          await conn.query(
            'INSERT INTO pet (nome, idade, sexo, idespecie, idraca, id_tutor) VALUES (?, ?, ?, ?, ?, ?)',
            [
              _nomeController.text,
              _idadeController.text,
              _selectedSexo,
              _selectedEspecie,
              _selectedRaca,
              idTutor,
            ],
          );
        } else {
          await conn.query(
            'UPDATE pet SET nome = ?, idade = ?, sexo = ?, idespecie = ?, idraca = ? WHERE idpet = ?',
            [
              _nomeController.text,
              _idadeController.text,
              _selectedSexo,
              _selectedEspecie,
              _selectedRaca,
              _idPet,
            ],
          );
        }
        await conn.close();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_idPet == null ? 'Pet cadastrado com sucesso!' : 'Pet atualizado com sucesso!')),
        );
        _limparCampos();
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar o pet: $e')),
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
    setState(() {
      _racas = [];
    });
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
            _racas = [];
            _selectedRaca = null;
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