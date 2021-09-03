import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mercadopago_sdk/mercadopago_sdk.dart';
import 'package:proyecto_final/sources/obj/globals.dart' as globals;
import 'package:proyecto_final/sources/payment_controllers/paypal_payment.dart';
import 'package:proyecto_final/sources/ui/stripe_options.dart';
import 'package:proyecto_final/sources/ui/successful_payment.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentScreen extends StatefulWidget {
  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> {
  Razorpay? razorpay;

  @override
  initState() {
    razorpay = new Razorpay();

    razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
    razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, handlerPaymentError);
    razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);

    const channelMercadoPagoRespuesta =
        const MethodChannel("waviacademy.com/mercadoPagoRespuesta");

    channelMercadoPagoRespuesta.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'mercadoPagoOK':
          var idPago = call.arguments[0];
          var status = call.arguments[1];
          var statusDetails = call.arguments[2];
          return mercadoPagoOK(idPago, status, statusDetails);
        case 'mercadoPagoError':
          var error = call.arguments[0];
          return mercadoPagoERROR(error);
      }
    });

    super.initState();
  }

  @override //overriding noSuchMethod
  noSuchMethod(Invocation invocation) =>
      'Got the ${invocation.memberName} with arguments ${invocation.positionalArguments}';

  @override
  void dispose() {
    super.dispose();
    razorpay!.clear();
  }

  void openCheckout() {
    var options = {
      'key': globals.razorpay_keyId,
      'amount': num.parse(globals.total) * 100,
      "currency": "MXN",
      'name': 'Papelería Wilfrido',
      'description': 'Articulos de papeleria',
      'prefill': {'contact': '8888888888', 'email': globals.email},
      "external": {
        "wallets": ["paytm"]
      }
    };

    try {
      razorpay!.open(options);
    } catch (e) {
      print(e.toString());
    }
  }

  void handlerPaymentSuccess(PaymentSuccessResponse response) {
    print('pago realizado con exito');
    print(response.paymentId);
    _navigateToSuccess(context);
  }

  void handlerPaymentError(PaymentFailureResponse response) {
    print('error en el pago');
    print(response.code.toString());
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text(
                "Hubo un error con su método de pago o el pago fue cancelado \n\nIntente denuevo más tarde"),
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

  void handlerExternalWallet(ExternalWalletResponse response) {
    print('pago con billetera externa');
    print(response.walletName);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.cyan[200],
      appBar: AppBar(
        title: Text('Pago'),
        backgroundColor: Colors.cyan[800],
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(7.0),
              height: 130.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Selecciona tu forma de pago',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(7.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 50.0,
                    ),
                    CustomButton(
                        onTap: () {
                          _navigateToPayPal(context);
                        },
                        text: 'PayPal',
                        imagePath: 'assets/paypal.png'),
                    SizedBox(
                      height: 15.0,
                    ),
                    CustomButton(
                        onTap: () {
                          _navigateToMercadoPago();
                        },
                        text: 'MercadoPago',
                        imagePath: 'assets/mercado-pago.png'),
                    SizedBox(
                      height: 15.0,
                    ),
                    CustomButton(
                        onTap: () {
                          openCheckout();
                        },
                        text: 'Razorpay',
                        imagePath: 'assets/razorpay.png'),
                    SizedBox(
                      height: 15.0,
                    ),
                    CustomButton(
                        onTap: () {
                          _navigateToStripe(context);
                        },
                        text: 'Stripe',
                        imagePath: 'assets/stripe.png'),
                  ],
                ),
              ),
            ),
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
                    '\$' + globals.total, //total.toStringAsFixed(2),
                    style: TextStyle(fontSize: 28.0),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _navigateToStripe(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StripeOptions()),
    );
  }

  void _navigateToPayPal(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => PaypalPayment(
          onFinish: (number) async {
            // payment done
            print('order id: ' + number);
            _navigateToSuccess(context);
          },
        ),
      ),
    );
  }

  void _navigateToSuccess(BuildContext context) async {
    await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SuccessfulPayment()),
        (route) => false);
  }

  void mercadoPagoOK(idPago, status, statusDetails) {
    print("idPago $idPago");
    print("status $status");
    print("statusDetails $statusDetails");
    _navigateToSuccess(context);
  }

  void mercadoPagoERROR(error) {
    print("error $error");
  }

  Future<Map<String, dynamic>> armarPreferencia() async {
    var mp = MP(globals.mpClientID, globals.mpClientSecret);

    var preference = {
      "items": [
        {
          "title": "Productos de papelería " + DateTime.now().toString(),
          "quantity": 1,
          "currency_id": "MXN",
          "unit_price": double.parse(globals.total)
        }
      ],
      "payer": {"name": globals.user, "email": globals.email},
      "payment_methods": {
        "excluded_payment_types": [
          //{"id": "ticket"},
          {"id": "atm"}
        ]
      }
    };

    var result = await mp.createPreference(preference);

    return result;
  }

  Future<void> _navigateToMercadoPago() async {
    armarPreferencia().then((result) {
      if (result != null) {
        var preferenceId = result['response']['id'];
        //print('resultado: ' + preferenceId);
        try {
          const channelMercadoPago =
              const MethodChannel("waviacademy.com/mercadoPago");

          final response = channelMercadoPago.invokeMethod(
              'mercadoPago', <String, dynamic>{
            "publicKey": globals.mpTESTPublicKey,
            "preferenceId": preferenceId
          });

          print(response);
        } on PlatformException catch (e) {
          print(e.message);
        }
      }
    });
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final String imagePath;
  final Color color;
  final Color textColor;
  final VoidCallback? onTap;

  const CustomButton({
    Key? key,
    required this.text,
    required this.imagePath,
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
              Image.asset(
                imagePath,
                height: 38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
