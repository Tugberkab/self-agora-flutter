import 'package:flutter/material.dart';
import 'package:flutter_agora/src/pages/call.dart';
import 'package:flutter_agora/src/pages/index.dart';

class AppRouter {
  Route onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case '/index':
        return MaterialPageRoute(builder: (_) => const IndexPage());
      case '/call':
        return MaterialPageRoute(builder: (_) => const CallPage());
      default:
        return MaterialPageRoute(builder: (_) => const IndexPage());
    }
  }
}
