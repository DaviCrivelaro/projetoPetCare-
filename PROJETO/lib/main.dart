import 'package:flutter/material.dart';
import 'package:flutter_pim/busca_servico.dart';
import 'package:flutter_pim/cadastro_pet.dart';
import 'package:flutter_pim/cadastro_servico.dart';
import 'package:flutter_pim/telas/cadastro_clinica.dart';
import 'package:flutter_pim/telas/home.dart';
import 'package:flutter_pim/telas/cadastro_usuario.dart';
import 'package:flutter_pim/telas/login.dart';
import 'package:flutter_pim/cadastro_tutor.dart';

 
void main() {
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
        '/home': (context) => const Home(),
        '/cadastroUsuario': (context) => CadastroUsuario(),
        '/cadastroClinica': (context) => const CadastroClinica(),
        '/cadastroTutor': (context) => const CadastroTutor(),
        '/cadastroPet': (context) => const CadastroPet(),
        '/cadastroServico': (context) => const CadastroServico(),
        '/buscaServico': (context) => const ConsultaServico(), 
      },
    );
  }
}
