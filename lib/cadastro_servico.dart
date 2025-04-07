import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

class CadastroServico extends StatefulWidget {
  const CadastroServico({super.key});

  @override
  _CadastroServicoState createState() => _CadastroServicoState();
}

class _CadastroServicoState extends State<CadastroServico> {
  final TextEditingController _controllerNomeServico = TextEditingController();
  String _mensagemErro = "";
  List<dynamic> _clinicas = [];
  String? _selectedClinica;

  // Configuração do banco na nuvem
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
    _carregarClinicas(); // Carregar clínicas ao iniciar
  }

  Future<void> _carregarClinicas() async {
    try {
      final conn = await MySqlConnection.connect(_settings);
      var results = await conn.query('SELECT idclinica, razao FROM clinica');
      setState(() {
        _clinicas = results.map((row) => {'idclinica': row[0], 'razao': row[1]}).toList();
      });
      await conn.close();
    } catch (e) {
      setState(() {
        _mensagemErro = "Erro ao carregar clínicas: $e";
      });
    }
  }

  void _validarCampos() {
    String nomeServico = _controllerNomeServico.text;

    if (nomeServico.isNotEmpty && _selectedClinica != null) {
      _cadastrarServico(nomeServico, _selectedClinica!);
    } else {
      setState(() {
        _mensagemErro = "Preencha todos os campos.";
      });
    }
  }

  Future<void> _cadastrarServico(String nomeServico, String idClinica) async {
    try {
      final conn = await MySqlConnection.connect(_settings);
      await conn.query(
        'INSERT INTO servico (nome_servico, idclinica) VALUES (?, ?)',
        [nomeServico, idClinica],
      );
      await conn.close();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Serviço cadastrado com sucesso!')),
      );
      _limparCampos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar serviço: $e')),
      );
    }
  }

  void _limparCampos() {
    _controllerNomeServico.clear();
    setState(() {
      _selectedClinica = null; // Limpa a seleção da clínica
      _mensagemErro = ""; // Limpa a mensagem de erro
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastro de Serviço", style: TextStyle(color: Colors.white)),
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
                  controller: _controllerNomeServico,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(32, 10, 32, 10),
                    hintText: "Nome do Serviço",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedClinica,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  hint: const Text("Selecione a Clínica"),
                  items: _clinicas.map((clinica) {
                    return DropdownMenuItem<String>(
                      value: clinica['idclinica'].toString(),
                      child: Text(clinica['razao']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedClinica = value;
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1ebbd8),
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 50),
                    ),
                    onPressed: _validarCampos,
                    child: const Text(
                      "Salvar",
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