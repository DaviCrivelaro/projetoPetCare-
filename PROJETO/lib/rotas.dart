import 'package:flutter/material.dart';
import 'package:flutter_pim/busca_servico.dart';
import 'package:flutter_pim/cadastro_pet.dart';
import 'package:flutter_pim/cadastro_servico.dart';
import 'package:flutter_pim/telas/cadastro_clinica.dart';
import 'package:flutter_pim/telas/home.dart';
import 'package:flutter_pim/telas/cadastro_usuario.dart';
import 'package:flutter_pim/telas/login.dart';
import 'package:flutter_pim/cadastro_tutor.dart';

class Rotas {
  static Route<dynamic> gerarRotas(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const Login());
      case '/home':
        return MaterialPageRoute(builder: (_) => const Home());
      case '/cadastroUsuario':
        return MaterialPageRoute(builder: (_) => CadastroUsuario());
      case '/cadastroClinica':
        return MaterialPageRoute(builder: (_) => const CadastroClinica());
      case '/cadastroTutor':
        return MaterialPageRoute(builder: (_) => const CadastroTutor());
      case '/cadastroPet':
        return MaterialPageRoute(builder: (_) => const CadastroPet());
      case '/cadastroServico':
        return MaterialPageRoute(builder: (_) => const CadastroServico());
      case '/buscaServico': // Adicione esta linha
        return MaterialPageRoute(builder: (_) => const ConsultaServico()); // E esta linha
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Rota não encontrada: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
