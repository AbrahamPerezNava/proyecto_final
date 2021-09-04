import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_final/sources/obj/product.dart';
import 'package:proyecto_final/sources/ui/product_info.dart';
import 'package:proyecto_final/sources/ui/shopping_cart.dart';

class SearchScreen extends StatefulWidget {
  final String searchString;
  final String user;

  SearchScreen(this.searchString, this.user);

  @override
  State<StatefulWidget> createState() => SearchScreenState();
}

final userReference = FirebaseDatabase.instance.reference();

class SearchScreenState extends State<SearchScreen> {
  bool cartExist = false;
  List<Product>? items;
  final controller = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.text = widget.searchString;
    cartExist = false;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(cartExist);
    return Scaffold(
      backgroundColor: Colors.cyan[200],
      appBar: AppBar(
        title: Text('Resultados: ' + widget.searchString),
        backgroundColor: Colors.cyan[800],
        actions: <Widget>[
          IconButton(
              onPressed: () {
                _navigateToShoppingCart(context, widget.user);
              },
              icon: Icon(Icons.shopping_cart)),
        ],
      ),

      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(7.0),
              child: Column(
                children: [
                  TextField(
                    controller: controller,
                    textInputAction: TextInputAction.go,
                    onSubmitted: (value) {
                      searchProduct(context, value, widget.user);
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
              child: ListSearch(widget.searchString, widget.user),
            ),
          ],
        ),
      ),
      //bottomNavigationBar: BottomAppBar(
      //  child:
      //),
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

  void _navigateToShoppingCart(BuildContext context, String user) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ShoppingCart(user)),
    );
  }
}

class ListSearch extends StatefulWidget {
  final String searchString;
  final String user;
  ListSearch(this.searchString, this.user);
  @override
  State<StatefulWidget> createState() => ListSearchState();
}

class ListSearchState extends State<ListSearch> {
  bool productExist = false;

  List<Product>? items;

  StreamSubscription<Event>? _onProductAddedSubscription;
  StreamSubscription<Event>? _onProductChangedSubscription;
  StreamSubscription<Event>? _onProductDeletedSubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    items = [];
    final userReference =
        FirebaseDatabase.instance.reference().child('producto');

    _onProductAddedSubscription =
        userReference.onChildAdded.listen(_onProductAdded);
    _onProductDeletedSubscription =
        userReference.onChildRemoved.listen(_onProductDeleted);
    _onProductChangedSubscription =
        userReference.onChildChanged.listen(_onProductUpdate);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _onProductAddedSubscription?.cancel();
    _onProductChangedSubscription?.cancel();
    _onProductDeletedSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    //return productsOnCart(user_id);

    if (productExist) {
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
    } else {
      return Container(
        padding: EdgeInsets.all(7.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/search.png',
              width: 150,
              height: 150,
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              'No hay productos que coincidan con tu busqueda',
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

  void _onProductAdded(Event event) {
    setState(() {
      Product prod = Product.fromSnapShot(event.snapshot);
      int stock = int.parse(prod.stock.toString());

      if (prod.desc!
              .toLowerCase()
              .contains(widget.searchString.toLowerCase()) &&
          stock > 0) {
        items?.add(prod);
        productExist = true;
      }
    });
  }

  void _onProductUpdate(Event event) {
    setState(() {
      bool contains = false;
      int located = 0;

      Product prod = Product.fromSnapShot(event.snapshot);
      int stock = int.parse(prod.stock.toString());

      for (int i = 0; i < items!.length; i++) {
        print(items![i].id);
        if (items![i].id == prod.id) {
          contains = true;
          located = i;
        }
      }

      if (contains) {
        if (prod.desc!
                .toLowerCase()
                .contains(widget.searchString.toLowerCase()) &&
            stock > 0) {
          items![located] = prod;
        } else {
          items!.removeAt(located);
          if (items!.isEmpty) {
            productExist = false;
          }
        }
      } else {
        if (prod.desc!
                .toLowerCase()
                .contains(widget.searchString.toLowerCase()) &&
            stock > 0) {
          items?.add(prod);
          productExist = true;
        }
      }
    });
  }

  void _onProductDeleted(Event event) {
    setState(() {
      bool contains = false;
      int located = 0;

      Product prod = Product.fromSnapShot(event.snapshot);

      for (int i = 0; i < items!.length; i++) {
        if (items![i].id == prod.id) {
          contains = true;
          located = i;
        }
      }

      if (contains) {
        items!.removeAt(located);

        if (items!.isEmpty) {
          productExist = false;
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
