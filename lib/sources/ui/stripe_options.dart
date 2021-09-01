import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:proyecto_final/sources/obj/globals.dart' as globals;
import 'package:proyecto_final/sources/obj/product_on_cart.dart';
import 'package:proyecto_final/sources/payment_controllers/stripe_service.dart';
import 'package:proyecto_final/sources/ui/successful_payment.dart';

class StripeOptions extends StatefulWidget {
  @override
  StripeOptionsState createState() => StripeOptionsState();
}

class StripeOptionsState extends State<StripeOptions> {
  payViaNewCard(BuildContext context, int totalFormat) async {
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Espere');
    await dialog.show();
    var response = await StripeService.payWithNewCard(
        amount: totalFormat.toString(), currency: 'MXN');
    await dialog.hide();

    if (response.success!) {
      _navigateToSuccess(context);
    } else {
      if (response.message != 'cancelled') {
        print(response.message);
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Error"),
                content: Text(
                    "Hubo un error con su método de pago \n\nIntente denuevo más tarde"),
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
      } else {}
    }

    /* ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(response.message!),
      duration:
          new Duration(milliseconds: response.success == true ? 1200 : 3000),
    ));*/
  }

  @override
  void initState() {
    super.initState();

    StripeService.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.purple[300],
        appBar: AppBar(
          backgroundColor: Colors.purple,
          title: Text('Pago por Stripe'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/stripe-black.png',
                      width: 255,
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    Text(
                      'Ingresa la información de tu tarjeta de débito o crédito para realizar el pago correspondiente',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 24.0,
                          fontWeight: FontWeight.normal),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Container(
                height: 80.0,
                padding: EdgeInsets.fromLTRB(45.0, 2.0, 45.0, 2.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 15.0,
                            ),
                            Text(
                              'Ingresar tarjeta',
                              style: TextStyle(
                                  color: Colors.purple[300],
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                          ],
                        ),
                        onPressed: () {
                          double totalFixed =
                              (double.parse(globals.total)) * 100;
                          int totalFormat =
                              int.parse(totalFixed.toStringAsFixed(0));

                          if (totalFormat > 1000) {
                            payViaNewCard(context, totalFormat);
                          } else {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Error"),
                                    content: Text(
                                        "Stripe solo admite pagos por mas de \$10.00 MXN \n\nUse otra pasarela de pago"),
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
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                        ))
                  ],
                ),
              )
            ],
          ),
        ));
  }

  void _navigateToSuccess(BuildContext context) async {
    await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SuccessfulPayment()),
        (route) => false);
  }
}
