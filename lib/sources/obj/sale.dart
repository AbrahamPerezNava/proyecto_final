class Sale {
  String? _id;
  String? _user;
  String? _address;
  String? _shippment;
  String? _date;
  String? _method;
  String? _receiver;
  String? _total;
  Map<Object, Object>? _products;

  Sale(this._id, this._user, this._address, this._shippment, this._date,
      this._method, this._receiver, this._total, this._products);

  String? get id => _id;
  String? get user => _user;
  String? get address => _address;
  String? get shippment => _shippment;
  String? get date => _date;
  String? get method => _method;
  String? get receiver => _receiver;
  String? get total => _total;
  Map<Object, Object>? get products => _products;

  Sale.fromJson(String id, Map<dynamic, dynamic> parsedJson) {
    _id = id;
    _user = parsedJson['cliente'];
    _address = parsedJson['direccion'];
    _shippment = parsedJson['envio'];
    _date = parsedJson['fecha'];
    _method = parsedJson['pasarela'];
    _receiver = parsedJson['receptor'];
    _total = parsedJson['total'];
    _products = parsedJson['productos'];
  }
}
