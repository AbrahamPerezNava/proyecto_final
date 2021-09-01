import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_final/sources/obj/globals.dart' as globals;
import 'package:proyecto_final/sources/obj/product.dart';
import 'package:proyecto_final/sources/obj/product_list.dart';
import 'package:proyecto_final/sources/obj/product_on_cart.dart';

class ScreenLists extends StatefulWidget {
  List<String> schools = [];
  List<String> teachers = [];
  List<String> groups = [];
  List<ProductList> lists = [];
  List<ProductOnCart> productsOnList = [];
  List<Product> allProducts = [];

  @override
  State<StatefulWidget> createState() => ScreenListsState();
}

class ScreenListsState extends State<ScreenLists> {
  String? schoolValue = '';
  String? teacherValue = '';
  String? groupsValue = '';

  String message = '';

  double total = 0;

  StreamSubscription<Event>? _onProductAdded;
  StreamSubscription<Event>? _onProductChanged;
  StreamSubscription<Event>? _onProductDeleted;

  StreamSubscription<Event>? _onProductListAdded;
  StreamSubscription<Event>? _onProductListChanged;
  StreamSubscription<Event>? _onProductListDeleted;

  final dbReference = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    widget.schools = [];
    widget.teachers = [];
    widget.groups = [];
    widget.lists = [];
    widget.productsOnList = [];
    widget.allProducts = [];

    final listReference = FirebaseDatabase.instance.reference().child('lista');
    final productReference =
        FirebaseDatabase.instance.reference().child('producto');

    _onProductAdded = productReference.onChildAdded.listen(onProductAdded);
    _onProductChanged = productReference.onChildChanged.listen(onProductUpdate);
    _onProductDeleted =
        productReference.onChildRemoved.listen(onProductRemoved);

    _onProductListAdded = listReference.onChildAdded.listen(onProductListAdded);
    _onProductListChanged =
        listReference.onChildChanged.listen(onProductListUpdate);
    _onProductListDeleted =
        listReference.onChildRemoved.listen(onProductListRemoved);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _onProductAdded?.cancel();
    _onProductChanged?.cancel();
    _onProductDeleted?.cancel();

