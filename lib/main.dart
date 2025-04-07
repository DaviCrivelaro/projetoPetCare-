import 'package:flutter/material.dart';
import 'package:flutter_pim/busca_servico.dart';
import 'package:flutter_pim/cadastro_pet.dart';
import 'package:flutter_pim/cadastro_servico.dart';
import 'package:flutter_pim/telas/cadastro_clinica.dart';
import 'package:flutter_pim/telas/cadastro_usuario.dart';
import 'package:flutter_pim/telas/login.dart';
import 'package:flutter_pim/cadastro_tutor.dart';
import 'package:flutter_pim/home_tutor.dart';
import 'package:flutter_pim/home_clinica.dart';
import 'package:flutter_pim/config.dart'; // Import do config.dart

void main() async {
  await Config.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PIM',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const Login(),
        '/homeTutor': (context) => const HomeTutor(), // Const apenas se não passar argumentos diretamente aqui
        '/homeClinica': (context) => const HomeClinica(), // Const apenas se não passar argumentos diretamente aqui
        '/cadastroUsuario': (context) => const CadastroUsuario(),
        '/cadastroClinica': (context) => const CadastroClinica(),
        '/cadastroTutor': (context) => const CadastroTutor(),
        '/cadastroPet': (context) => const CadastroPet(),
        '/cadastroServico': (context) => const CadastroServico(),
        '/buscaServico': (context) => const ConsultaServico(),
      },
    );
  }
}