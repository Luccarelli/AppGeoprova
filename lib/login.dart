import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:project_test/favoritos_screen.dart';
import 'database_helper.dart';
//import 'homePage.dart';
//import 'obras.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController loginController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  void saveLoginInfo(String login, String senha) async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnLogin: login,
      DatabaseHelper.columnPassword: senha,
    };
    int id = await DatabaseHelper.instance.insert(row);
    print('Registro inserido com ID: $id');
  }

  Future<String> fazerLogin(String login, String senha) async {
    final url = Uri.parse('https://geoprova.eaglesgroup.com.br/api/login');
    final headers = {
      'Content-Type': 'application/json',
      'x-api-key':
          'minhaChaveDeApiSuperSegura123', // Substitua pela sua chave de API
    };
    final body = jsonEncode({"login": login, "senha": senha});

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      print('Resposta da API: ${response.body}');

      final trimmedResponse = response.body.trim();
      final responseData = jsonDecode(trimmedResponse);

      return responseData['message'].toString();
    } else {
      print('Resposta da API: ${response.body}');

      final responseData = jsonDecode(response.body);
      return responseData['message'].toString();
    }
  }

  @override
  void initState() {
    super.initState();
    // Verificar o status de login no início da tela
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
      // Aqui, você pode prosseguir para a tela principal automaticamente.
      // Substitua "HomePage()" pela sua tela inicial real, caso o nome seja diferente.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ObrasFavoritas()),
      );
    } else {
      // Caso não exista nenhum registro no banco de dados, é o primeiro acesso ou o usuário fez logout anteriormente.
      // Você pode redirecionar o usuário para a tela de login neste caso.
      print('Nenhum login salvo. Redirecionar para a tela de login.');
      // Aqui, você pode redirecionar o usuário para a tela de login.
    }
  }

  void _showTopSnackBar(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER_RIGHT,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context)
              .unfocus(); // Remove o foco dos campos de texto e oculta o teclado
        },
        child: Center(
          // Centraliza o conteúdo verticalmente e horizontalmente
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  child: Image.asset('assets/img/geoprova_login.png'),
                ),
                SizedBox(height: 35),
                Container(
                  decoration: BoxDecoration(
                    color: Colors
                        .white, // Cor do fundo do Container (pode ser a mesma cor do seu background)
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: loginController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Login',
                      border: OutlineInputBorder(
                        borderSide:
                            BorderSide.none, // Remova a borda do TextField
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors
                        .white, // Cor do fundo do Container (pode ser a mesma cor do seu background)
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: senhaController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(
                        borderSide:
                            BorderSide.none, // Remova a borda do TextField
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24), // Espaço entre o campo de senha e o botão
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      String result = await fazerLogin(
                        loginController.text,
                        senhaController.text,
                      );
                      _showTopSnackBar(result);

                      if (result == 'Login bem-sucedido!') {
                        saveLoginInfo(
                            loginController.text, senhaController.text);

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ObrasFavoritas(),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      primary: Colors.orange,
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: Text(
                      'Entrar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
