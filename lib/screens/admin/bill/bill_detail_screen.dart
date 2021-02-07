import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stock_q/models/bill.dart';
import 'package:stock_q/models/product.dart';
import 'package:stock_q/resources/admin_methods.dart';
import 'package:stock_q/screens/admin/history/service_history.dart';
import 'package:stock_q/widgets/pdf_viewer.dart';
import 'package:stock_q/screens/custom_loading.dart';
import 'package:stock_q/utils/universal_variables.dart';
import 'package:stock_q/utils/utilities.dart';
import 'package:stock_q/widgets/bouncy_page_route.dart';
import 'package:stock_q/widgets/custom_appbar.dart';
import 'package:stock_q/widgets/dialogs.dart';
import 'package:stock_q/widgets/header.dart';

AdminMethods _adminMethods = AdminMethods();

class BillDetails extends StatefulWidget {
  final String billId;

  BillDetails({this.billId});

  @override
  _BillDetailsState createState() => _BillDetailsState();
}

class _BillDetailsState extends State<BillDetails> {
  Bill currentBill;
  bool isLoading = false;
  double totalTax = 0;
  TextEditingController _buyerInfoController = TextEditingController();

  generatePdf() async {
    double amount = 0;
    double grossAmount = 0;
    double totalSGST = 0;
    double totalCGST = 0;
    String amounten;
    List<List<dynamic>> datas = List();
    for (dynamic i = 0; i < currentBill.productList.length; i++) {
      List<dynamic> data = List();
      Product product = await _adminMethods
          .getProductDetailsFromProductId(currentBill.productListId[i]);
      data.add(currentBill.productList[i]);
      data.add(product.hsnCode);
      data.add(currentBill.taxList[i]);
      data.add(currentBill.qtyList[i]);
      data.add(currentBill.sellingRateList[i]);
      amount = amount +
          ((currentBill.qtyList[i] * currentBill.sellingRateList[i]) +
              ((currentBill.qtyList[i] * currentBill.sellingRateList[i]) *
                  (currentBill.taxList[i] / 100)));
      grossAmount = grossAmount +
          (currentBill.qtyList[i] * currentBill.sellingRateList[i]);
      totalSGST = totalSGST +
          (((currentBill.qtyList[i] * currentBill.sellingRateList[i]) *
              (currentBill.taxList[i] / 100)) /
              2);
      totalCGST = totalCGST +
          (((currentBill.qtyList[i] * currentBill.sellingRateList[i]) *
              (currentBill.taxList[i] / 100)) /
              2);
      datas.add(data);
      //print("totalSGST:$totalSGST");
    }
    setState(() {
      // amounten = NumberWordsSpelling.toWord(amount.toStringAsFixed(0), 'en_US');
      amounten = amount.toStringAsFixed(0);
    });
    generatePakkaBillPdfAndView(
        context, datas, grossAmount, totalSGST, totalCGST, amounten, amount);
  }

  generatePakkaBillPdfAndView(context,
      List<List<dynamic>> datas,
      double grossAmount,
      double totalSGST,
      double totalCGST,
      String amounten,
      double amount) async {
    if (await Permission.storage.request().isGranted) {
      try {
        String fullPath = await Utils.generatePakkaBill(
            currentBill,
            _buyerInfoController.text,
            datas,
            grossAmount,
            totalSGST,
            totalCGST,
            amounten,
            amount);
        if (fullPath == 'textfieldError') {
          Dialogs.okDialog(context, 'Error',
              'Dont use next line in buyer info textfield', Colors.red[200]);
        } else {
          Navigator.push(
              context,
              BouncyPageRoute(
                  widget: PdfPreviewwScreen(
                    path: fullPath,
                  )));
        }
      } catch (e) {
        Dialogs.okDialog(
            context, 'Error', 'Something went wrong!', Colors.red[200]);
      }
    } else {
      Dialogs.okDialog(
          context, 'Error', 'You have denied your permission', Colors.red[200]);
    }

    setState(() {
      _buyerInfoController.clear();
    });
  }

