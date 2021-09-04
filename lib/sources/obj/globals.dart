library my_prj.globals;

import 'package:proyecto_final/sources/obj/product_on_cart.dart';
import 'package:proyecto_final/sources/obj/sale.dart';

String user = '';
String total = '';
String email = '';
List<ProductOnCart> cart = [];
bool cartToPay = false;

String mpTESTPublicKey = "TEST-4cd37a74-fd54-47b5-8c30-ef9bfc8a6f54";
String mpTESTAccessToken =
    "TEST-7510030192174874-083008-ef17432e80f8e344ee0563791dc30302-130160313";

String mpPublicKey = "APP_USR-57da62e2-c3fe-488e-a623-bdde25580be5";
String mpAccessToken =
    "APP_USR-7510030192174874-083008-10ea42e0b254a71f1eda1cbe027535bf-130160313";

String mpClientID = "7510030192174874";
String mpClientSecret = "Bh2xZ3OeNd29qH3q2uviwuGNDlLh8omK";

String razorpay_keyId = 'rzp_test_7RfGQWJBQj7XIf';
String razorpay_keySecret = 'voDMrnFYOKjt0Tz0oA08fCLj';

String client = '';
String phone = '';

String address = '';
String method = '';
String receiverName = '';
bool shippment = false;

Sale? selectedSale;
