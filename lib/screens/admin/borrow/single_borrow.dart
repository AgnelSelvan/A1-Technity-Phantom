import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:image/image.dart' as I;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:save_in_gallery/save_in_gallery.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:stock_q/models/bill.dart';
import 'package:stock_q/models/product.dart';
import 'package:stock_q/models/user.dart';
import 'package:stock_q/resources/admin_methods.dart';
import 'package:stock_q/resources/auth_methods.dart';
import 'package:stock_q/screens/admin/borrow/pdf_viewer.dart';
import 'package:stock_q/screens/custom_loading.dart';
import 'package:stock_q/utils/universal_variables.dart';
import 'package:stock_q/utils/utilities.dart';
import 'package:stock_q/widgets/bouncy_page_route.dart';
import 'package:stock_q/widgets/custom_appbar.dart';
import 'package:stock_q/widgets/dialogs.dart';
import 'package:stock_q/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

AdminMethods _adminMethods = AdminMethods();
AuthMethods _authMethods = AuthMethods();

class SingleBorrow extends StatefulWidget {
  final String mobileNo;

  SingleBorrow({@required this.mobileNo});

  @override
  _SingleBorrowState createState() => _SingleBorrowState();
}

class _SingleBorrowState extends State<SingleBorrow> {
  TextEditingController _buyerInfoController = TextEditingController();
  GlobalKey _containerKey = GlobalKey();
  UserModel currentUser;
  final _imageSaver = ImageSaver();
  bool isLoading = false;
  final pdf = pw.Document();
  List<Bill> billsList = List();
  double amountToBeGiven = 0;
  List<dynamic> taxList = List();

  generatePdf(Bill bill) async {
    double amount = 0;
    double grossAmount = 0;
    double totalSGST = 0;
    double totalCGST = 0;
    String amounten;
    List<List<dynamic>> datas = List();
    for (dynamic i = 0; i < bill.productList.length; i++) {
      List<dynamic> data = List();
      Product product = await _adminMethods
          .getProductDetailsFromProductId(bill.productListId[i]);
      data.add(bill.productList[i]);
      data.add(product.hsnCode);
      data.add(bill.taxList[i]);
      data.add(bill.qtyList[i]);
      data.add(bill.sellingRateList[i]);
      amount = amount +
          ((bill.qtyList[i] * bill.sellingRateList[i]) +
              ((bill.qtyList[i] * bill.sellingRateList[i]) *
                  (bill.taxList[i] / 100)));
      grossAmount = grossAmount + (bill.qtyList[i] * bill.sellingRateList[i]);
      totalSGST = totalSGST +
          (((bill.qtyList[i] * bill.sellingRateList[i]) *
                  (bill.taxList[i] / 100)) /
              2);
      totalCGST = totalCGST +
          (((bill.qtyList[i] * bill.sellingRateList[i]) *
                  (bill.taxList[i] / 100)) /
              2);
      datas.add(data);
      //print("totalSGST:$totalSGST");
    }
    setState(() {
      // amounten = NumberWordsSpelling.toWord(amount.toStringAsFixed(0), 'en_US');
      amounten = amount.toStringAsFixed(0);
    });
    generatePakkaBillPdf(context, bill, datas, grossAmount, totalSGST,
        totalCGST, amounten, amount);
  }

