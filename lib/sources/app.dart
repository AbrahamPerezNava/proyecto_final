import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proyecto_final/sources/bloc/auth_cubit.dart';

import 'navigation/routes.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  static Widget create() {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSignedOut) {
          _navigatorKey.currentState
              ?.pushNamedAndRemoveUntil(Routes.inicio, (route) => false);
        } else if (state is AuthSignedIn) {
          _navigatorKey.currentState
              ?.pushNamedAndRemoveUntil(Routes.home, (route) => false);
        }
      },
      child: MyApp(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Flutter Demo',
      onGenerateRoute: Routes.routes,
    );
  }
}
