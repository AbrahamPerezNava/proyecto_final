import 'package:flutter/material.dart';
import 'package:proyecto_final/sources/obj/globals.dart' as globals;
import 'package:proyecto_final/sources/ui/payment_screen.dart';

class ShippmentDetails extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ShippmentDetailsState();
}

class ShippmentDetailsState extends State<ShippmentDetails> {
  String dropdownValue = 'Lo recojo en el negocio';
  bool domicilio = false;
  String? emptyValidator(String? value) {
    return (value == null || value.trim().toString().isEmpty)
        ? 'Este campo es necesario'
        : null;
  }

  final _formNegKey = GlobalKey<FormState>();
  final _formDomKey = GlobalKey<FormState>();

  final clientNameNegController = TextEditingController();

  final clientNameDomController = TextEditingController();

  final avenue = TextEditingController();
  final street = TextEditingController();
  final house_number = TextEditingController();
  final references = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[200],
      appBar: AppBar(
        title: Text('Método de entrega'),
        backgroundColor: Colors.cyan[800],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(14.0),
              child: Column(
                children: [
                  Text(
                    'Donde quiere recibir su producto:',
                    style: TextStyle(fontSize: 22.0),
                  ),
                  Container(
                    width: 300.0,
                    height: 35.0,
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
                      value: dropdownValue,
                      elevation: 16,
                      style: TextStyle(color: Colors.black),
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValue = newValue!;
                          changeFields();
                        });
                      },
                      items: <String>[
                        'Lo recojo en el negocio',
                        'Quiero recibirlo a domicilio '
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  )
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(7.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Form(
                    key: _formNegKey,
                    child: Visibility(
                      child: Container(
                        padding: EdgeInsets.all(7.0),
                        color: Colors.white,
                        child: Column(
                          children: [
                            Text('Persona que recogerá el pedido',
                                style: TextStyle(fontSize: 22.0)),
                            SizedBox(
                              height: 10.0,
                            ),
                            TextFormField(
                              controller: clientNameNegController,
                              validator: emptyValidator,
                              decoration: InputDecoration(
                                  icon: Icon(Icons.account_box),
                                  labelText: 'Cliente'),
                            ),
                            Text(
                              '*Se pedirá una identificación oficial para la entrega',
                              style: TextStyle(color: Colors.red),
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  if (_formNegKey.currentState?.validate() ==
                                      true) {
                                    globals.receiverName =
                                        clientNameNegController.text;
                                    globals.shippment = false;

                                    navigateToShippmentString(context);

                                    print('negocio');
                                  }
                                },
                                child: Text('Proceder al pago'))
                          ],
                        ),
                      ),
                      visible: !domicilio,
                    ),
                  ),
                  Form(
                    key: _formDomKey,
                    child: Visibility(
                      child: Container(
                        padding: EdgeInsets.all(7.0),
                        color: Colors.white,
                        child: Column(
                          children: [
                            Text('Persona que recibirá el pedido',
                                style: TextStyle(fontSize: 18.0)),
                            SizedBox(
                              height: 5.0,
                            ),
                            TextFormField(
                              controller: clientNameDomController,
                              validator: emptyValidator,
                              decoration: InputDecoration(
                                  icon: Icon(Icons.account_box),
                                  labelText: 'Cliente'),
                            ),
                            Text(
                              '*Se cobrará el envío al llegar al domicilio',
                              style: TextStyle(color: Colors.red),
                            ),
                            SizedBox(
                              height: 35.0,
                            ),
                            Text('Dirección de envío',
                                style: TextStyle(fontSize: 18.0)),
                            SizedBox(
                              height: 5.0,
                            ),
                            TextFormField(
                              controller: avenue,
                              validator: emptyValidator,
                              decoration: InputDecoration(
                                  icon: Icon(Icons.house_outlined),
                                  labelText: 'Colonia'),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            TextFormField(
                              controller: street,
                              validator: emptyValidator,
                              decoration: InputDecoration(
                                  icon: Icon(Icons.house_outlined),
                                  labelText: 'Calle'),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            TextFormField(
                              controller: house_number,
                              validator: emptyValidator,
                              decoration: InputDecoration(
                                  icon: Icon(Icons.house_outlined),
                                  labelText: 'Número de casa'),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            TextFormField(
                              controller: references,
                              validator: emptyValidator,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              decoration: InputDecoration(
                                  icon: Icon(Icons.house_outlined),
                                  labelText: 'Referencias'),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Center(
                                child: ElevatedButton(
                                    onPressed: () {
                                      if (_formDomKey.currentState
                                              ?.validate() ==
                                          true) {
                                        globals.address = 'Colonia: ' +
                                            avenue.text +
                                            '\nCalle: ' +
                                            street.text +
                                            '\nNo. Casa: ' +
                                            house_number.text +
                                            '\nReferencias: ' +
                                            references.text;

                                        globals.receiverName =
                                            clientNameDomController.text;
                                        globals.shippment = true;

                                        print('domicilio');

                                        navigateToShippmentString(context);
                                      }
                                    },
                                    child: Text('Proceder al pago')))
                          ],
                        ),
                      ),
                      visible: domicilio,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void changeFields() {
    if (dropdownValue == 'Lo recojo en el negocio') {
      domicilio = false;
    } else {
      domicilio = true;
    }
  }

  void navigateToShippmentString(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PaymentScreen()),
    );
  }
}
