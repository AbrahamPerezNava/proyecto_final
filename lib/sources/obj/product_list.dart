import 'package:firebase_database/firebase_database.dart';

class ProductList {
  String? _id;
  String? _school;
  String? _group;
  String? _teacher;
  Map<Object, Object>? _products;

  ProductList(
      this._id, this._school, this._group, this._teacher, this._products);

  ProductList.map(dynamic obj) {
    this._school = obj['escuela'];
    this._group = obj['grupo'];
    this._teacher = obj['profesor'];
    this._products = obj['prodcutos'];
  }

  String? get id => _id;
  String? get school => _school;
  String? get group => _group;
  String? get teacher => _teacher;
  Map<Object, Object>? get products => _products;

  ProductList.fromSnapShot(DataSnapshot snapshot) {
    _id = snapshot.key;
    _school = snapshot.value['escuela'];
    _group = snapshot.value['grupo'];
    _teacher = snapshot.value['profesor'];
    _products = snapshot.value['productos'];
  }

  ProductList.fromJson(String id, Map<dynamic, dynamic> parsedJson) {
    _id = id;
    _school = parsedJson['escuela'];
    _group = parsedJson['grupo'];
    _teacher = parsedJson['profesor'];
    _products = parsedJson['productos'];
  }
}
