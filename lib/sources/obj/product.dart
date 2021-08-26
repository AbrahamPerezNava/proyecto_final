import 'package:firebase_database/firebase_database.dart';

class Product {
  String? _id;
  String? _desc;
  String? _image;
  String? _price;
  String? _stock;

  Product(this._id, this._desc, this._image, this._price, this._stock);

  Product.map(dynamic obj) {
    this._desc = obj['descripcion'];
    this._image = obj['imagen'];
    this._price = obj['precioVenta'];
    this._stock = obj['stock'];
  }

  String? get id => _id;
  String? get desc => _desc;
  String? get image => _image;
  String? get price => _price;
  String? get stock => _stock;

  Product.fromSnapShot(DataSnapshot snapshot) {
    _id = snapshot.key;
    _desc = snapshot.value['descripcion'];
    _image = snapshot.value['imagen'];
    _price = snapshot.value['precioventa'].toString();
    _stock = snapshot.value['stock'].toString();
  }
}
