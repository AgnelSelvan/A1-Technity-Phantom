import 'package:stock_q/models/review.dart';

class DummyProductModel {
  String productId, title, description;
  int stock, discount, price, productRating;
  List<Review> reviews;
  List<Map<String, dynamic>> previewImages;
  Map<String, dynamic> thumbnailImage;

  DummyProductModel(
      {this.productId,
      this.title,
      this.description,
      this.productRating,
      this.stock,
      this.discount,
      this.reviews,
      this.price,
      this.thumbnailImage,
      this.previewImages});

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["productId"] = this.productId ?? '';
    map["title"] = this.title ?? '';
    map["description"] = this.description ?? '';
    map["stock"] = this.stock ?? 0;
    map["productRating"] = this.productRating ?? 0;
    map["discount"] = this.discount ?? 0;
    map["reviews"] = this.reviews ?? [];
    map["price"] = this.price ?? 100;
    map["previewImages"] = this.previewImages ?? [];
    map["thumbnailImage"] = this.thumbnailImage ?? {};
    return map;
  }
}

class ProductModel {
  String code;
  String name;
  String id;
  String hsnCode;
  String unit;
  int unitQty;
  double purchaseRate;
  double sellingRate;

  ProductModel(
      {this.name,
      this.code,
      this.purchaseRate,
      this.sellingRate,
      this.unitQty,
      this.id,
      this.unit,
      this.hsnCode});

  Map toMap(ProductModel product) {
    var data = Map<String, dynamic>();
    data['code'] = product.code;
    data['name'] = product.name;
    data['id'] = product.id;
    data['purchase_rate'] = product.purchaseRate;
    data['selling_rate'] = product.sellingRate;
    data['hsn_code'] = product.hsnCode;
    data['unit'] = product.unit;
    data['unit_qty'] = product.unitQty;

    return data;
  }

  ProductModel.fromMap(Map<String, dynamic> mapData) {
    this.code = mapData['code'];
    this.name = mapData['name'];
    this.id = mapData['id'];
    this.purchaseRate = mapData['purchase_rate'];
    this.sellingRate = mapData['selling_rate'];
    this.hsnCode = mapData['hsn_code'];
    this.unit = mapData['unit'];
    this.unitQty = mapData['unit_qty'];
  }
}
