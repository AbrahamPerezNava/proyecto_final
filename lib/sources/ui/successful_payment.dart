import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_final/sources/obj/globals.dart' as globals;
import 'package:proyecto_final/sources/ui/home_screen.dart';

class SuccessfulPayment extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SuccessfulPaymentState();
}

class SuccessfulPaymentState extends State<SuccessfulPayment> {
  final dbReference = FirebaseDatabase.instance.reference();
  List<String> unitaryPrices = [];
  List<String> productNames = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    print('Carrito: ' +
        globals.cartToPay.toString() +
        '\nTotal: \$' +
        globals.total +
        '\nCosas: ' +
        globals.cart.length.toString() +
        '\nUsuario: ' +
        globals.user);

    return FutureBuilder<String>(
        future: updateDatabase(),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            print(snapshot.data);
            return Scaffold(
              backgroundColor: Colors.cyan[200],
              appBar: AppBar(
                title: Text('Compra exitosa'),
                automaticallyImplyLeading: false,
                backgroundColor: Colors.cyan[800],
              ),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                        padding: EdgeInsets.all(7.0),
                        child: Image.asset(
                          'assets/check.png',
                          width: 150.0,
                        )),
                    Container(
                      padding: EdgeInsets.all(7.0),
                      child: Column(
                        children: [
                          Text(
                            'Tu compra se ha realizado con éxito',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 28.0,
                                fontWeight: FontWeight.normal),
                            textAlign: TextAlign.center,
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
                            'Total: \$' + globals.total,
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
                          CustomButton(
                              onTap: () {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomeScreen()),
                                    (route) => false);
                              },
                              text: 'Volver a ver los productos',
                              icon: Icon(Icons.shopping_bag)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }

  Widget generateTable() {
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
  }

  Future<String> updateDatabase() async {
    for (int i = 0; i < globals.cart.length; i++) {
      String? id = globals.cart[i].id;
      String? quantity = globals.cart[i].quantity;

      await dbReference
          .child('producto/' + id!)
          .once()
          .then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> map = snapshot.value;

        int actualStock = int.parse(map['stock'].toString());

        unitaryPrices.add(map['precioventa'].toString());
        productNames.add(map['descripcion'].toString());

        print('777777777777777777777777777777');

        print(map['descripcion'].toString());

        int newStock = actualStock - (int.parse(quantity!));

        dbReference.child('producto/' + id).update({"stock": newStock});
      });
    }

    if (globals.cartToPay) {
      dbReference.child('cliente/' + globals.user + '/carrito').remove();
    }

    int newId = 101;

    await dbReference
        .child('venta')
        .limitToLast(1)
        .once()
        .then((DataSnapshot snapshot) {
      if (snapshot.exists) {
        Map<dynamic, dynamic> map = snapshot.value;

        int lastFolio = int.parse(map.keys.first);

        newId = lastFolio + 1;
      }
    });

    if (globals.shippment) {
      dbReference.child('venta/' + newId.toString()).set({
        "cliente": globals.user,
        "receptor": globals.receiverName,
        "fecha": DateTime.now().toString(),
        "total": globals.total,
        "pasarela": globals.method,
        "envio": 'si',
        "direccion": globals.address
      });
    } else {
      dbReference.child('venta/' + newId.toString()).set({
        "cliente": globals.user,
        "receptor": globals.receiverName,
        "fecha": DateTime.now().toString(),
        "total": globals.total,
        "pasarela": globals.method,
        "envio": 'no',
        "direccion": ''
      });
    }

    for (int i = 0; i < globals.cart.length; i++) {
      dbReference
          .child(
              'venta/' + newId.toString() + '/productos/' + globals.cart[i].id!)
          .set({
        "cantidad": int.parse(globals.cart[i].quantity!),
      });
    }

    return 'hola';
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final Icon icon;
  final Color color;
  final Color textColor;
  final VoidCallback? onTap;

  const CustomButton({
    Key? key,
    required this.text,
    required this.icon,
    this.color = Colors.white,
    this.textColor = Colors.black,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      elevation: 7,
      borderRadius: BorderRadius.all(Radius.circular(15)),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 65.0,
          padding: EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
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
