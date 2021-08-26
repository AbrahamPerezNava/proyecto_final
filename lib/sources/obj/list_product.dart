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

class ListProductState extends State<ListProduct> {
  List<Product>? items;

  StreamSubscription<Event>? _onProductAddedSubscription;
  StreamSubscription<Event>? _onProductChangedSubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    items = [];

    final productReference =
        FirebaseDatabase.instance.reference().child('producto');

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
                    subtitle: Text("\$" +
                        double.parse(items![position].price!)
                            .toStringAsFixed(2)),
                    leading: Image(
                      image: NetworkImage('${items![position].image}'),
                      height: 70,
                      width: 70,
                    ),
                    onTap: () => {
                      _navigateToProductInformation(
                          context, items![position].id, widget.user)
                    },
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
    //
  }

  void _onProductAdded(Event event) {
    setState(() {
      Product prod = Product.fromSnapShot(event.snapshot);
      int stock = int.parse(prod.stock.toString());

      if (stock > 0) {
        items?.add(prod);
      }
    });
  }

  void _onProductUpdate(Event event) {
    setState(() {
      bool contains = false;
      int located = 0;
      int stock = 0;

      Product prod = Product.fromSnapShot(event.snapshot);
      stock = int.parse(prod.stock.toString());

      for (int i = 0; i < items!.length; i++) {
        print(items![i].id);
        if (items![i].id == prod.id) {
          contains = true;
          located = i;
        }
      }

      if (contains) {
        if (stock > 0) {
          items![located] = prod;
        } else {
          items!.removeAt(located);
        }
      } else {
        if (stock > 0) {
          items?.add(prod);
        }
      }
    });
  }

  void _navigateToProductInformation(
      BuildContext context, String? product, String user) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductInfo(product, user)),
    );
  }
}
