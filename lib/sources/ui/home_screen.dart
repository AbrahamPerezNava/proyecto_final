import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_final/sources/obj/globals.dart' as globals;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proyecto_final/sources/bloc/auth_cubit.dart';
import 'package:proyecto_final/sources/obj/list_product.dart';
import 'package:proyecto_final/sources/ui/search_screen.dart';
import 'package:proyecto_final/sources/ui/shopping_cart.dart';
import 'package:proyecto_final/sources/ui/shopping_record.dart';

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
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        buildWhen: (previous, current) => current is AuthSignedIn,
        builder: (_, state) {
          //final authUser = (state as AuthSignedIn).user;

          id_user = globals.user;
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
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
                decoration: BoxDecoration(color: Color(0xFF00838F)),
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'Hola denuevo ' + globals.client.split(' ').first,
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.white, fontSize: 26.0),
                      ),
                      Icon(
                        Icons.account_box,
                        size: 58.0,
                        color: Colors.white,
                      )
                    ],
                  ),
                )),
            ListTile(
              title: const Text('Carrito de compra'),
              leading: Icon(Icons.shopping_cart),
              onTap: () {
                Navigator.pop(context);
                _navigateToShoppingCart(context, id_user);
              },
            ),
            ListTile(
              title: const Text('Compras'),
              leading: Icon(Icons.shopping_basket),
              onTap: () {
                Navigator.pop(context);
                _navigateToShoppingRecord(context);
              },
            ),
            ListTile(
              title: const Text('Cerrar sesión'),
              leading: Icon(Icons.power_settings_new),
              onTap: () {
                Navigator.pop(context);

                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return alert;
                    });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToShoppingCart(BuildContext context, String user) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ShoppingCart(user)),
    );
  }

  void _navigateToShoppingRecord(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ShoppingRecord()),
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
