import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_final/sources/obj/product.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:proyecto_final/sources/ui/product_info.dart';

class ListProduct extends StatefulWidget {
  final String user;
  ListProduct(this.user);
  @override
  State<StatefulWidget> createState() => ListProductState();
}

final productReference =
    FirebaseDatabase.instance.reference().child('producto');

class ListProductState extends State<ListProduct> {
  List<Product>? items;

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

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items?.length,
      padding: EdgeInsets.all(7.0),
      itemBuilder: (context, position) {
        return Column(
          children: <Widget>[
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 10,
              child: Column(
                children: <Widget>[
                  ListTile(
                    contentPadding: EdgeInsets.all(5.0),
                    title: Text('${items![position].desc}'),
                    subtitle:
                        Text("\$" + items![position].price!.toStringAsFixed(2)),
                    leading: Image(
                      image: NetworkImage('${items![position].image}'),
                      height: 70,
                      width: 70,
                    ),
                    onTap: () => {
                      _navigateToProductInformation(
                          context, items![position], widget.user)
                    },
                  ),

                  /*new Text(
                    '${items![position].desc}',
                    style: TextStyle(
                      fontSize: 21.0,
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(top: 8.0)),
                  new Text(
                    '\$${items![position].price}',
                    style: TextStyle(
                      fontSize: 21.0,
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(top: 8.0)),
                  new Text(
                    '${items![position].stock} disponibles',
                    style: TextStyle(
                      fontSize: 21.0,
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(top: 8.0)),*/
                ],
              ),
            )
          ],
          /* children: <Widget>[
            Divider(
              height: 7.0,
            ),
            Row(
              children: <Widget>[
                Expanded(
                    child: ListTile(
                  title: Text(
                    '${items![position].desc}',
                    style: TextStyle(
                      fontSize: 21.0,
                    ),
                  ),
                  subtitle: Text(
                    '${items![position].price}',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                  leading: Column(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.orange,
                        radius: 17.0,
                        child: Text(
                          '${items![position].stock}',
                          style: TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                      )
                    ],
                  ),
                  onTap: () => {
                    _navigateToProductInformation(context, items![position])
                  },
                ))
              ],
            )
          ],*/
        );
      },
    );
    //
  }

  void _onProductAdded(Event event) {
    setState(() {
      items?.add(new Product.fromSnapShot(event.snapshot));
    });
  }

  void _onProductUpdate(Event event) {
    var oldProductValuew =
        items?.singleWhere((product) => product.id == event.snapshot.key);
    setState(() {
      items![items!.indexOf(oldProductValuew!)] =
          new Product.fromSnapShot(event.snapshot);
    });
  }

  void _navigateToProductInformation(
      BuildContext context, Product product, String user) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductInfo(product, user)),
    );
  }
}
