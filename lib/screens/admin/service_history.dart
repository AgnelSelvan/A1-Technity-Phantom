import 'package:flutter/material.dart';
import 'package:stock_q/models/services.dart';
import 'package:stock_q/screens/admin/service_screen.dart';
import 'package:stock_q/screens/custom_loading.dart';

class ServiceHistoryScreen extends StatefulWidget {
  final String billNo;
  ServiceHistoryScreen({Key key, this.billNo}) : super(key: key);

  @override
  _ServiceHistoryScreenState createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  List<ServicesModel> listServicesModel = [];
  bool isLoading = false;

  getInitData() async {
    setState(() {
      isLoading = true;
    });
    adminMethods.getServicesByBillNo(widget.billNo).then((value){
      setState(() {
        listServicesModel = value;
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getInitData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ? CustomCircularLoading() : Container(
        padding: EdgeInsets.all(8),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: listServicesModel.length == 0 ? Container(
              child: Text("No Service Record Exists", style: TextStyle(
                color: Colors.red
              ),),
            ) : listServicesModel.map((e) => 
              ListTile(
                title: Text(e.customerName,),
                subtitle: Text(e.serviceReason,),
                trailing: Text("₹ " + e.serviceAmount.toString())
              )
            )
          ),
        ),
      ) ,
    );
  }
}