import 'package:flutter/material.dart';
import 'login.dart';
import 'favoritos_screen.dart';
import 'database_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'obras.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _loggedOut = false;
  String _loggedInUser = '';

  @override
  void initState() {
    super.initState();
    _fetchLoggedInUser();
  }

  void _fetchLoggedInUser() async {
    List<Map<String, dynamic>> rows =
        await DatabaseHelper.instance.queryAllRows();
    if (rows.isNotEmpty) {
      setState(() {
        _loggedInUser = rows[0][DatabaseHelper.columnLogin];
      });
    }
  }

  void logout(BuildContext context) async {
    if (!_loggedOut) {
      Fluttertoast.showToast(
        msg: 'Logout efetuado com sucesso!', // Mensagem a ser exibida
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER_RIGHT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      print('Realizando o logout...');
      int rowsDeleted = await DatabaseHelper.instance.deleteAll();
      print('Linhas deletadas: $rowsDeleted');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginForm()),
      );
      setState(() {
        _loggedOut = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.orange),
            child: Center(
              child: Text(
                _loggedInUser,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          // ListTile(
          //   leading: Icon(Icons.home),
          //   title: Text('Obras cadastradas'),
          //   onTap: () {
          //     Navigator.pushReplacement(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => HomePage(),
          //       ),
          //     );
          //   },
          // ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Contratos (Obras)'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => Obras(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.star),
            title: Text('Obras favoritas'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ObrasFavoritas(),
                ),
              );
            },
          ),
          Spacer(), // Adiciona um espaço flexível para empurrar o Logout para o final
          ListTile(
            leading:
                Icon(Icons.logout, color: Colors.red), // Define a cor do ícone
            title: Text(
              'Logout',
              style: TextStyle(color: Colors.red), // Define a cor do texto
            ),
            onTap: () {
              logout(context);
            },
          ),
        ],
      ),
    );
  }
}
