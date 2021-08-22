import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  static Widget create(BuildContext context) => SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/stationery.png',
              width: 200,
              height: 200,
            ),
            SizedBox(height: 24),
            Text('Cargando...', style: TextStyle(fontSize: 24))
          ],
        ),
      ),
    );
  }
}
