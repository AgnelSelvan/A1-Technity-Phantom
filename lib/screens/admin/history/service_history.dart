import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:stock_q/models/services.dart';
import 'package:stock_q/screens/admin/service_screen.dart';
import 'package:stock_q/screens/custom_loading.dart';
import 'package:stock_q/utils/universal_variables.dart';
import 'package:stock_q/widgets/custom_appbar.dart';

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
      for (var i = 0; i < listServicesModel.length; i++) {
        print(listServicesModel[i].customerName);
      }
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
      appBar: CustomAppBar(
        bgColor: Colors.white,
        title: Text("Service History " + widget.billNo, style: Variables.appBarTextStyle),
        actions: null,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Ionicons.ios_arrow_back,
            color: Variables.primaryColor,
          ),
        ),
        centerTitle: true),
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
                  trailing: Column(
                    children: [
                      Text("₹ " + e.serviceAmount.toString()),
                      Text(DateFormat('dd/MM/yyyy')
                        .format(e.timestamp.toDate())
                        .toString(), style: TextStyle(
                          color: Colors.grey[500],
                        ),),
                    ],
                  )
                )
            ).toList()
          ),
        ),
      ) ,
    );
  }
}