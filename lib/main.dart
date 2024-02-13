import 'package:flutter/material.dart';
//import 'package:project_test/notifications/firebase_api.dart';
import 'login.dart';
//import 'homePage.dart';
import 'database_helper.dart';
import 'favoritos_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';
import 'routes.dart';
import 'package:provider/provider.dart';
import 'notifications/firebase_messaging_service.dart';
import 'notifications/notification_service.dart';

void main() async {
  Routes.navigatorKey = GlobalKey<NavigatorState>();
  WidgetsFlutterBinding.ensureInitialized();
  PermissionStatus status = await Permission.notification.request();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        Provider<NotificationService>(
          create: (context) => NotificationService(),
        ),
        Provider<FirebaseMessagingService>(
          create: (context) =>
              FirebaseMessagingService(context.read<NotificationService>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: Routes.navigatorKey,
      initialRoute: Routes.initial,
      routes: Routes.list,
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
    initilizeFirebaseMessaging();
    checkNotifications();
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

  initilizeFirebaseMessaging() async {
    await Provider.of<FirebaseMessagingService>(context, listen: false)
        .initialize();
  }

  checkNotifications() async {
    await Provider.of<NotificationService>(context, listen: false)
        .checkForNotifications();
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
