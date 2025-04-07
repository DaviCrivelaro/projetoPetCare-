import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
//import 'package:flutter_pim/config.dart'; // Ajuste conforme seu arquivo de configuração

class HomeTutor extends StatefulWidget {
  final Map<String, dynamic>? usuario;
  const HomeTutor({super.key, this.usuario});

  @override
  _HomeTutorState createState() => _HomeTutorState();
}

class _HomeTutorState extends State<HomeTutor> {
  Map<String, dynamic>? _dadosTutor;
  List<Map<String, dynamic>> _pets = [];

  @override
  void initState() {
    super.initState();
    _carregarDadosTutor();
  }

  Future<void> _carregarDadosTutor() async {
    print('Carregando dados do tutor com id: ${widget.usuario?['id']}');
    final conn = await MySqlConnection.connect(ConnectionSettings(
      host: '34.46.224.119',
      port: 3306,
      user: 'root',
      password: '{;&AOd):6YT]~7j9',
      db: 'flutter_pim',
    ));

    try {
      var resultTutor = await conn.query(
        'SELECT t.*, e.* FROM tutor t JOIN endereco e ON t.idendereco = e.idendereco WHERE t.idtutor = ?',
        [widget.usuario?['id']],
      );
      print('Resultado da query tutor: ${resultTutor.length} registros encontrados');

      if (resultTutor.isNotEmpty) {
        var row = resultTutor.first;
        setState(() {
          _dadosTutor = {
            'id': row['idtutor'],
            'nome': row['nome'],
            'email': row['email'],
            'telefone': row['telefone'],
            'idendereco': row['idendereco'],
            'logradouro': row['logradouro'],
            'numero': row['numero'],
            'complemento': row['complemento'],
            'bairro': row['bairro'],
            'cidade': row['cidade'],
            'estado': row['estado'],
            'cep': row['cep'],
            'latitude': row['latitude'],
            'longitude': row['longitude'],
          };
          print('Dados do tutor carregados: $_dadosTutor');
        });

        var resultPets = await conn.query(
          'SELECT * FROM pet WHERE id_tutor = ?',
          [widget.usuario?['id']],
        );
        print('Pets encontrados: ${resultPets.length}');
        setState(() {
          _pets = resultPets.map((row) => {
            'idpet': row['idpet'],
            'nome': row['nome'],
            'idade': row['idade'],
            'sexo': row['sexo'],
            'idespecie': row['idespecie'],
            'idraca': row['idraca'],
          }).toList();
        });
      } else {
        print('Nenhum tutor encontrado para id: ${widget.usuario?['id']}');
      }
    } catch (e) {
      print('Erro ao carregar dados do tutor: $e');
    } finally {
      await conn.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Área do Tutor', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff1ebbd8),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_dadosTutor != null) ...[
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("ID: ${_dadosTutor!['id']}", style: const TextStyle(fontSize: 16)),
                      Text("Nome: ${_dadosTutor!['nome']}", style: const TextStyle(fontSize: 16)),
                      Text("E-mail: ${_dadosTutor!['email']}", style: const TextStyle(fontSize: 16)),
                      Text("Telefone: ${_dadosTutor!['telefone']}", style: const TextStyle(fontSize: 16)),
                      Text("Endereço: ${_dadosTutor!['logradouro']}, ${_dadosTutor!['numero']}", style: const TextStyle(fontSize: 16)),
                      Text("Complemento: ${_dadosTutor!['complemento'] ?? 'N/A'}", style: const TextStyle(fontSize: 16)),
                      Text("Bairro: ${_dadosTutor!['bairro']}", style: const TextStyle(fontSize: 16)),
                      Text("Cidade: ${_dadosTutor!['cidade']}", style: const TextStyle(fontSize: 16)),
                      Text("Estado: ${_dadosTutor!['estado']}", style: const TextStyle(fontSize: 16)),
                      Text("CEP: ${_dadosTutor!['cep']}", style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  print('Passando dados para CadastroTutor: $_dadosTutor');
                  await Navigator.pushNamed(context, '/cadastroTutor', arguments: _dadosTutor);
                  await _carregarDadosTutor(); // Recarrega os dados após voltar
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: const Size(200, 50)),
                child: const Text('Editar Dados', style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
              const SizedBox(height: 20),
              const Text("Pets Cadastrados:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ..._pets.map((pet) => ListTile(
                    title: Text(pet['nome']),
                    subtitle: Text("Idade: ${pet['idade']} | Sexo: ${pet['sexo']}"),

                    trailing: IconButton(
  icon: const Icon(Icons.edit),
  onPressed: () async {
    await Navigator.pushNamed(context, '/cadastroPet', arguments: pet);
    await _carregarDadosTutor(); // Recarrega os dados após editar pet
  },
),
                    //trailing: IconButton(
                      //icon: const Icon(Icons.edit),
                     // onPressed: () => Navigator.pushNamed(context, '/cadastroPet', arguments: pet),
                   // ),
                  )),
              ElevatedButton(
                onPressed: () async {
                  print('Passando id_tutor para CadastroPet: ${_dadosTutor!['id']}');
                  await Navigator.pushNamed(context, '/cadastroPet', arguments: {'id_tutor': _dadosTutor!['id']});
                  await _carregarDadosTutor(); // Recarrega os dados após cadastrar pet
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff1ebbd8), minimumSize: const Size(200, 50)),
                child: const Text('Adicionar Pet', style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
            ] else ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text("Carregando dados do tutor..."),
            ],
          ],
        ),
      ),
    );
  }
}