import 'package:flutter/material.dart';
import 'favoritos_screen.dart';
import 'obras.dart';

class Routes {
  static Map<String, Widget Function(BuildContext)> list =
      <String, WidgetBuilder>{
    '/obras': (_) => const Obras(),
    '/favoritos': (_) => const ObrasFavoritas(),
  };

  static String initial = '/favoritos';

  static GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();
}