  generatePakkaBillPdf(
      context,
      Bill bill,
      List<List<dynamic>> datas,
      double grossAmount,
      double totalSGST,
      double totalCGST,
      String amounten,
      double amount) async {
    if (await Permission.storage.request().isGranted) {
      try {
        String fullPath = await Utils.generatePakkaBill(
            bill,
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

  getCurrentUser() async {
    setState(() {
      isLoading = true;
    });
    User user = await _authMethods.getCurrentUser();
    if (user == null) {
      Dialogs.okDialog(
          context, 'Error', 'Check your internet connection', Colors.red[200]);
    } else {
      UserModel nowUser = await _authMethods.getUserDetailsById(user.uid);
      setState(() {
        currentUser = nowUser;
        isLoading = false;
      });
    }
    //print(currentUser.mobileNo);
  }

  convertWidgetToImage() async {
    setState(() {
      isLoading = true;
    });
    RenderRepaintBoundary renderRepaintBoundary =
        _containerKey.currentContext.findRenderObject();
    ui.Image boxImage = await renderRepaintBoundary.toImage(pixelRatio: 1);
    ByteData byteData =
        await boxImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List png = byteData.buffer.asUint8List();
    List<Uint8List> pngList = [];
    final dir = await getExternalStorageDirectory();
    pngList.add(png);
    final res = await _imageSaver.saveImages(
        imageBytes: pngList, directoryName: '${dir.path}/image.jpg');
    //print(res.toString());

    //print(dir.path);

    final file = await new File('${dir.path}/sample.png').create();
    file.writeAsBytesSync(png);
    //print(file);

    String text =
        'Dear sir/madam, your payment of ₹ ${amountToBeGiven.round().toString()} is still pending. Make payment as soon as possible';
    try {
      await Share.file('esys image', 'sample.png', png, 'image/png',
          text: text);
    } catch (e) {
      Dialogs.okDialog(
          context, 'Error', 'Error launching whatsapp', Colors.red[200]);
    }

    // String text =
    //     'Dear sir/madam, your payment of ₹ ${(borrowModel.price - borrowModel.givenAmount).toString()} is still pending. Make payment as soon as possible';
    // //print("Hii");
    // var uri =
    //     "whatsapp://send?phone=${borrowModel.mobileNo}&text=$text&img=${file.path}";
    // if (await canLaunch(uri)) {
    //   await launch(uri);
    // } else {
    //   Dialogs.okDialog(
    //       context, 'Error', 'Error launching whatsapp', Colors.red[200]);
    // }
    setState(() {
      isLoading = false;
    });
  }

  getBillsByMobileNo() async {
    amountToBeGiven = 0;
    List<Bill> docsList =
        await _adminMethods.getBillByMobileNo(widget.mobileNo);
    for (var doc in docsList) {
      int totalTax = 0;
      for (var tax in doc.taxList) {
        totalTax = totalTax + tax;
      }
      taxList.add(totalTax);
    }
    for (var i = 0; i < docsList.length; i++) {
      if (docsList[i].isTax)
        amountToBeGiven = amountToBeGiven +
            ((docsList[i].price +
                (docsList[i].price * (taxList[i] / 100)) -
                docsList[i].givenAmount));
      else
        amountToBeGiven =
            amountToBeGiven + (docsList[i].price - docsList[i].givenAmount);
    }
    setState(() {
      billsList = docsList;
    });
    //print(taxList);
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getBillsByMobileNo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
            bgColor: Colors.white,
            title: Text("Stock Q", style: Variables.appBarTextStyle),
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
        body: isLoading
            ? CustomCircularLoading()
            : SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StickyHeader(
                        header: buildStickyHeaderListView(context),
                        content: buildStickyBody(),
                      ),
                    ],
                  ),
                ),
              ));
  }

  buildStickyBody() {
    return ListView(
      shrinkWrap: true,
      children: [
        currentUser.role == 'admin' ? buildBodyHeadButtons() : Container(),
        buildEntries()
      ],
    );
  }

  buildEntries() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  "Bill No",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: .5),
                ),
              ),
              SizedBox(height: 15),
              Column(
                  children: List.generate(billsList.length, (index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FocusedMenuHolder(
                      blurSize: 2,
                      menuItems: <FocusedMenuItem>[
                        FocusedMenuItem(
                            title: Text("Report"),
                            onPressed: () {
                              if (billsList[index].isTax == null) {
                                Dialogs.okDialog(context, 'Error',
                                    'Somthing went wrong!', Colors.red[200]);
                              } else {
                                if (currentUser.role == 'admin') {
                                  billsList[index].isTax
                                      ? getBuyerName(billsList[index])
                                      : getKachaBill(billsList[index]);
                                } else {
                                  billsList[index].isTax
                                      ? generatePdf(billsList[index])
                                      : getKachaBill(billsList[index]);
                                }
                              }
                            },
                            trailingIcon: Icon(
                              FontAwesome.file_pdf_o,
                              size: 16,
                              color: Colors.red[200],
                            )),
                        FocusedMenuItem(
                            title: Text("Update Given Amount"),
                            onPressed: () {
                              showUpdateGivenAmount(billsList[index]);
                            },
                            trailingIcon: Icon(
                              FontAwesome.rupee,
                              size: 16,
                              color: Colors.orange[200],
                            )),
                      ],
                      onPressed: () {},
                      child: Container(
                        height: 25,
                        alignment: Alignment.center,
                        child: Text(
                          billsList[index].billNo == null ||
                                  billsList[index].billNo == ""
                              ? "Null"
                              : billsList[index].billNo.toString(),
                          style: TextStyle(
                              color: Variables.blackColor,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 0.3),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                  ],
                );
              }))
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  "Date",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: .5),
                ),
              ),
              SizedBox(height: 15),
              Column(
                  children: List.generate(billsList.length, (index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 25,
                      alignment: Alignment.center,
                      child: Text(
                        DateFormat('dd/MM/yyyy')
                            .format(billsList[index].timestamp.toDate()),
                        style: TextStyle(
                            color: Variables.blackColor,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.3),
                      ),
                    ),
                    SizedBox(height: 5),
                  ],
                );
              }))
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  "Price",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: .5),
                ),
              ),
              SizedBox(height: 15),
              SizedBox(height: 5),
              Column(
                  children: List.generate(billsList.length, (index) {
                return Column(
                  children: [
                    Container(
                      height: 25,
                      alignment: Alignment.center,
                      child: Text(
                        billsList[index].isTax
                            ? '₹${(billsList[index].price + (billsList[index].price * (taxList[index] / 100))).toStringAsFixed(2).toString()}'
                            : '₹${billsList[index].price.toStringAsFixed(2).toString()}',
                        style: TextStyle(
                            color: Variables.blackColor,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.3),
                      ),
                    ),
                    SizedBox(height: 5),
                  ],
                );
              }))
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  "You Got",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: .5),
                ),
              ),
              SizedBox(height: 15),
              SizedBox(height: 5),
              Column(
                  children: List.generate(billsList.length, (index) {
                return Column(
                  children: [
                    Container(
                      height: 25,
                      alignment: Alignment.center,
                      child: Text(
                        '₹${billsList[index].givenAmount.toString()}',
                        style: TextStyle(
                            color: Variables.blackColor,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.3),
                      ),
                    ),
                    SizedBox(height: 5),
                  ],
                );
              }))
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  "Ttl Price",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: .5),
                ),
              ),
              SizedBox(height: 15),
              Column(
                  children: List.generate(billsList.length, (index) {
                return Column(
                  children: [
                    Container(
                      height: 25,
                      alignment: Alignment.center,
                      child: Text(
                        billsList[index].isTax
                            ? '₹${((billsList[index].price + (billsList[index].price * (taxList[index] / 100))) - billsList[index].givenAmount).round().toString()}'
                            : '₹${(billsList[index].price - billsList[index].givenAmount).round().toString()}',
                        style: TextStyle(
                            color: Variables.blackColor,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.3),
                      ),
                    ),
                    SizedBox(height: 5),
                  ],
                );
              }))
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  "Paid",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: .5),
                ),
              ),
              SizedBox(height: 10),
              Column(
                  children: List.generate(billsList.length, (index) {
                return Column(
                  children: [
                    Container(
                      height: 25,
                      alignment: Alignment.center,
                      child: Text(
                        billsList[index].isPaid ? 'Yes' : 'No',
                        style: TextStyle(
                            color: Variables.blackColor,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.3),
                      ),
                    ),
                    SizedBox(height: 5),
                  ],
                );
              }))
            ],
          )
        ],
      ),
    );
  }

  showUpdateGivenAmount(Bill bill) {
    TextEditingController _givenAmountController = TextEditingController();
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Text('Amount'),
            content: Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                  color: Colors.yellow[100],
                  borderRadius: BorderRadius.circular(8)),
              child: TextFormField(
                cursorColor: Variables.primaryColor,
                keyboardType: TextInputType.number,
                style: Variables.inputTextStyle,
                decoration: InputDecoration(
                    prefix: Icon(
                      FontAwesome.rupee,
                      size: 16,
                      color: Colors.red[200],
                    ),
                    border: InputBorder.none,
                    hintText: '200'),
                controller: _givenAmountController,
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
                  _adminMethods.updateGivenAmount(
                      bill, double.parse(_givenAmountController.text));
                  getBillsByMobileNo();
                  Navigator.pop(context);
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

  getBuyerName(Bill bill) {
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
                  generatePdf(bill);
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

  void _showModalSheet() {
    showModalBottomSheet(
        backgroundColor: Colors.grey[200],
        context: context,
        builder: (builder) {
          return Container(
            padding: EdgeInsets.all(10),
            height: 300,
            child: ListView(
              children: [
                RepaintBoundary(
                  key: _containerKey,
                  child: Container(
                    height: MediaQuery.of(context).size.height / 3,
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Payment reminder for ",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                        ),
                        Text("₹${amountToBeGiven.round().toString()}",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w500)),
                        Text(
                            DateFormat('dd/MM/yyyy')
                                .format(billsList[0].timestamp.toDate()),
                            style: TextStyle(
                                color: Variables.blackColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 0.5)),
                        Text(
                            "Sent by ${currentUser.name == '' ? '' : currentUser.name}",
                            style: TextStyle(
                                color: Variables.blackColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w300)),
                        Text(
                            "${currentUser.mobileNo == null ? '' : currentUser.mobileNo}"),
                      ],
                    ),
                  ),
                ),
                buildRaisedButton(
                    'Send Reminder', Variables.primaryColor, Colors.white, () {
                  convertWidgetToImage();
                })
              ],
            ),
          );
        });
  }

  getKachaBill(Bill bill) async {
    File file = await Utils.generateKachaBill(bill);
    if (file == null) {
      Dialogs.okDialog(
          context, 'Error', "Somthing went wrong!", Colors.red[200]);
    } else {
      String fullPath = file.path;
      //print('Utils working');

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PdfPreviewwScreen(
                    path: fullPath,
                  )));
    }
  }

  buildBodyHeadButtons() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () {
              _showModalSheet();
            },
            child: Column(
              children: [
                Icon(
                  FontAwesome.whatsapp,
                  color: Colors.green[200],
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "Reminder",
                  style: TextStyle(
                      color: Variables.blackColor,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1),
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              var uri =
                  'sms:${widget.mobileNo}?body=Dear sir/madam, your payment of ₹ ${amountToBeGiven.round().toString()} is still pending. Make payment as soon as possible';
              if (await canLaunch(uri)) {
                await launch(uri);
              } else {
                Dialogs.okDialog(context, 'Error', 'Error launching whatsapp',
                    Colors.red[200]);
              }
            },
            child: Column(
              children: [
                Icon(
                  Icons.sms,
                  color: Colors.blue[200],
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "SMS",
                  style: TextStyle(
                      color: Variables.blackColor,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  buildStickyHeaderListView(context) {
    return Container(
        padding: EdgeInsets.all(8),
        height: MediaQuery.of(context).size.height / 4,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Container(
          height: double.infinity,
          width: MediaQuery.of(context).size.width / 2,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Variables.lightPrimaryColor,
              borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "₹ ${amountToBeGiven.round().toString()}",
                style: TextStyle(
                    color: Variables.lightGreyColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    letterSpacing: 1),
              ),
              SizedBox(height: 10),
              Text(
                "You will get",
                style: TextStyle(
                    color: Variables.lightGreyColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    letterSpacing: 1),
              ),
            ],
          ),
        ));
  }
}
