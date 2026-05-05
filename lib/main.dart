import 'package:flutter/material.dart';
import 'screens/user_list_screen.dart';

void main() {
  runApp(const cadastro_usuarios());
}

class cadastro_usuarios extends StatelessWidget {
  const cadastro_usuarios({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro de Usuários',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const UserListScreen(),
    );
  }
}
