import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proyecto_final/sources/bloc/auth_cubit.dart';
import 'package:proyecto_final/sources/obj/globals.dart' as globals;

class EmailCreate extends StatefulWidget {
  static Widget create(BuildContext context) => EmailCreate();

  @override
  State<StatefulWidget> createState() => _EmailCreateState();
}

class _EmailCreateState extends State<EmailCreate> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _lastNameController2 = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  bool _obscureText = true;
  bool _obscureText2 = true;

  String? emailValidator(String? value) {
    return (value == null || value.trim().toString().isEmpty)
        ? 'Este campo es necesario'
        : null;
  }

  String? phoneValidator(String? value) {
    return (value == null || value.trim().length < 10)
        ? 'El número de teléfono debe tener 10 dígitos'
        : null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.trim().toString().isEmpty)
      return 'Este campo es necesario';
    if (value.length < 8)
      return 'La contraseña debe contener al menos 8 caracteres';

    if (_passwordController.text != _repeatPasswordController.text)
      return 'Las contraseñas no concuerdan';

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[200],
      appBar:
          AppBar(title: Text('Registrarse'), backgroundColor: Colors.cyan[800]),
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
                        Image.asset(
                          'assets/add-user.png',
                          width: 115,
                          height: 115,
                        ),
                        SizedBox(height: 40),
                        Text(
                          'Rellena los campos para crear una cuenta nueva',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 30),
                        TextFormField(
                          controller: _firstNameController,
                          validator: emailValidator,
                          decoration: InputDecoration(
                              icon: Icon(Icons.account_box),
                              labelText: 'Nombre'),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _lastNameController,
                          validator: emailValidator,
                          decoration: InputDecoration(
                              icon: Icon(Icons.account_box),
                              labelText: 'Apellido Paterno'),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _lastNameController2,
                          validator: emailValidator,
                          decoration: InputDecoration(
                              icon: Icon(Icons.account_box),
                              labelText: 'Apellido Materno'),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _phoneNumberController,
                          validator: phoneValidator,
                          decoration: InputDecoration(
                              icon: Icon(Icons.phone), labelText: 'Teléfono'),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                              icon: Icon(Icons.mail), labelText: 'Email'),
                          validator: emailValidator,
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
                          validator: passwordValidator,
                          obscureText: _obscureText,
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _repeatPasswordController,
                          decoration: InputDecoration(
                              icon: Icon(Icons.lock),
                              labelText: 'Repite contraseña',
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscureText2 = !_obscureText2;
                                    });
                                  },
                                  icon: !_obscureText2
                                      ? Icon(
                                          Icons.visibility,
                                          color: Colors.black,
                                        )
                                      : Icon(
                                          Icons.visibility_off,
                                          color: Colors.black,
                                        ))),
                          validator: passwordValidator,
                          obscureText: _obscureText2,
                        ),
                        SizedBox(height: 30),
                        Center(
                          child: ElevatedButton(
                              child: Text('Crear cuenta'),
                              onPressed: () {
                                if (_formKey.currentState?.validate() == true) {
                                  globals.client = _firstNameController.text +
                                      ' ' +
                                      _lastNameController.text +
                                      ' ' +
                                      _lastNameController2.text;

                                  globals.phone = _phoneNumberController.text;

                                  context
                                      .read<AuthCubit>()
                                      .createUserWithEmailAndPassword(
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
                        if (state is AuthSigningIn)
                          Center(child: CircularProgressIndicator()),
                        if (state is AuthError)
                          Text(
                            state.message,
                            style: TextStyle(color: Colors.red, fontSize: 15.0),
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
}
