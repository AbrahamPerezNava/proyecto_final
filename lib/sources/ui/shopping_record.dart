import 'dart:async';
import 'package:proyecto_final/sources/obj/globals.dart' as globals;

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_final/sources/obj/product_on_cart.dart';
import 'package:proyecto_final/sources/obj/sale.dart';
import 'package:proyecto_final/sources/ui/sale_info.dart';

class ShoppingRecord extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ShoppingRecordState();
}

class ShoppingRecordState extends State<ShoppingRecord> {
  bool recordExist = false;

  List<Sale>? sales;

  StreamSubscription<Event>? onRecordAdded;
  StreamSubscription<Event>? onRecordChanged;
  StreamSubscription<Event>? onRecordDeleted;

  @override
  void initState() {
    sales = [];

    final recordReference =
        FirebaseDatabase.instance.reference().child('venta');

    onRecordAdded = recordReference.onChildAdded.listen(onSaleAdded);
    onRecordChanged = recordReference.onChildChanged.listen(onSaleUpdated);
    onRecordDeleted = recordReference.onChildRemoved.listen(onSaleDeleted);

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    onRecordAdded?.cancel();
    onRecordChanged?.cancel();
    onRecordDeleted?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    sales!.sort((a, b) => b.id!.compareTo(a.id!));
    if (recordExist) {
      return Scaffold(
        backgroundColor: Colors.cyan[200],
        appBar: AppBar(
          title: Text('Registro de compras'),
          backgroundColor: Colors.cyan[800],
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Text('si hay ventas ' + sales!.length.toString()),
              // Text('Total 1: ' + sales![0].id!)
              Expanded(
                  child: ListView.builder(
                itemCount: sales?.length,
                padding: EdgeInsets.all(7.0),
                itemBuilder: (context, index) {
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
                              title: Text('Compra No: ' + sales![index].id!),
                              subtitle: Text("Fecha: " +
                                  DateTime.parse(sales![index].date!)
                                      .day
                                      .toString() +
                                  ' / ' +
                                  DateTime.parse(sales![index].date!)
                                      .month
                                      .toString() +
                                  ' / ' +
                                  DateTime.parse(sales![index].date!)
                                      .year
                                      .toString()),
                              leading: Icon(
                                Icons.shopping_bag_outlined,
                                size: 55.0,
                                color: Colors.black,
                              ),
                              onTap: () {
                                navigateToSaleDetails(sales![index]);
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  );
                },
              ))
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.cyan[200],
      appBar: AppBar(
        title: Text('Registro de compras'),
        backgroundColor: Colors.cyan[800],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(7.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/vacio.png',
                    width: 150,
                    height: 150,
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    'Aun no has realizado ninguna compra',
                    style: TextStyle(
                      fontSize: 22.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void onSaleAdded(Event event) {
    setState(() {
      Map<dynamic, dynamic> map = event.snapshot.value;

      print(event.snapshot.key);

      Sale s1 = Sale.fromJson(event.snapshot.key.toString(), map);

      if (s1.user == globals.user) {
        sales!.add(s1);
        recordExist = true;
      }
    });
  }

  void onSaleUpdated(Event event) {
    setState(() {});
  }

  void onSaleDeleted(Event event) {
    setState(() {});
  }

  Future<void> navigateToSaleDetails(Sale sale) async {
    globals.selectedSale = sale;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SaleInfo()),
    );
  }
}
