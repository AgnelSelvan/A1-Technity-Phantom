class SubCategory {
  String hsnCode;
  String productName;
  String id;

  SubCategory({this.hsnCode, this.productName, this.id});

  Map toMap(SubCategory category) {
    var data = Map<String, dynamic>();
    data['hsn_code'] = category.hsnCode;
    data['product_name'] = category.productName;
    data['id'] = category.id;

    return data;
  }

  SubCategory.fromMap(Map<String, dynamic> mapData) {
    this.hsnCode = mapData['hsn_code'];
    this.productName = mapData['product_name'];
    this.id = mapData['id'];
  }
}
