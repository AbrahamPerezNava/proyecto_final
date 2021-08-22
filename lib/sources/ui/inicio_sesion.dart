import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proyecto_final/sources/bloc/auth_cubit.dart';
import 'package:proyecto_final/sources/navigation/routes.dart';

class InicioSesion extends StatelessWidget {
  static Widget create(BuildContext context) => InicioSesion();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan[800],
        title: Text('Iniciar Sesión'),
      ),
      body: Center(
        child: PageView(
          children: [_SignIn()],
        ),
      ),
    );
  }
}

class _SignIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isSigningIn = context.watch<AuthCubit>().state is AuthSigningIn;

    return Container(
      padding: EdgeInsets.all(24.0),
      color: Colors.cyan[200],
      child: AbsorbPointer(
        absorbing: isSigningIn,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 50),
            Image.asset(
              'assets/log-in.png',
              width: 200,
              height: 200,
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  'Inicia sesión o crea una cuenta nueva',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (isSigningIn) CircularProgressIndicator(),

            /*   _BotonInicioSesion(
              text: 'Iniciar sesión de prueba',
              imagePath: 'assets/question.png',
              color: Colors.lightBlue[100]!,
              textColor: Colors.black,
              onTap: () {
                //todo
              }),
*/

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Column(
                children: [
                  _BotonInicioSesion(
                    text: 'Iniciar sesión con Google',
                    imagePath: 'assets/google.png',
                    color: Colors.white,
                    textColor: Colors.black,
                    onTap: () => context.read<AuthCubit>().signInWithGoogle(),
                  ),
                  SizedBox(height: 8),
                  _BotonInicioSesion(
                      text: 'Iniciar sesión con email',
                      imagePath: 'assets/email.png',
                      color: Colors.cyan[800]!,
                      textColor: Colors.black,
                      onTap: () {
                        context.read<AuthCubit>().reset();
                        Navigator.pushNamed(context, Routes.signInEmail);
                      }),
                  /*SizedBox(height: 8),
                  _BotonInicioSesion(
                    text: 'Iniciar sesión de prueba',
                    imagePath: 'assets/question.png',
                    color: Colors.purple[200]!,
                    textColor: Colors.black,
                    onTap: () => context.read<AuthCubit>().signInAnonymously(),
                  ),*/
                  SizedBox(height: 50),
                  OutlineButton(
                      child: Text('Crear cuenta nueva'),
                      onPressed: () {
                        context.read<AuthCubit>().reset();
                        Navigator.pushNamed(context, Routes.createAccount);
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
      //padding: EdgeInsets.all(24.0),
    );
  }
}

class _BotonInicioSesion extends StatelessWidget {
  final String text;
  final String imagePath;
  final Color color;
  final Color textColor;
  final VoidCallback? onTap;

  const _BotonInicioSesion({
    Key? key,
    required this.text,
    required this.imagePath,
    this.color = Colors.blue,
    this.textColor = Colors.white,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      elevation: 3,
      borderRadius: BorderRadius.all(Radius.circular(20)),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              Image.asset(
                imagePath,
                width: 24,
                height: 24,
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
