class Stock {
  String stockId;
  String productId;
  String productCode;
  int qty;

  Stock({this.productId, this.productCode, this.qty, this.stockId});

  Map toMap(Stock stock) {
    var data = Map<String, dynamic>();

    data['stock_id'] = stock.stockId;
    data['product_id'] = stock.productId;
    data['product_code'] = stock.productCode;
    data['quantity'] = stock.qty;

    return data;
  }

  Stock.fromMap(Map<String, dynamic> mapData) {
    this.productId = mapData['product_id'];
    this.stockId = mapData['stock_id'];
    this.productCode = mapData['product_code'];
    this.qty = mapData['quantity'];
  }
}
