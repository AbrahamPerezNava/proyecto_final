import 'dart:async';
import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_final/sources/obj/product.dart';
import 'package:proyecto_final/sources/ui/shopping_cart.dart';

class ProductInfo extends StatefulWidget {
  final String? productId;
  final String user;

  ProductInfo(this.productId, this.user);

  @override
  State createState() => ProductInfoState();
}

final userReference = FirebaseDatabase.instance.reference();

class ProductInfoState extends State<ProductInfo> {
  String? piecesChoosen;

  String? image;
  String? desc;
  String? price;
  String? stock;

  List<String> items2 = [];
  int position = 0;

  int opciones = 0;

  StreamSubscription<Event>? _onProductAddedSubscription;
  StreamSubscription<Event>? _onProductChangedSubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    image = '';
    desc = '';
    price = '0';
    stock = '0';

    final productReference =
        FirebaseDatabase.instance.reference().child("producto");
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

    Widget okButton = FlatButton(
      child: Text("Aceptar"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    return Scaffold(
        backgroundColor: Colors.cyan[200],
        appBar: AppBar(
          title: Text('Información'),
          backgroundColor: Colors.cyan[800],
        ),
        body: SingleChildScrollView(
            child: Center(
                child: Container(
          padding: EdgeInsets.all(7.0),
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.white,
                alignment: Alignment.center,
                child: Image(
                  image: NetworkImage(image!),
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
                    desc!,
                    style: TextStyle(fontSize: 25.0),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  new Text(
                    "\$" + price!,
                    style: TextStyle(fontSize: 38.0),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  new Text(
                    "Existencias: ${stock!} unidades",
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
                              items2.length,
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
                      icon: Icon(Icons.monetization_on_outlined),
                      color: Colors.cyan[800]!,
                      textColor: Colors.white,
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
                        checaExistencia(widget.user, widget.productId);
                        _navigateToShoppingCart(context, widget.user);
                      }),
                ],
              )),
              SizedBox(
                height: 15.0,
              ),
            ],
          ),
        ))));
  }

  void _navigateToShoppingCart(BuildContext context, String user) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ShoppingCart(user)),
    );
  }

  void _onProductAdded(Event event) {
    setState(() {
      Product prod = Product.fromSnapShot(event.snapshot);

      if (prod.id == widget.productId) {
        image = prod.image.toString();
        desc = prod.desc.toString();
        price = double.parse(prod.price!).toStringAsFixed(2);
        stock = int.parse(prod.stock!).toString();

        print(stock);
      }

      dropdownValue = '1';

      actualizaPiezas(stock);
    });
  }

  void _onProductUpdate(Event event) {
    setState(() {
      Product prod = Product.fromSnapShot(event.snapshot);

      if (prod.id == widget.productId) {
        image = prod.image.toString();
        desc = prod.desc.toString();
        price = double.parse(prod.price!).toStringAsFixed(2);
        stock = int.parse(prod.stock!).toString();

        if (prod.stock == '0') {
          Navigator.of(context).pop();

          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Lo sentimos"),
                  content: Text("Este producto está fuera de stock"),
                  actions: [
                    FlatButton(
                      child: Text("Aceptar"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              });
        } else {
          actualizaPiezas(stock);
        }
      }
    });
  }

  void actualizaPiezas(String? stockString) {
    int stock = int.parse(stockString!);
    if (int.parse(dropdownValue) > stock) {
      dropdownValue = stockString;
    }

    items2 = [];
    for (int i = 0; i < stock; i++) {
      items2.add((i + 1).toString());
    }
  }

  void llenaOpciones() {}

  Future<void> checaExistencia(String id_user, String? id_product) async {
    print(id_user);
    await userReference
        .child('cliente/' + id_user + '/carrito/' + id_product!)
        .once()
        .then((DataSnapshot snapshot) {
      if (!snapshot.exists) {
        print('no hay carrito');
        userReference
            .child('cliente/' + id_user + '/carrito/' + id_product)
            .set({"cantidad": dropdownValue});
      } else {
        Map<dynamic, dynamic> map = snapshot.value;
        print(map.values.toList()[0]);
        int add = int.parse(map.values.toList()[0].toString());
        int newQuantity = add + int.parse(dropdownValue);
        userReference
            .child('cliente/' + id_user + '/carrito/' + id_product)
            .update({"cantidad": newQuantity});
      }
    });
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
              Icon(
                icon.icon,
                color: textColor,
              ),
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
