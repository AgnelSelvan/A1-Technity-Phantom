import 'package:cloud_firestore/cloud_firestore.dart';

class Bill {
  String billId;
  List<dynamic> productListId;
  List<dynamic> productList;
  List<dynamic> qtyList;
  List<dynamic> taxList;
  List<dynamic> sellingRateList;
  double price;
  double givenAmount;
  String billNo;
  String mobileNo;
  Timestamp timestamp;
  String customerName;
  bool isTax;
  bool isPaid;
  String borrowId;
  String paidId;

  Bill(
      {this.billNo,
      this.billId,
      this.customerName,
      this.givenAmount,
      this.mobileNo,
      this.price,
      this.productList,
      this.timestamp,
      this.qtyList,
      this.sellingRateList,
      this.taxList,
      this.productListId,
      this.isTax,
      this.isPaid,
      this.borrowId,
      this.paidId});
  Map toMap(Bill bill) {
    var data = Map<String, dynamic>();
    data['bill_no'] = bill.billNo;
    data['bill_id'] = bill.billId;
    data['customer_name'] = bill.customerName;
    data['given_amount'] = bill.givenAmount;
    data['mobile_no'] = bill.mobileNo;
    data['price'] = bill.price;
    data['timestamp'] = bill.timestamp;
    data['product_list'] = bill.productList;
    data['quantity_list'] = bill.qtyList;
    data['selling_rate_list'] = bill.sellingRateList;
    data['tax_list'] = bill.taxList;
    data['product_list_id'] = bill.productListId;
    data['is_tax'] = bill.isTax;
    data['is_paid'] = bill.isPaid;
    data['borrow_id'] = bill.borrowId;
    data['paid_id'] = bill.paidId;
    return data;
  }

  Bill.fromMap(Map<String, dynamic> mapData) {
    this.billNo = mapData['bill_no'];
    this.billId = mapData['bill_id'];
    this.customerName = mapData['customer_name'];
    this.givenAmount = mapData['given_amount'];
    this.mobileNo = mapData['mobile_no'];
    this.price = mapData['price'];
    this.productList = mapData['product_list'];
    this.qtyList = mapData['quantity_list'];
    this.sellingRateList = mapData['selling_rate_list'];
    this.taxList = mapData['tax_list'];
    this.timestamp = mapData['timestamp'];
    this.productListId = mapData['product_list_id'];
    this.isTax = mapData['is_tax'];
    this.isPaid = mapData['is_paid'];
    this.borrowId = mapData['borrow_id'];
    this.paidId = mapData['paid_id'];
  }
}