  getBuyerName() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Text('Buyer Info'),
            content: Container(
              height: MediaQuery.of(context).size.height / 5,
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: <Widget>[
                  Text(
                    "Info",
                    style: Variables.inputLabelTextStyle,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                        color: Colors.yellow[100],
                        borderRadius: BorderRadius.circular(8)),
                    child: TextFormField(
                      maxLines: 5,
                      cursorColor: Variables.primaryColor,
                      style: Variables.inputTextStyle,
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: 'Buyer Info'),
                      controller: _buyerInfoController,
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(DialogAction.Abort);
                },
                child: Text(
                  "No",
                  style: TextStyle(color: Variables.primaryColor),
                ),
              ),
              RaisedButton(
                elevation: 0,
                color: Variables.primaryColor,
                onPressed: () async {
                  Navigator.pop(context);
                  generatePdf();
                },
                child: Text(
                  "Yes",
                  style: TextStyle(color: Variables.lightGreyColor),
                ),
              )
            ],
          );
        });
  }

  getBillDetails() async {
    setState(() {
      isLoading = true;
    });
    Bill _currentBill = await _adminMethods.getBillById(widget.billId);
    setState(() {
      currentBill = _currentBill;
    });
    for (int tax in _currentBill.taxList) {
      setState(() {
        totalTax = totalTax + tax.toDouble();
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getBillDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          bgColor: Colors.white,
          title: Text("Stock Q", style: Variables.appBarTextStyle),
          actions: [
            IconButton(
                icon: Icon(
                  FontAwesome.file_pdf_o,
                  size: 16,
                  color: Colors.red[200],
                ),
                onPressed: () {
                  if (currentBill.isTax == null) {
                    Dialogs.okDialog(context, 'Error', 'Somthing went wrong!',
                        Colors.red[200]);
                  } else {
                    currentBill.isTax ? getBuyerName() : Text("Kacha");
                  }
                })
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
      body: isLoading
          ? CustomCircularLoading()
          : Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: [
            Center(child: BuildHeader(text: 'Bill Details')),
            SizedBox(
              height: 40,
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Bill No: ',
                        style: Variables.inputTextStyle,
                      ),
                      Text(currentBill.billNo)
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        'Date: ',
                        style: Variables.inputTextStyle,
                      ),
                      Text(DateFormat('dd/MM/yy')
                          .format(currentBill.timestamp.toDate()))
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        'Customer Name: ',
                        style: Variables.inputTextStyle,
                      ),
                      Text(currentBill.customerName)
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text("Product:  "),
                      Row(
                        children: List.generate(
                          currentBill.productList.length,
                              (index) => Column(
                            children: [
                              Text(
                                  "${currentBill.productList[index]}(${currentBill.qtyList[index]})\t,"),
                              Text(
                                  " ₹${currentBill.qtyList[index] * currentBill.sellingRateList[index]}")
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        'Price: ',
                        style: Variables.inputTextStyle,
                      ),
                      Text(currentBill.price.toString())
                    ],
                  ),
                  currentBill.isTax ? SizedBox(height: 20) : Container(),
                  currentBill.isTax
                      ? Row(
                    children: [
                      Text(
                        'Tax: ',
                        style: Variables.inputTextStyle,
                      ),
                      Text(totalTax.toString()),
                    ],
                  )
                      : Text("No Tax"),
                  currentBill.isPaid ? Container() : SizedBox(height: 20),
                  currentBill.isPaid
                      ? Container()
                      : Row(
                    children: [
                      Text("Given Amount : "),
                      Text(currentBill.givenAmount.toString()),
                    ],
                  ),
                  SizedBox(height: 20),
                  FlatButton(onPressed: (){
                    Navigator.push(
                      context,
                      BouncyPageRoute(
                          widget: ServiceHistoryScreen( billNo: currentBill.billNo, )));
                  },
                  color: Variables.primaryColor,
                  child: Text(
                      'Service History',
                      style: TextStyle(
                        color: Colors.white
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
