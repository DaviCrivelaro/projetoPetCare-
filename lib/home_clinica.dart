import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

class HomeClinica extends StatefulWidget {
  final Map<String, dynamic>? usuario; // Dados do usuário logado
  const HomeClinica({super.key, this.usuario});

  @override
  _HomeClinicaState createState() => _HomeClinicaState();
}

class _HomeClinicaState extends State<HomeClinica> {
  Map<String, dynamic>? _dadosClinica;
  List<Map<String, dynamic>> _servicos = [];

  @override
  void initState() {
    super.initState();
    _carregarDadosClinica();
  }

  Future<void> _carregarDadosClinica() async {
    final conn = await MySqlConnection.connect(ConnectionSettings(
      host: '34.46.224.119',
      port: 3306,
      user: 'root',
      password: '{;&AOd):6YT]~7j9',
      db: 'flutter_pim',
    ));

    var resultClinica = await conn.query(
      'SELECT c.*, e.* FROM clinica c JOIN endereco e ON c.idendereco = e.idendereco WHERE c.idclinica = ?',
      [widget.usuario?['id']],
    );

    if (resultClinica.isNotEmpty) {
      var row = resultClinica.first;
      setState(() {
        _dadosClinica = {
          'idclinica': row['idclinica'],
          'razao': row['razao'],
          'cnpj': row['cnpj'],
          'telefone': row['telefone'],
          'idendereco': row['idendereco'],
          'logradouro': row['logradouro'],
          'numero': row['numero'],
          'complemento': row['complemento'] ?? 'N/A',
          'bairro': row['bairro'],
          'cidade': row['cidade'],
          'estado': row['estado'],
          'cep': row['cep'],
        };
      });

      var resultServicos = await conn.query(
        'SELECT * FROM servico WHERE idclinica = ?',
        [widget.usuario?['id']],
      );
      setState(() {
        _servicos = resultServicos.map((row) => {
          'idservico': row['idservico'],
          'nome_servico': row['nome_servico'],
        }).toList();
      });
    }

    await conn.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Área da Clínica', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff1ebbd8),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_dadosClinica != null) ...[
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Razão Social: ${_dadosClinica!['razao']}", style: const TextStyle(fontSize: 16)),
                      Text("CNPJ: ${_dadosClinica!['cnpj']}", style: const TextStyle(fontSize: 16)),
                      Text("Telefone: ${_dadosClinica!['telefone']}", style: const TextStyle(fontSize: 16)),
                      Text("Endereço: ${_dadosClinica!['logradouro']}, ${_dadosClinica!['numero']}", style: const TextStyle(fontSize: 16)),
                      Text("Complemento: ${_dadosClinica!['complemento']}", style: const TextStyle(fontSize: 16)),
                      Text("Bairro: ${_dadosClinica!['bairro']}", style: const TextStyle(fontSize: 16)),
                      Text("Cidade: ${_dadosClinica!['cidade']}", style: const TextStyle(fontSize: 16)),
                      Text("Estado: ${_dadosClinica!['estado']}", style: const TextStyle(fontSize: 16)),
                      Text("CEP: ${_dadosClinica!['cep']}", style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/cadastroClinica', arguments: _dadosClinica),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: const Size(200, 50)),
                child: const Text('Editar Dados', style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
              const SizedBox(height: 20),
              const Text("Serviços Cadastrados:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ..._servicos.map((servico) => ListTile(
                    title: Text(servico['nome_servico']),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => Navigator.pushNamed(context, '/cadastroServico', arguments: servico),
                    ),
                  )),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/cadastroServico', arguments: {'idclinica': _dadosClinica!['idclinica']}),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff1ebbd8), minimumSize: const Size(200, 50)),
                child: const Text('Adicionar Serviço', style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
            ] else ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text("Carregando dados da clínica..."),
            ],
          ],
        ),
      ),
    );
  }
}