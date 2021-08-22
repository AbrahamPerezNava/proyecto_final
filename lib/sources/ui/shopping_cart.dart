import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShoppingCart extends StatefulWidget {
  final String user;

  ShoppingCart(this.user);

  @override
  State<StatefulWidget> createState() => ShoppingCartState();
}

class ShoppingCartState extends State<ShoppingCart> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[200],
      appBar: AppBar(
        title: Text('Carrito de compra'),
        backgroundColor: Colors.cyan[800],
        actions: <Widget>[
          IconButton(onPressed: () {}, icon: Icon(Icons.receipt)),
        ],
      ),
      body: Center(
        child: Column(
          children: <Widget>[Text(widget.user)],
        ),
      ),
    );
  }
}
