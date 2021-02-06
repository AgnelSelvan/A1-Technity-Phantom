class Category {
  String hsnCode;
  String productName;
  int tax;
  String id;

  Category({this.hsnCode, this.productName, this.tax, this.id});

  Map toMap(Category category) {
    var data = Map<String, dynamic>();
    data['hsn_code'] = category.hsnCode;
    data['product_name'] = category.productName;
    data['tax'] = category.tax;
    data['id'] = category.id;

    return data;
  }

  Category.fromMap(Map<String, dynamic> mapData) {
    this.hsnCode = mapData['hsn_code'];
    this.productName = mapData['product_name'];
    this.tax = mapData['tax'];
    this.id = mapData['id'];
  }
}
