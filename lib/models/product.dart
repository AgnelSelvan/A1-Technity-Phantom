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
