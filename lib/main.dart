import 'package:flutter/material.dart';
import 'login.dart';
//import 'homePage.dart';
import 'database_helper.dart';
import 'favoritos_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      title: 'Seu Aplicativo',
      home: AppInitializer(),
    );
  }
}

class AppInitializer extends StatefulWidget {
  @override
  _AppInitializerState createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    List<Map<String, dynamic>> rows =
        await DatabaseHelper.instance.queryAllRows();
    if (rows.isNotEmpty) {
      // Caso exista algum registro no banco de dados, significa que o usuário já fez login anteriormente.
      // Você pode recuperar as informações de login aqui e fazer o auto login.
      String login = rows[0][DatabaseHelper.columnLogin];
      String password = rows[0][DatabaseHelper.columnPassword];
      print('Login salvo: $login, Senha salva: $password');
      // Redirecionar para a tela principal após o login bem-sucedido
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ObrasFavoritas(),
        ),
      );
    } else {
      // Caso não exista nenhum registro no banco de dados, é o primeiro acesso ou o usuário fez logout anteriormente.
      // Redirecionar para a tela de login neste caso.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginForm(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
