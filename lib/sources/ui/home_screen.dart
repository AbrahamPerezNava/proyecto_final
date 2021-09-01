import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_final/sources/obj/globals.dart' as globals;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proyecto_final/sources/bloc/auth_cubit.dart';
import 'package:proyecto_final/sources/obj/list_product.dart';
import 'package:proyecto_final/sources/ui/search_screen.dart';
import 'package:proyecto_final/sources/ui/shopping_cart.dart';

class HomeScreen extends StatelessWidget {
  final databaseReference = FirebaseDatabase.instance;
  static Widget create(BuildContext context) => HomeScreen();
  String id_user = '';
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Widget cancelButton = FlatButton(
      child: Text("No"),
      color: Colors.blue[100],
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Si"),
      color: Colors.red,
      textColor: Colors.white,
      onPressed: () {
        context.read<AuthCubit>().signOut();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Advertencia"),
      content: Text("¿Seguro que quieres cerrar sesión?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    return Scaffold(
      backgroundColor: Colors.cyan[200],
      appBar: AppBar(
        title: Text('Productos'),
        backgroundColor: Colors.cyan[800],
        actions: <Widget>[
          IconButton(
              onPressed: () {
                _navigateToShoppingCart(context, id_user);
              },
              icon: Icon(Icons.shopping_cart)),
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return alert;
                    });
              },
              icon: Icon(Icons.power_settings_new))
        ],
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        buildWhen: (previous, current) => current is AuthSignedIn,
        builder: (_, state) {
          final authUser = (state as AuthSignedIn).user;
          globals.user = authUser.uid;
          globals.email = authUser.email;

          id_user = authUser.uid;
          return Center(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: controller,
                        textInputAction: TextInputAction.go,
                        onSubmitted: (value) {
                          controller.clear();
                          searchProduct(context, value, id_user);
                        },
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                            hintText: 'Buscar'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListProduct(id_user),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  void _navigateToShoppingCart(BuildContext context, String user) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ShoppingCart(user)),
    );
  }

  void searchProduct(
      BuildContext context, String searchString, String user) async {
    if (!searchString.trim().isEmpty) {
      await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SearchScreen(searchString, user)),
      );
    }
  }
}
