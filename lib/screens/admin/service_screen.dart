import 'dart:math';
import 'package:stock_q/models/bill.dart';
import 'package:stock_q/models/category.dart';
import 'package:stock_q/models/paid.dart';
import 'package:stock_q/models/product.dart';
import 'package:stock_q/models/services.dart';
import 'package:stock_q/resources/admin_methods.dart';
import 'package:stock_q/screens/admin/add/add_product.dart';
import 'package:stock_q/screens/custom_loading.dart';
import 'package:stock_q/screens/root_screen.dart';
import 'package:stock_q/utils/universal_variables.dart';
import 'package:stock_q/utils/utilities.dart';
import 'package:stock_q/widgets/bouncy_page_route.dart';
import 'package:stock_q/widgets/custom_appbar.dart';
import 'package:stock_q/widgets/dialogs.dart';
import 'package:stock_q/widgets/header.dart';
import 'package:stock_q/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_icons/flutter_icons.dart';

AdminMethods adminMethods = AdminMethods();

class ServiceScreen extends StatefulWidget {
  ServiceScreen({Key key}) : super(key: key);

  @override
  _ServiceScreenState createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  TextEditingController _billNumberController = TextEditingController();
  TextEditingController serviceReasonController = TextEditingController();
  TextEditingController serviceAmountController = TextEditingController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.QR);
      //print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _billNumberController = TextEditingController(text: barcodeScanRes);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
            bgColor: Colors.white,
            title: Text("Stock Q", style: Variables.appBarTextStyle),
            actions:  [
              IconButton(
                  icon: Icon(
                    FontAwesome.qrcode,
                    color: Variables.primaryColor,
                  ),
                  onPressed: () => scanQR())
            ],
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
      body: ListView(
          physics: const BouncingScrollPhysics(),
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 5),
              color: Colors.white,
              child: Card(
                elevation: 3,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: Column(
                    children: <Widget>[
                      BuildHeader(
                        text: "SERVICES",
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      buildBillNoField(),
                      SizedBox(
                        height: 20,
                      ),
                      buildServiceReasonField(),
                      SizedBox(
                        height: 20,
                      ),
                      buildAmountField(),
                      SizedBox(
                        height: 20,
                      ),
                      buildBottomContainer()

                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }
  
  buildBottomContainer() {
    return buildRaisedButton('Paid', Colors.green[300], Colors.white, () {
      showDialog(
          context: context,
          builder: (context) {
            TextEditingController _customerNameController =
                TextEditingController();
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              title: Text("Enter Customer Name"),
              content: Container(
                padding: EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8)),
                child: TextFormField(
                  cursorColor: Variables.primaryColor,
                  validator: (value) {
                    if (value.trim().isEmpty)
                      return "You cannot have an empty name!";
                    return null;
                  },
                  maxLines: 1,
                  style: Variables.inputTextStyle,
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.person,
                        size: 16,
                      ),
                      border: InputBorder.none,
                      hintText: 'Ram'),
                  controller: _customerNameController,
                ),
              ),
              actions: [
                buildRaisedButton(
                    "Confirm", Variables.primaryColor, Colors.white,
                    () async {
                      ServicesModel servicesModel = ServicesModel(
                        serviceId: FirebaseFirestore.instance.collection('services').doc().id,
                        billNo: _billNumberController.text,
                        serviceAmount: int.parse(serviceAmountController.text),
                        serviceReason: serviceReasonController.text,
                        customerName: _customerNameController.text,
                        timestamp: Timestamp.now()
                      );
                      print(servicesModel.timestamp);
                      adminMethods.addServiceInDB(servicesModel);
                      Navigator.pop(context);
                      _billNumberController.clear();
                      serviceAmountController.clear();
                      serviceReasonController.clear();
                      _customerNameController.clear();
                      final snackbar =
                          customSnackBar("Added Successfully", Variables.blackColor);
                      _scaffoldKey.currentState.showSnackBar(snackbar);
                })
              ],
            );
          });
    });
  }

  buildBillNoField() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            padding: EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
                color: Colors.yellow[100],
                borderRadius: BorderRadius.circular(8)),
            child: TextField(
              maxLines: 1,
              style: Variables.inputTextStyle,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: 'Bill number'),
              controller: _billNumberController,
            ),
          ),
        ),
      ],
    );
  }


  buildServiceReasonField() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            padding: EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
                color: Colors.yellow[100],
                borderRadius: BorderRadius.circular(8)),
            child: TextField(
              maxLines: 1,
              style: Variables.inputTextStyle,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: 'Service Reason'),
              controller: serviceReasonController,
            ),
          ),
        ),
      ],
    );
  }

  buildAmountField() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            padding: EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
                color: Colors.yellow[100],
                borderRadius: BorderRadius.circular(8)),
            child: TextField(
              maxLines: 1,
              style: Variables.inputTextStyle,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: 'Enter Service Amount'),
              controller: serviceAmountController,
            ),
          ),
        ),
      ],
    );
  }

}