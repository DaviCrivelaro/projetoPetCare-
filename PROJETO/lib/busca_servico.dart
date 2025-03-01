import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_pim/config.dart';
import 'package:http/http.dart' as http;

class ConsultaServico extends StatefulWidget {
  const ConsultaServico({super.key});

  @override
  _ConsultaServicoState createState() => _ConsultaServicoState();
}

class _ConsultaServicoState extends State<ConsultaServico> {
  final TextEditingController _controllerNomeServico = TextEditingController();
  final TextEditingController _controllerIdTutor = TextEditingController();
  List<dynamic> _servicos = [];
  String _mensagemErro = "";

  Future<void> _buscarServicos() async {
    final url = Uri.parse('$serverIP/busca_servico.php'); // Altere para o IP do seu servidor
    try {
      final response = await http.post(
        url,
        body: {
          'nome_servico': _controllerNomeServico.text,
          'id_tutor': _controllerIdTutor.text, // Adicionado campo ID do tutor
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success']) {
          setState(() {
            _servicos = data['data'];
            _mensagemErro = "";
          });
        } else {
          setState(() {
            _mensagemErro = data['message'];
            _servicos = [];
          });
        }
      } else {
        setState(() {
          _mensagemErro = "Erro ao buscar serviços. Tente novamente.";
          _servicos = [];
        });
      }
    } catch (e) {
      setState(() {
        _mensagemErro = "Erro ao buscar serviços. Tente novamente.";
        _servicos = [];
      });
    }
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
                  controller: _controllerIdTutor,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(32, 10, 32, 10),
                    hintText: "ID do Tutor",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                        title: Text(servico['razao_social']),
                        //subtitle: Text("Telefone: ${servico['telefone']}\nServiço: ${servico['nome_servico']}"),
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
