import 'dart:async';
import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_final/sources/obj/product.dart';
import 'package:proyecto_final/sources/ui/shopping_cart.dart';

class ProductInfo extends StatefulWidget {
  final Product product;
  final String user;

  ProductInfo(this.product, this.user);

  @override
  State createState() => ProductInfoState();
}

final productReference =
    FirebaseDatabase.instance.reference().child("producto");

class ProductInfoState extends State<ProductInfo> {
  String? piecesChoosen;
  List<Product>? items;
  List<String> items2 = [];
  int position = 0;

  int opciones = 0;

  StreamSubscription<Event>? _onProductAddedSubscription;
  StreamSubscription<Event>? _onProductChangedSubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    items = [];
    _onProductAddedSubscription =
        productReference.onChildAdded.listen(_onProductAdded);
    _onProductChangedSubscription =
        productReference.onChildChanged.listen(_onProductUpdate);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _onProductAddedSubscription?.cancel();
    _onProductChangedSubscription?.cancel();
  }

  int _value = 1;
  String dropdownValue = '1';

  @override
  Widget build(BuildContext context) {
    //int position = 0;

    int pieces = int.parse(widget.product.stock.toString());

    return Scaffold(
        backgroundColor: Colors.cyan[200],
        appBar: AppBar(
          title: Text('Información'),
          backgroundColor: Colors.cyan[800],
        ),
        body: Center(
            child: Container(
          padding: EdgeInsets.all(7.0),
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.white,
                alignment: Alignment.center,
                child: Image(
                  image: NetworkImage('${items![position].image}'),
                  height: 300,
                  width: 300,
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    new Text(
                      items![position].desc.toString(),
                      style: TextStyle(fontSize: 25.0),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    new Text(
                      "\$${items![position].price!.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 38.0),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    new Text(
                      "Existencias: ${items![position].stock} unidades",
                      style: TextStyle(fontSize: 18.0),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Row(
                      children: [
                        Text('Cantidad: ', style: TextStyle(fontSize: 18.0)),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          width: 60,
                          height: 40,
                          padding: EdgeInsets.only(left: 3.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: Colors.black,
                                style: BorderStyle.solid,
                                width: 0.0),
                          ),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            underline: Container(
                              color: Colors.transparent,
                            ),
                            value: dropdownValue,
                            elevation: 16,
                            onChanged: (String? newValue) {
                              setState(() {
                                dropdownValue = newValue!;
                              });
                            },
                            items: List.generate(
                                int.parse(items![position].stock.toString()),
                                (index) => DropdownMenuItem(
                                    value: (index + 1).toString(),
                                    child: Text(
                                      (index + 1).toString(),
                                      style: TextStyle(fontSize: 18),
                                    ))),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    _Boton(
                        text: 'Comprar',
                        icon: Icon(Icons.monetization_on),
                        color: Colors.cyan[800]!,
                        textColor: Colors.black,
                        onTap: () {}),
                    SizedBox(
                      height: 15.0,
                    ),
                    _Boton(
                        text: 'Agregar al carrito',
                        icon: Icon(Icons.add_shopping_cart),
                        color: Colors.white,
                        textColor: Colors.black,
                        onTap: () {
                          _navigateToShoppingCart(context, widget.user);
                        }),
                  ],
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
            ],
          ),
        )));
  }

  void _navigateToShoppingCart(BuildContext context, String user) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ShoppingCart(user)),
    );
  }

  void _onProductAdded(Event event) {
    setState(() {
      items?.add(new Product.fromSnapShot(event.snapshot));
      actualizaPiezas();
    });
  }

  void _onProductUpdate(Event event) {
    var oldProductValuew =
        items?.singleWhere((product) => product.id == event.snapshot.key);
    setState(() {
      items![items!.indexOf(oldProductValuew!)] =
          new Product.fromSnapShot(event.snapshot);

      actualizaPiezas();
    });
  }

  void actualizaPiezas() {
    for (int i = 0; i < items!.length; i++) {
      if (items![i].id == widget.product.id) {
        position = i;
      }
    }

    for (var i = 0; i < int.parse(items![position].stock.toString()); i++) {
      items2.add((i + 1).toString());
    }
  }

  void llenaOpciones() {}
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



/*Center(
          child: Container(
        padding: EdgeInsets.all(7.0),
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.white,
              alignment: Alignment.center,
              child: Image(
                image: NetworkImage('${widget.product.image}'),
                height: 300,
                width: 300,
              ),
            ),
            SizedBox(
              height: 15.0,
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  new Text(
                    widget.product.desc.toString(),
                    style: TextStyle(fontSize: 25.0),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  new Text(
                    "\$${widget.product.price!.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 38.0),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  new Text(
                    "Existencias: ${widget.product.stock} unidades",
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Row(
                    children: [
                      Text('Cantidad: ', style: TextStyle(fontSize: 18.0)),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        width: 60,
                        height: 40,
                        padding: EdgeInsets.only(left: 3.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: Colors.black,
                              style: BorderStyle.solid,
                              width: 0.0),
                        ),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          underline: Container(
                            color: Colors.transparent,
                          ),
                          value: dropdownValue,
                          elevation: 16,
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownValue = newValue!;
                            });
                          },
                          items: List.generate(
                              items.length,
                              (index) => DropdownMenuItem(
                                  value: items[index],
                                  child: Text(
                                    items[index],
                                    style: TextStyle(fontSize: 18),
                                  ))),

                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  _Boton(
                      text: 'Comprar',
                      icon: Icon(Icons.monetization_on),
                      color: Colors.cyan[800]!,
                      textColor: Colors.black,
                      onTap: () {}),
                  SizedBox(
                    height: 15.0,
                  ),
                  _Boton(
                      text: 'Agregar al carrito',
                      icon: Icon(Icons.add_shopping_cart),
                      color: Colors.white,
                      textColor: Colors.black,
                      onTap: () {
                        _navigateToShoppingCart(context, widget.user);
                      }),
                ],
              ),
            ),
            SizedBox(
              height: 15.0,
            ),
          ],
        ),
      )

          ),*/