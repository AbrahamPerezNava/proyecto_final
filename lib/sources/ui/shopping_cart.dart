import 'dart:async';
import 'package:proyecto_final/sources/obj/globals.dart' as globals;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_final/sources/obj/product.dart';
import 'package:proyecto_final/sources/obj/product_on_cart.dart';
import 'package:proyecto_final/sources/ui/payment_screen.dart';
import 'package:proyecto_final/sources/ui/screen_lists.dart';

class ShoppingCart extends StatefulWidget {
  final String user;
  List<ProductOnCart>? productsOnCart;
  List<Product>? allProducts;

  ShoppingCart(this.user);

  @override
  State<StatefulWidget> createState() => ShoppingCartState();
}

final userReference = FirebaseDatabase.instance.reference();

class ShoppingCartState extends State<ShoppingCart> {
  bool cartExist = false;

  double total = 0.0;

  StreamSubscription<Event>? _onProductAddedToCart;
  StreamSubscription<Event>? _onProductChangedOnCart;
  StreamSubscription<Event>? _onProductDeletedOnCart;

  StreamSubscription<Event>? _onProductAdded;
  StreamSubscription<Event>? _onProductChanged;
  StreamSubscription<Event>? _onProductDeleted;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    cartExist = false;

    widget.productsOnCart = [];
    widget.allProducts = [];

    final cartReference =
        FirebaseDatabase.instance.reference().child('cliente/' + widget.user);

    final productReference =
        FirebaseDatabase.instance.reference().child('producto');

    _onProductAddedToCart = cartReference.onChildAdded.listen(onCartAdded);
    _onProductChangedOnCart = cartReference.onChildChanged.listen(onCartUpdate);
    _onProductDeletedOnCart =
        cartReference.onChildRemoved.listen(onCartRemoved);

