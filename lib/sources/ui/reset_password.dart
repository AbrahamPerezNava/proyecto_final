import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proyecto_final/sources/bloc/auth_cubit.dart';

class ResetPassword extends StatefulWidget {
  static Widget create(BuildContext context) => ResetPassword();

  @override
  State<StatefulWidget> createState() => ResetPasswordState();
}

class ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  String? validator(String? value) {
    return (value == null || value.trim().isEmpty)
        ? 'Este campo es necesario'
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.cyan[200],
        appBar: AppBar(
            title: Text('Restablecer contraseña'),
            backgroundColor: Colors.cyan[800]),
        body: SingleChildScrollView(
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
                        'Ingresa el email con el que te registraste',
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
                      Center(
                        child: ElevatedButton(
                            child: Text('Recupera conraseña'),
                            onPressed: () {
                              if (_formKey.currentState?.validate() == true) {
                                print('hola');
                                context
                                    .read<AuthCubit>()
                                    .sendPasswordResetEmail(
                                        _emailController.text);

                                Navigator.of(context).pop();

                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Aviso"),
                                        content: Text(
                                            "Si tu emaiil está registrado en nuestra aplicación recibiras un correo con instrucciones para reestablecer tu contraseña"),
                                        actions: [
                                          FlatButton(
                                            child: Text("Aceptar"),
                                            color: Colors.blue[100],
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          )
                                        ],
                                      );
                                    });
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.cyan[800]!),
                            )),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
