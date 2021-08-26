import 'package:firebase_database/firebase_database.dart';

class ProductOnCart {
  String? _id;
  String? _quantity;
  bool? _available;

  ProductOnCart(this._id, this._quantity, this._available);

  ProductOnCart.map(dynamic obj) {
    this._quantity = obj['cantidad'];
  }

  String? get id => _id;
  String? get quantity => _quantity;
  bool? get available => _available;

  ProductOnCart.fromSnapShot(DataSnapshot snapshot) {
    _id = snapshot.key;
    _quantity = int.parse(snapshot.value['cantidad']).toString();
  }
}
