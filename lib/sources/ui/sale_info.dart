import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_final/sources/obj/globals.dart' as globals;
import 'package:proyecto_final/sources/obj/product_on_cart.dart';

class SaleInfo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SaleInfoState();
}

class SaleInfoState extends State<SaleInfo> {
  final dbReference = FirebaseDatabase.instance.reference();

  List<String> productNames = [];

  List<ProductOnCart> productsOnSale = [];

  @override
  void initState() {
    productsOnSale = [];
    productNames = [];

    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getSaleInformation(),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            print(snapshot.data);
            return Scaffold(
              backgroundColor: Colors.cyan[200],
              appBar: AppBar(
                title: Text('Información de tu compra'),
                backgroundColor: Colors.cyan[800],
              ),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        padding: EdgeInsets.all(7.0),
                        child: Image.asset(
                          'assets/punto-de-venta.png',
                          width: 150.0,
                        )),
                    Container(
                      padding: EdgeInsets.all(7.0),
                      child: Column(
                        children: [
                          Text(
                            'Información',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 28.0,
                                fontWeight: FontWeight.normal),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Folio: ' + globals.selectedSale!.id.toString(),
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                                fontWeight: FontWeight.normal),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(
                            'Fecha: ' +
                                DateTime.parse(
                                        globals.selectedSale!.date.toString())
                                    .day
                                    .toString() +
                                '/' +
                                DateTime.parse(
                                        globals.selectedSale!.date.toString())
                                    .month
                                    .toString() +
                                '/' +
                                DateTime.parse(
                                        globals.selectedSale!.date.toString())
                                    .year
                                    .toString(),
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                                fontWeight: FontWeight.normal),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(
                            'Método de pago: ' +
                                globals.selectedSale!.method.toString(),
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                                fontWeight: FontWeight.normal),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(
                            'Entrega a domicilio: ' +
                                globals.selectedSale!.shippment.toString(),
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                                fontWeight: FontWeight.normal),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(
                            'Recibe el pedido: ' +
                                globals.selectedSale!.receiver.toString(),
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                                fontWeight: FontWeight.normal),
                            textAlign: TextAlign.left,
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
                            'Total: \$' + globals.selectedSale!.total!,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                                fontWeight: FontWeight.normal),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Scaffold(
              backgroundColor: Colors.cyan[200],
              appBar: AppBar(
                title: Text('Cargando información'),
                backgroundColor: Colors.cyan[800],
              ),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [CircularProgressIndicator()],
                ),
              ),
            );
          }
        });
  }

  Future<String> getSaleInformation() async {
    for (int j = 0; j < globals.selectedSale!.products!.length; j++) {
      String id = globals.selectedSale!.products!.keys.toList()[j].toString();
      String quantity = globals.selectedSale!.products!.values
          .toList()[j]
          .toString()
          .replaceAll(new RegExp(r'[^0-9]'), '');

      ProductOnCart pc = ProductOnCart(id, quantity, true);

      productsOnSale.add(pc);

      await dbReference
          .child('producto/' + id)
          .once()
          .then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> map = snapshot.value;

        productNames.add(map['descripcion'].toString());

        print(map['descripcion'].toString());
      });
    }

    return 'done';
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
        ],
        rows: List<DataRow>.generate(
            globals.selectedSale!.products!.length,
            (index) => DataRow(cells: <DataCell>[
                  DataCell(Text(
                    productNames[index].toString(),
                  )),
                  DataCell(Text(productsOnSale[index].quantity.toString(),
                      textAlign: TextAlign.center)),
                ])));
  }
}