    _onProductListAdded?.cancel();
    _onProductListChanged?.cancel();
    _onProductListDeleted?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[200],
      appBar: AppBar(
        title: Text('Listas'),
        backgroundColor: Colors.cyan[800],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              padding: EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text(
                    'Escuela:',
                    style: TextStyle(fontSize: 22.0),
                  ),
                  Container(
                    height: 35.0,
                    padding: EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: Colors.black,
                            style: BorderStyle.solid,
                            width: 0.0)),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      underline: Container(
                        color: Colors.transparent,
                      ),
                      value: schoolValue,
                      elevation: 16,
                      style: TextStyle(color: Colors.black),
                      onChanged: (String? newValue) {
                        setState(() {
                          schoolValue = newValue;
                          teacherFilter();
                        });
                      },
                      items: List.generate(
                          widget.schools.length,
                          (index) => DropdownMenuItem(
                              value: widget.schools[index].toString(),
                              child: Text(
                                widget.schools[index].toString(),
                                style: TextStyle(fontSize: 14.0),
                              ))),
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text(
                    'Profesor(a):',
                    style: TextStyle(fontSize: 22.0),
                  ),
                  Container(
                    height: 35.0,
                    padding: EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: Colors.black,
                            style: BorderStyle.solid,
                            width: 0.0)),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      underline: Container(
                        color: Colors.transparent,
                      ),
                      value: teacherValue,
                      elevation: 16,
                      style: TextStyle(color: Colors.black),
                      onChanged: (String? newValue) {
                        setState(() {
                          teacherValue = newValue;
                          groupFilter();
                        });
                      },
                      items: List.generate(
                          widget.teachers.length,
                          (index) => DropdownMenuItem(
                              value: widget.teachers[index].toString(),
                              child: Text(
                                widget.teachers[index].toString(),
                                style: TextStyle(fontSize: 14.0),
                              ))),
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text(
                    'Materia o grupo:',
                    style: TextStyle(fontSize: 22.0),
                  ),
                  Container(
                    height: 35.0,
                    padding: EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: Colors.black,
                            style: BorderStyle.solid,
                            width: 0.0)),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      underline: Container(
                        color: Colors.transparent,
                      ),
                      value: groupsValue,
                      elevation: 16,
                      style: TextStyle(color: Colors.black),
                      onChanged: (String? newValue) {
                        setState(() {
                          groupsValue = newValue;
                          //groupFilter();
                          productsOnList();
                        });
                      },
                      items: List.generate(
                          widget.groups.length,
                          (index) => DropdownMenuItem(
                              value: widget.groups[index].toString(),
                              child: Text(
                                widget.groups[index].toString(),
                                style: TextStyle(fontSize: 14.0),
                              ))),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: generateTable(),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Text(
                    'Total: \$' + total.toStringAsFixed(2),
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.normal),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        addToCart();
                        Navigator.of(context).pop();
                        if (message != '') {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Aviso"),
                                  content: Text(
                                      "Los siguientes productos no pueden surtirse completamente por falta de existencias: \n\n" +
                                          message +
                                          "\nEstos se agregaron a su carrito con el mayor número de piezas disponibles para cada uno"),
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
                        }
                      },
                      child: Text('Agregar al carrito'))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void onProductListAdded(Event event) {
    setState(() {
      Map<dynamic, dynamic> map = event.snapshot.value;

      print(event.snapshot.key);

      ProductList pl = ProductList.fromJson(event.snapshot.key.toString(), map);

      print(pl.id);
      print(pl.school);
      print(pl.teacher);
      print(pl.group);
      print(pl.products);

      for (int i = 0; i < pl.products!.length; i++) {
        print(pl.products!.keys.toList()[i].toString());
        print(pl.products!.values
            .toList()[i]
            .toString()
            .replaceAll(new RegExp(r'[^0-9]'), ''));
      }

      print('///////////////////////////////////');

      widget.lists.add(pl);

      widget.schools.add(pl.school!);

      // widget.teachers.add(pl.teacher!);

      // widget.groups.add(pl.group!);

      removeDuplicate();

      print(widget.schools[0]);
    });
  }

  void onProductListUpdate(Event event) {
    setState(() {});
  }

  void onProductListRemoved(Event event) {
    setState(() {});
  }

  void removeDuplicate() {
    widget.schools = widget.schools.toSet().toList();
    schoolValue = widget.schools[0];
    teacherFilter();
    //widget.teachers = widget.teachers.toSet().toList();
    //widget.teachers = widget.teachers.toSet().toList();
  }

  void teacherFilter() {
    widget.teachers = [];
    for (int i = 0; i < widget.lists.length; i++) {
      if (widget.lists[i].school == schoolValue) {
        widget.teachers.add(widget.lists[i].teacher!);
      }
    }

    widget.teachers = widget.teachers.toSet().toList();

    teacherValue = widget.teachers[0];

    groupFilter();
  }

  void groupFilter() {
    widget.groups = [];
    for (int i = 0; i < widget.lists.length; i++) {
      if (widget.lists[i].school == schoolValue &&
          widget.lists[i].teacher == teacherValue) {
        widget.groups.add(widget.lists[i].group!);
      }
    }

    groupsValue = widget.groups[0];
  }

  void productsOnList() {
    widget.productsOnList = [];

    for (int i = 0; i < widget.lists.length; i++) {
      if (widget.lists[i].school == schoolValue &&
          widget.lists[i].teacher == teacherValue &&
          widget.lists[i].group == groupsValue) {
        for (int j = 0; j < widget.lists[i].products!.length; j++) {
          String id = widget.lists[i].products!.keys.toList()[j].toString();
          String quantity = widget.lists[i].products!.values
              .toList()[j]
              .toString()
              .replaceAll(new RegExp(r'[^0-9]'), '');

          ProductOnCart pc = ProductOnCart(id, quantity, true);

          widget.productsOnList.add(pc);
        }
      }
    }

    for (int i = 0; i < widget.productsOnList.length; i++) {
      print(widget.productsOnList[i].id);
      print(widget.productsOnList[i].quantity);
    }
  }

