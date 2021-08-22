import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proyecto_final/sources/bloc/auth_cubit.dart';

class EmailCreate extends StatefulWidget {
  static Widget create(BuildContext context) => EmailCreate();

  @override
  State<StatefulWidget> createState() => _EmailCreateState();
}

class _EmailCreateState extends State<EmailCreate> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  bool _obscureText = true;
  bool _obscureText2 = true;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _toggle2() {
    setState(() {
      _obscureText2 = !_obscureText2;
    });
  }

  String? emailValidator(String? value) {
    return (value == null || value.isEmpty) ? 'Este campo es necesario' : null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Este campo es necesario';
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
                        if (state is AuthSigningIn)
                          Center(child: CircularProgressIndicator()),
                        if (state is AuthError)
                          Text(
                            state.message,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 24,
                            ),
                          ),
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
                          decoration: InputDecoration(
                              icon: Icon(Icons.account_box),
                              labelText: 'Nombre'),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                              icon: Icon(Icons.account_box),
                              labelText: 'Apellido Paterno'),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                              icon: Icon(Icons.account_box),
                              labelText: 'Apellido Materno'),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _phoneNumberController,
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
                              icon: Icon(Icons.lock), labelText: 'Contraseña'),
                          validator: passwordValidator,
                          obscureText: _obscureText,
                        ),
                        new FlatButton(
                            onPressed: _toggle,
                            child: new Text(_obscureText ? "Abc" : "***")),
                        SizedBox(height: 5),
                        TextFormField(
                          controller: _repeatPasswordController,
                          decoration: InputDecoration(
                              icon: Icon(Icons.lock),
                              labelText: 'Repite contraseña'),
                          validator: passwordValidator,
                          obscureText: _obscureText2,
                        ),
                        new FlatButton(
                            onPressed: _toggle2,
                            child: new Text(_obscureText2 ? "Abc" : "***")),
                        SizedBox(height: 30),
                        Center(
                          child: ElevatedButton(
                              child: Text('Crear cuenta'),
                              onPressed: () {
                                if (_formKey.currentState?.validate() == true) {
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
