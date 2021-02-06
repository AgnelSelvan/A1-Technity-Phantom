class Paid {
  String buyId;
  String billId;

  Paid({this.buyId, this.billId});

  Map toMap(Paid buys) {
    var data = Map<String, dynamic>();
    data['buy_id'] = buys.buyId;
    data['bill_id'] = buys.billId;
    return data;
  }

  Paid.fromMap(Map<String, dynamic> mapData) {
    this.buyId = mapData['buy_id'];
    this.billId = mapData['bill_id'];
  }
}
