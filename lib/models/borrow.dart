class Borrow {
  String borrowId;
  String billId;

  Borrow({this.borrowId, this.billId});
  Map toMap(Borrow borrow) {
    var data = Map<String, dynamic>();
    data['borrow_id'] = borrow.borrowId;
    data['bill_id'] = borrow.billId;
    return data;
  }

  Borrow.fromMap(Map<String, dynamic> mapData) {
    this.borrowId = mapData['borrow_id'];
    this.billId = mapData['bill_id'];
  }
}