    _onProductAdded = productReference.onChildAdded.listen(onProductAdded);
    _onProductChanged = productReference.onChildChanged.listen(onProductUpdate);
    _onProductDeleted =
        productReference.onChildRemoved.listen(onProductRemoved);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _onProductAddedToCart?.cancel();
    _onProductChangedOnCart?.cancel();
    _onProductDeletedOnCart?.cancel();
    _onProductAdded?.cancel();
    _onProductChanged?.cancel();
    _onProductDeleted?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[200],
      appBar: AppBar(
        title: Text('Carrito de compra'),
        backgroundColor: Colors.cyan[800],
        actions: <Widget>[
          IconButton(
              onPressed: () {
                navigateToListsScreen(context);
              },
              icon: Icon(Icons.receipt)),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: fillList(cartExist),
            ),
            createBottomBar(),
          ],
        ),
      ),
    );
  }

  void onCartAdded(Event event) {
    setState(() {
      print('cart added');

      Map<dynamic, dynamic> map = event.snapshot.value;

      cartExist = true;

      for (int i = 0; i < map.length; i++) {
        String id = map.keys.toList()[i].toString();
        String quantity = map.values
            .toList()[i]
            .toString()
            .replaceAll(new RegExp(r'[^0-9]'), '');

        ProductOnCart prodCart = ProductOnCart(id, quantity, true);
        print(prodCart.id);
        print(prodCart.quantity);
        widget.productsOnCart!.add(prodCart);
      }

      calculateTotal();
    });
  }

  void onCartUpdate(Event event) {
    setState(() {
      print('cart updated');
      Map<dynamic, dynamic> map = event.snapshot.value;

      widget.productsOnCart = [];

      for (int i = 0; i < map.length; i++) {
        String id = map.keys.toList()[i].toString();
        String quantity = map.values
            .toList()[i]
            .toString()
            .replaceAll(new RegExp(r'[^0-9]'), '');

        ProductOnCart prodCart = ProductOnCart(id, quantity, true);
        print(prodCart.id);
        print(prodCart.quantity);
        widget.productsOnCart!.add(prodCart);
      }

      calculateTotal();
    });
  }

  void onCartRemoved(Event event) {
    setState(() {
      widget.productsOnCart = [];
      cartExist = false;
    });
  }

  //////////////////////////////////////////////////////////

  void onProductAdded(Event event) {
    setState(() {
      Product prod = Product.fromSnapShot(event.snapshot);
      print('Agrega 1111');
      widget.allProducts?.add(prod);
      calculateTotal();
    });
  }

  void onProductUpdate(Event event) {
    setState(() {
      Product prod = Product.fromSnapShot(event.snapshot);

      for (int i = 0; i < widget.allProducts!.length; i++) {
        if (widget.allProducts![i].id == prod.id) {
          widget.allProducts![i] = prod;

          for (int j = 0; j < widget.productsOnCart!.length; j++) {
            if (prod.id == widget.productsOnCart![j].id) {
              print('Esta en el carrito');

              if (int.parse(prod.stock.toString()) > 0) {
                if (int.parse(prod.stock.toString()) <
                    int.parse(widget.productsOnCart![j].quantity.toString())) {
                  print('El stock es mas bajo');

                  changeCartQuantity(prod.id, prod.stock.toString());

                  //widget.productsOnCart![j] = newProd;

                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Aviso"),
                          content: Text("El stock de " +
                              prod.desc.toString() +
                              " cambió, y es menor a las piezas en su carrito. \n\nHemos actualizado las piezas disponibles en su carrito"),
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
              } else {
                deleteFromCart(prod.id);

                //widget.productsOnCart![j] = newProd;

                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Aviso"),
                        content: Text("El producto " +
                            prod.desc.toString() +
                            " ya no está disponible. \n\nEl producto ha sido retirado de su carrito"),
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
            }
          }
          calculateTotal();
        }
      }

      print('Modificado');
      print(event.snapshot.value);
    });
  }

  void onProductRemoved(Event event) {
    setState(() {
      print('Borrado');
      print(event.snapshot.value);

      Product prod = Product.fromSnapShot(event.snapshot);

      for (int i = 0; i < widget.allProducts!.length; i++) {
        if (widget.allProducts![i].id == prod.id) {
          widget.allProducts!.removeAt(i);

          for (int j = 0; j < widget.productsOnCart!.length; j++) {
            if (prod.id == widget.productsOnCart![j].id) {
              print('Esta en el carrito');

              deleteFromCart(prod.id);

              //widget.productsOnCart![j] = newProd;

              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Aviso"),
                      content: Text("El producto " +
                          prod.desc.toString() +
                          " ya no está disponible. \n\nEl producto ha sido retirado de su carrito"),
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
          }
          calculateTotal();
        }
      }

      print('Modificado');
      print(event.snapshot.value);
    });
  }

  ///////////////////////////////////////////////////////////

  Widget fillList(bool exist) {
    if (cartExist) {
      print(widget.productsOnCart!.length);
      return ListView.builder(
        itemCount: widget.productsOnCart!.length,
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
                      title: Text(widget
                          .allProducts![widget.allProducts!.indexWhere(
                              (element) =>
                                  element.id ==
                                  widget.productsOnCart![position].id)]
                          .desc
                          .toString()),
                      subtitle: Text(widget
                              .allProducts![widget.allProducts!.indexWhere(
                                  (element) =>
                                      element.id ==
                                      widget.productsOnCart![position].id)]
                              .stock
                              .toString() +
                          " disponibles"),
                      leading: Image(
                        image: NetworkImage(widget
                            .allProducts![widget.allProducts!.indexWhere(
                                (element) =>
                                    element.id ==
                                    widget.productsOnCart![position].id)]
                            .image
                            .toString()),
                        height: 70,
                        width: 70,
                      ),
                      onTap: () => {},
                    ),
                    Container(
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 25.0,
                            child: Row(
                              children: [
                                ElevatedButton(
                                    child: Text(
                                      'Eliminar',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12.0),
                                    ),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text("Advertencia"),
                                              content: Text(
                                                  "¿Seguro que quieres eliminar este producto de tu carrito de compra?"),
                                              actions: [
                                                FlatButton(
                                                  child: Text("No"),
                                                  color: Colors.blue[100],
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                FlatButton(
                                                  child: Text("Si"),
                                                  color: Colors.red,
                                                  textColor: Colors.white,
                                                  onPressed: () {
                                                    deleteFromCart(widget
                                                        .productsOnCart![
                                                            position]
                                                        .id);
                                                    Navigator.of(context).pop();
                                                  },
                                                )
                                              ],
                                            );
                                          });
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.red),
                                    ))
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(7.0),
                            child: Row(
                              children: [
                                Text(
                                  'Cantidad: ',
                                  style: TextStyle(fontSize: 14.0),
                                ),
                                Container(
                                  width: 60.0,
                                  height: 25.0,
                                  padding: EdgeInsets.all(3.0),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.black,
                                          style: BorderStyle.solid,
                                          width: 0.0)),
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    underline: Container(
                                      color: Colors.transparent,
                                    ),
                                    value: widget
                                        .productsOnCart![position].quantity,
                                    elevation: 16,
                                    style: TextStyle(color: Colors.black),
                                    onChanged: (String? newValue) {
                                      changeCartQuantity(
                                          widget.productsOnCart![position].id,
                                          newValue!);
                                    },
                                    items: List.generate(
                                        int.parse(widget
                                            .allProducts![widget.allProducts!
                                                .indexWhere((element) =>
                                                    element.id ==
                                                    widget
                                                        .productsOnCart![
                                                            position]
                                                        .id)]
                                            .stock
                                            .toString()),
                                        (index) => DropdownMenuItem(
                                            value: (index + 1).toString(),
                                            child: Text(
                                              (index + 1).toString(),
                                              style: TextStyle(fontSize: 14.0),
                                            ))),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Text(
                            '\$' +
                                (double.parse(widget
                                            .allProducts![widget.allProducts!
                                                .indexWhere((element) =>
                                                    element.id ==
                                                    widget
                                                        .productsOnCart![
                                                            position]
                                                        .id)]
                                            .price
                                            .toString()) *
                                        double.parse(widget
                                            .productsOnCart![position].quantity
                                            .toString()))
                                    .toStringAsFixed(2),
                            style: TextStyle(fontSize: 20.0),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          );
        },
      );
    } else {
      return Container(
        padding: EdgeInsets.all(7.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/sad.png',
              width: 150,
              height: 150,
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              'Aun no tienes productos en tu carrito de compra',
              style: TextStyle(
                fontSize: 22.0,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }

  Widget createBottomBar() {
    return Container(
      height: 115.0, //set your height here
      width: double.maxFinite, //set your width here

      child: Visibility(
        visible: cartExist,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(7.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: TextStyle(fontSize: 28.0),
                  ),
                  Text(
                    '\$' + total.toStringAsFixed(2),
                    style: TextStyle(fontSize: 28.0),
                  )
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(7.0, 7.0, 7.0, 15.0),
              child: Column(
                children: [
                  _Boton(
                      text: 'Continuar con la compra',
                      icon: Icon(Icons.payment),
                      color: Colors.cyan[800]!,
                      textColor: Colors.white,
                      onTap: () {
                        navigateToPaymentString(
                            context, total, widget.productsOnCart!);
                      }),
                ],
              ),
            )
            //add as many tabs as you want here
          ],
        ),
      ),
    );
  }

  void navigateToPaymentString(
      BuildContext context, double total, List<ProductOnCart> cart) async {
    globals.total = total.toStringAsFixed(2);
    globals.cart = cart;
    globals.cartToPay = true;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PaymentScreen()),
    );
  }

  void navigateToListsScreen(BuildContext context) async {
    globals.cart = widget.productsOnCart!;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScreenLists()),
    );
  }

  void calculateTotal() {
    double result = 0.0;

    for (int i = 0; i < widget.productsOnCart!.length; i++) {
      result = result +
          (double.parse(widget
                  .allProducts![widget.allProducts!.indexWhere(
                      (element) => element.id == widget.productsOnCart![i].id)]
                  .price
                  .toString()) *
              double.parse(widget.productsOnCart![i].quantity.toString()));
    }

    total = result;
  }

  void changeCartQuantity(String? idProdCart, String newQuantity) {
    userReference
        .child('cliente/' + widget.user + '/carrito/' + idProdCart!)
        .update({"cantidad": int.parse(newQuantity)});
  }

  void deleteFromCart(String? idProdCart) {
    userReference
        .child('cliente/' + widget.user + '/carrito/' + idProdCart!)
        .remove();
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