///////////////////////////////////////////////////////////////////////////////////////////////////////////////

  void onProductAdded(Event event) {
    setState(() {
      Product prod = Product.fromSnapShot(event.snapshot);
      widget.allProducts.add(prod);
    });
  }

  void onProductUpdate(Event event) {
    setState(() {
      Product prod = Product.fromSnapShot(event.snapshot);

      for (int i = 0; i < widget.allProducts.length; i++) {
        if (widget.allProducts[i].id == prod.id) {
          widget.allProducts[i] = prod;
        }
      }
    });
  }

  void onProductRemoved(Event event) {
    setState(() {
      Product prod = Product.fromSnapShot(event.snapshot);

      for (int i = 0; i < widget.allProducts.length; i++) {
        if (widget.allProducts[i].id == prod.id) {
          widget.allProducts.removeAt(i);
        }
      }
    });
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////

  Widget generateTable() {
    productsOnList();
    calculateTotal();

    return DataTable(
        columns: const <DataColumn>[
          DataColumn(
            label: Text(
              'Producto',
              style: TextStyle(fontStyle: FontStyle.normal),
            ),
          ),
          DataColumn(
            label: Text(
              'Unidades',
              style: TextStyle(fontStyle: FontStyle.normal),
            ),
          ),
          DataColumn(
            label: Text(
              'Subtotal',
              style: TextStyle(fontStyle: FontStyle.normal),
            ),
          ),
        ],
        rows: List<DataRow>.generate(
            widget.productsOnList.length,
            (index) => DataRow(cells: <DataCell>[
                  DataCell(Text(widget
                          .allProducts[widget.allProducts.indexWhere(
                              (element) =>
                                  element.id ==
                                  widget.productsOnList[index].id)]
                          .desc
                          .toString()
                      //widget.productList[index].id.toString(),
                      )),
                  DataCell(Text(
                      widget.productsOnList[index].quantity.toString(),
                      textAlign: TextAlign.center)),
                  DataCell(Text(
                      '\$' +
                          (double.parse(widget
                                      .allProducts[widget.allProducts
                                          .indexWhere((element) =>
                                              element.id ==
                                              widget.productsOnList[index].id)]
                                      .price
                                      .toString()) *
                                  int.parse(widget
                                      .productsOnList[index].quantity
                                      .toString()))
                              .toString(),
                      textAlign: TextAlign.center)),
                ])));
  }

  void calculateTotal() {
    total = 0;
    for (int i = 0; i < widget.productsOnList.length; i++) {
      total = total +
          (double.parse(widget
                  .allProducts[widget.allProducts.indexWhere(
                      (element) => element.id == widget.productsOnList[i].id)]
                  .price
                  .toString()) *
              int.parse(widget.productsOnList[i].quantity.toString()));
    }
  }

  void addToCart() {
    bool contains = false;
    int indexList = 0;
    int indexCart = 0;

    if (globals.cart.length > 0) {
      for (int i = 0; i < widget.productsOnList.length; i++) {
        ProductOnCart prodList = widget.productsOnList[i];

        for (int j = 0; j < globals.cart.length; j++) {
          ProductOnCart prodCart = globals.cart[j];

          if (prodList.id == prodCart.id) {
            contains = true;
            indexList = i;
            indexCart = j;
          }
        }

        if (contains) {
          verifyStock(
              widget.productsOnList[indexList], globals.cart[indexCart]);
          contains = false;
        } else {
          addWithoutVerify(widget.productsOnList[i]);
        }
      }
    } else {
      addAll();
    }
  }

  void verifyStock(ProductOnCart prodOnList, ProductOnCart prodOnCart) {
    print(prodOnList.id! + ' exist on cart');

    int totalQuantity =
        int.parse(prodOnList.quantity!) + int.parse(prodOnCart.quantity!);

    int stock = int.parse(widget
        .allProducts[widget.allProducts
            .indexWhere((element) => element.id == prodOnCart.id)]
        .stock
        .toString());

    if (stock >= totalQuantity) {
      dbReference
          .child('cliente/' + globals.user + '/carrito/' + prodOnCart.id!)
          .update({"cantidad": totalQuantity});
    } else {
      dbReference
          .child('cliente/' + globals.user + '/carrito/' + prodOnCart.id!)
          .update({"cantidad": stock});

      message = message +
          widget
              .allProducts[widget.allProducts
                  .indexWhere((element) => element.id == prodOnCart.id)]
              .desc! +
          '\n\n';
    }
  }

  void addWithoutVerify(ProductOnCart prodOnList) {
    print(prodOnList.id! + ' does not exist on cart');

    int listQuantity = int.parse(prodOnList.quantity!);

    int stock = int.parse(widget
        .allProducts[widget.allProducts
            .indexWhere((element) => element.id == prodOnList.id)]
        .stock
        .toString());

    if (stock >= listQuantity) {
      dbReference
          .child('cliente/' + globals.user + '/carrito/' + prodOnList.id!)
          .set({"cantidad": listQuantity});
    } else {
      dbReference
          .child('cliente/' + globals.user + '/carrito/' + prodOnList.id!)
          .set({"cantidad": stock});

      message = message +
          widget
              .allProducts[widget.allProducts
                  .indexWhere((element) => element.id == prodOnList.id)]
              .desc! +
          '\n\n';
    }
  }

  void addAll() {
    print('theres no cart at all');

    for (int i = 0; i < widget.productsOnList.length; i++) {
      ProductOnCart poc = widget.productsOnList[i];

      int listQuantity = int.parse(poc.quantity!);

      int stock = int.parse(widget
          .allProducts[
              widget.allProducts.indexWhere((element) => element.id == poc.id)]
          .stock
          .toString());

      if (stock >= listQuantity) {
        dbReference
            .child('cliente/' + globals.user + '/carrito/' + poc.id!)
            .set({"cantidad": listQuantity});
      } else {
        dbReference
            .child('cliente/' + globals.user + '/carrito/' + poc.id!)
            .set({"cantidad": stock});

        message = message +
            widget
                .allProducts[widget.allProducts
                    .indexWhere((element) => element.id == poc.id)]
                .desc! +
            '\n\n';
      }
    }
  }

  /*Widget generateTable() {
    return DataTable(
        columns: const <DataColumn>[
          DataColumn(
            label: Text(
              'Producto',
              style: TextStyle(fontStyle: FontStyle.normal),
            ),
          ),
          DataColumn(
            label: Text(
              'Unidades',
              style: TextStyle(fontStyle: FontStyle.normal),
            ),
          ),
          DataColumn(
            label: Text(
              'Subtotal',
              style: TextStyle(fontStyle: FontStyle.normal),
            ),
          ),
        ],
        rows: List<DataRow>.generate(
            globals.cart.length,
            (index) => DataRow(cells: <DataCell>[
                  DataCell(Text(
                    productNames[index].toString(),
                  )),
                  DataCell(Text(globals.cart[index].quantity.toString(),
                      textAlign: TextAlign.center)),
                  DataCell(Text(
                      '\$' +
                          ((double.parse(unitaryPrices[index].toString()) *
                                  int.parse(
                                      globals.cart[index].quantity.toString())))
                              .toStringAsFixed(2),
                      textAlign: TextAlign.center)),
                ])));
  }*/

}
