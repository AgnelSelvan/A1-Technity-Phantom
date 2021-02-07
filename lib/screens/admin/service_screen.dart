import 'dart:math';
import 'package:stock_q/models/bill.dart';
import 'package:stock_q/models/category.dart';
import 'package:stock_q/models/paid.dart';
import 'package:stock_q/models/product.dart';
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

class ServiceScreen extends StatefulWidget {
  ServiceScreen({Key key}) : super(key: key);

  @override
  _ServiceScreenState createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  TextEditingController _billNumberController = TextEditingController();
  
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
      body: Text("Hello"),
    );
  }
}