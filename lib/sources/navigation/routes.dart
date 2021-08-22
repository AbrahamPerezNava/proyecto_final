import 'package:flutter/material.dart';
import 'package:proyecto_final/sources/ui/email_create_screen.dart';
import 'package:proyecto_final/sources/ui/email_signin_screen.dart';
import 'package:proyecto_final/sources/ui/home_screen.dart';
import 'package:proyecto_final/sources/ui/inicio_sesion.dart';
import 'package:proyecto_final/sources/ui/product_info.dart';
import 'package:proyecto_final/sources/ui/splash_screen.dart';

class Routes {
  static const splash = '/';
  static const inicio = '/inicio';
  static const home = '/home';
  static const createAccount = '/createAccount';
  static const signInEmail = '/signInEmail';
  static const productInfo = '/productInfo';

  static Route routes(RouteSettings routeSettings) {
    print('Route name: ${routeSettings.name}');
    switch (routeSettings.name) {
      case splash:
        return _buildRoute(SplashScreen.create);

      case inicio:
        return _buildRoute(InicioSesion.create);

      case home:
        return _buildRoute(HomeScreen.create);

      case createAccount:
        return _buildRoute(EmailCreate.create);

      case signInEmail:
        return _buildRoute(EmailSignIn.create);

      default:
        throw Exception('La ruta no existe');
    }
  }

  static MaterialPageRoute _buildRoute(Function build) =>
      MaterialPageRoute(builder: (context) => build(context));
}
