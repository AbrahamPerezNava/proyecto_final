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
          children: <Widget>[
            Container(
              child: Column(
                children: [Text(widget.user)],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          child: Container(
        height: 115.0, //set your height here
        width: double.maxFinite, //set your width here
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(7.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: TextStyle(fontSize: 28.0),
                  ),
                  Text(
                    '\$345.00',
                    style: TextStyle(fontSize: 28.0),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(7.0),
              child: Column(
                children: [
                  _Boton(
                      text: 'Continuar con la compra',
                      icon: Icon(Icons.payment),
                      color: Colors.cyan[800]!,
                      textColor: Colors.black,
                      onTap: () {}),
                ],
              ),
            )
            //add as many tabs as you want here
          ],
        ),
      )),
    );
  }
}

class _Boton extends StatelessWidget {
  final String text;
  final Icon icon;
  final Color color;
  final Color textColor;
  final VoidCallback? onTap;

  const _Boton({
    Key? key,
    required this.text,
    required this.icon,
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
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon.icon),
              SizedBox(
                width: 5,
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
