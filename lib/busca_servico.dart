import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:geolocator/geolocator.dart';

class ConsultaServico extends StatefulWidget {
  const ConsultaServico({super.key});

  @override
  _ConsultaServicoState createState() => _ConsultaServicoState();
}

class _ConsultaServicoState extends State<ConsultaServico> {
  final TextEditingController _controllerNomeServico = TextEditingController();
  List<dynamic> _servicos = [];
  String _mensagemErro = "";

  // Configuração do banco na nuvem
  final _settings = ConnectionSettings(
    host: '34.46.224.119',
    port: 3306,
    user: 'root',
    password: '{;&AOd):6YT]~7j9',
    db: 'flutter_pim',
  );

  Future<void> _buscarServicos() async {
    String nomeServico = _controllerNomeServico.text;

    // Validação do parâmetro
    if (nomeServico.isEmpty) {
      setState(() {
        _mensagemErro = "Preencha o nome do serviço.";
        _servicos = [];
      });
      return;
    }

    try {
      // Obter a localização atual do dispositivo
      Position position = await _determinePosition();
      double userLatitude = position.latitude;
      double userLongitude = position.longitude;

      final conn = await MySqlConnection.connect(_settings);

      // Consulta principal ajustada para usar a localização do GPS
      String query = '''
        SELECT 
          s.nome_servico, 
          c.razao, 
          c.telefone, 
          (6371 * ACOS(
            COS(RADIANS(?)) * COS(RADIANS(e_clinica.latitude)) *
            COS(RADIANS(e_clinica.longitude) - RADIANS(?)) +
            SIN(RADIANS(?)) * SIN(RADIANS(e_clinica.latitude))
          )) AS distancia
        FROM 
          servico s
        JOIN 
          clinica c ON s.idclinica = c.idclinica
        JOIN 
          endereco e_clinica ON c.idEndereco = e_clinica.idEndereco
        WHERE 
          s.nome_servico LIKE ?
        ORDER BY 
          distancia ASC
        LIMIT 3
      ''';

      String nomeServicoParam = '%$nomeServico%';
      var results = await conn.query(query, [
        userLatitude,  // Latitude do usuário (GPS)
        userLongitude, // Longitude do usuário (GPS)
        userLatitude,  // Para o cálculo
        nomeServicoParam, // Nome do serviço
      ]);

      if (results.isNotEmpty) {
        setState(() {
          _servicos = results.map((row) => {
            'nome_servico': row[0],
            'razao': row[1],
            'telefone': row[2],
            'distancia': (row[3] as double).toStringAsFixed(2) + ' Km',
          }).toList();
          _mensagemErro = "";
        });
      } else {
        setState(() {
          _mensagemErro = "Nenhum serviço encontrado.";
          _servicos = [];
        });
      }

      await conn.close();
    } catch (e) {
      setState(() {
        _mensagemErro = "Erro ao buscar serviços: $e";
        _servicos = [];
      });
    }
  }

  // Função para obter a localização atual do dispositivo
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar se o serviço de localização está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Os serviços de localização estão desativados.';
    }

    // Verificar permissões
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Permissão de localização negada.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Permissão de localização negada permanentemente. Por favor, habilite nas configurações.';
    }

    // Obter a posição atual
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Consulta de Serviços", style: TextStyle(color: Colors.white)),
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
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1ebbd8),
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 50),
                    ),
                    onPressed: _buscarServicos,
                    child: const Text(
                      "Buscar",
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (_mensagemErro.isNotEmpty)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        _mensagemErro,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  ),
                Container(
                  color: Colors.white,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _servicos.length,
                    itemBuilder: (context, index) {
                      final servico = _servicos[index];
                      return ListTile(
                        title: Text(servico['razao']),
                        subtitle: Text(
                          "Telefone: ${servico['telefone']}\nServiço: ${servico['nome_servico']}\nDistância: ${servico['distancia']}",
                        ),
                      );
                    },
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