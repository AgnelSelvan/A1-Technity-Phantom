import 'package:cloud_firestore/cloud_firestore.dart';

class ServicesModel {
  String serviceId;
  String billNo;
  String serviceReason;
  int serviceAmount;
  String customerName;
  Timestamp timestamp;

  ServicesModel({this.billNo, this.serviceReason, this.serviceAmount, this.serviceId, this.customerName, this.timestamp});

  Map toMap(ServicesModel services) {
    var data = Map<String, dynamic>();

    data['service_id'] = services.serviceId;
    data['bill_no'] = services.billNo;
    data['service_reason'] = services.serviceReason;
    data['service_amount'] = services.serviceAmount;
    data['customer_name'] = services.customerName;
    data['timestamp'] = services.timestamp;

    return data;
  }

  ServicesModel.fromMap(Map<String, dynamic> mapData) {
    this.billNo = mapData['bill_no'];
    this.serviceId = mapData['service_id'];
    this.serviceReason = mapData['service_reason'];
    this.serviceAmount = mapData['service_amount'];
    this.customerName = mapData['customer_name'];
    this.timestamp = mapData['timestamp'];
  }
}
