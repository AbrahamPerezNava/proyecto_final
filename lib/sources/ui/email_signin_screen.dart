import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proyecto_final/sources/bloc/auth_cubit.dart';
import 'package:proyecto_final/sources/ui/reset_password.dart';

class EmailSignIn extends StatefulWidget {
  static Widget create(BuildContext context) => EmailSignIn();

  @override
  State<StatefulWidget> createState() => _EmailSignInState();
}

class _EmailSignInState extends State<EmailSignIn> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscureText = true;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  String? validator(String? value) {
    return (value == null || value.isEmpty) ? 'Este campo es necesario' : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[200],
      appBar: AppBar(
          title: Text('Iniciar sesión'), backgroundColor: Colors.cyan[800]),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (_, state) {
          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        SizedBox(height: 70),
                        Image.asset(
                          'assets/sign-in.png',
                          width: 115,
                          height: 115,
                        ),
                        SizedBox(height: 40),
                        Text(
                          'Ingresa tu email y tu contraseña',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 30),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            icon: Icon(Icons.email),
                            //labelStyle: TextStyle(color: Colors.cyan[800]),
                            labelText: 'Email',
                          ),
                          validator: validator,
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                              icon: Icon(Icons.lock),
                              labelText: 'Contraseña',
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                  icon: !_obscureText
                                      ? Icon(
                                          Icons.visibility,
                                          color: Colors.black,
                                        )
                                      : Icon(
                                          Icons.visibility_off,
                                          color: Colors.black,
                                        ))),
                          validator: validator,
                          obscureText: _obscureText,
                        ),
                        SizedBox(height: 30),
                        Center(
                          child: ElevatedButton(
                              child: Text('Iniciar sesión'),
                              onPressed: () {
                                if (_formKey.currentState?.validate() == true) {
                                  context
                                      .read<AuthCubit>()
                                      .signInUserWithEmailAndPassword(
                                          _emailController.text,
                                          _passwordController.text);
                                }
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.cyan[800]!),
                              )),
                        ),
                        SizedBox(height: 15),
                        Center(
                          child: TextButton(
                            child: Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(color: Colors.black),
                            ),
                            onPressed: () {
                              _navigateToReset(context);
                            },
                          ),
                        ),
                        if (state is AuthSigningIn)
                          Center(child: CircularProgressIndicator()),
                        if (state is AuthError)
                          Text(
                            state.message,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 15.0,
                            ),
                          ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  void _navigateToReset(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResetPassword()),
    );
  }
}
