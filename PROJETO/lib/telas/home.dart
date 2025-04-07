import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'PIM App',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Tutor'),
              onTap: () {
                Navigator.pushNamed(context, '/cadastroTutor');
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_hospital),
              title: const Text('Clínica'),
              onTap: () {
                Navigator.pushNamed(context, '/cadastroClinica');
              },
            ),
            ListTile(
              leading: const Icon(Icons.pets),
              title: const Text('Pet'),
              onTap: () {
                Navigator.pushNamed(context, '/cadastroPet');
              },
            ),
            ListTile(
              leading: const Icon(Icons.build),
              title: const Text('Serviço'),
              onTap: () {
                Navigator.pushNamed(context, '/cadastroServico');
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Buscar Serviço'),
              onTap: () {
                Navigator.pushNamed(context, '/buscaServico');
               },
            ),
          ],
        ),
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Bem-vindo à tela de Menu!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                 //Botão para ir para a tela de Pesquisa
                ElevatedButton(
                 onPressed: () {
                   Navigator.pushNamed(context, '/buscaServico'); // Navegando para a tela de pesquisa
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1ebbd8),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Busca Serviço',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),

                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/cadastroTutor');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1ebbd8),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Tutor',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/cadastroClinica');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1ebbd8),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Clínica',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/cadastroPet');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1ebbd8),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Pet',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/cadastroServico');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1ebbd8),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Serviço',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1ebbd8),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Sair',
                    style: TextStyle(color: Colors.white, fontSize: 20),
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
