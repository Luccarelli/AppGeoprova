import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:project_test/routes.dart';
import 'notification_service.dart';
import 'package:http/http.dart' as http;

class FirebaseMessagingService {
  final NotificationService _notificationService;

  FirebaseMessagingService(this._notificationService);

  Future<void> initialize() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      badge: true,
      sound: true,
      alert: true,
    );

    await getDeviceFirebaseToken(); // Aguarde a obtenção do token
    _onMessage();
    _onMessageOpenedApp();
  }

  Future<void> getDeviceFirebaseToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    debugPrint('=======================================');
    debugPrint('TOKEN: $token');
    debugPrint('=======================================');

    if (token != null) {
      await sendTokenToServer(token);
    }
  }

  _onMessage() {
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _notificationService.showLocalNotification(
          CustomNotification(
            id: android.hashCode,
            title: notification.title!,
            body: notification.body!,
            payload: message.data['route'] ?? '',
          ),
        );
      }
    });
  }

  _onMessageOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen(_goToPageAfterMessage);
  }

  _goToPageAfterMessage(message) {
    final String route = message.data['route'] ?? '';
    if (route.isNotEmpty) {
      Routes.navigatorKey?.currentState?.pushNamed(route);
    }
  }

  Future<void> sendTokenToServer(String token) async {
    final apiUrl =
        'https://geoprova.eaglesgroup.com.br/api/savetoken'; // Substitua pela URL correta
    final headers = {
      'Content-Type': 'application/json',
      'x-api-key': 'minhaChaveDeApiSuperSegura123',
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: '{"token": "$token"}', // Envie o corpo como JSON
    );

    if (response.statusCode == 201) {
      debugPrint('Token enviado com sucesso para o servidor.');
    } else {
      debugPrint(
          'Falha ao enviar o token para o servidor. Código de resposta: ${response.statusCode}');
    }
  }
}
