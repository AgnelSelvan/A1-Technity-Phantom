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

AdminMethods _adminMethods = AdminMethods();

class BillScreen extends StatefulWidget {
  BillScreen({Key key}) : super(key: key);

  @override
  _BillScreenState createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String randomNumber;
  TextEditingController _codeFieldController = TextEditingController();
  TextEditingController _billNumberController;
  TextEditingController _qtyController;
  TextEditingController _priceController;
  TextEditingController _taxController;
  TextEditingController _totalPriceController;
  String selectedCategory, selectedOption;
  bool viewVisible = false;
  Product currentProduct;
  Category currentCategory;
  List<String> productListId = [];
  List<String> productList = [];
  List<int> qtyList = [];
  List<double> sellingRateList = [];
  List<int> taxList = [];
  double totalPrice;
  int tax;
  bool _isTaxCheckBox = true;

  @override
  void initState() {
    super.initState();
    getBillNo();

    _qtyController = TextEditingController();
    _priceController = TextEditingController();
    _taxController = TextEditingController();
    _totalPriceController = TextEditingController();
  }

  getBillNo() async {
    randomNumber = await _adminMethods.getBillNo();
    setState(() {
      _billNumberController =
          TextEditingController(text: randomNumber.toString());
    });
  }

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

  void showWidget() {
    //print(viewVisible);
    setState(() {
      viewVisible = !viewVisible;
    });
    //print(viewVisible);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Variables.lightGreyColor,
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
                        text: "BILL",
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      buildBillNoField(),
                      SizedBox(
                        height: 15,
                      ),
                      viewVisible ? buildVisibility() : Container(),
                      Row(
                        mainAxisAlignment: viewVisible
                            ? MainAxisAlignment.spaceAround
                            : MainAxisAlignment.center,
                        children: <Widget>[
                          GestureDetector(
                            onTap: showWidget,
                            child: Container(
                              width: 170,
                              decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(100)),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        color: Colors.yellow[100]),
                                    child: Icon(
                                      Icons.add,
                                      color: Variables.blackColor,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    "Add Product",
                                    style: TextStyle(
                                        letterSpacing: 1,
                                        fontSize: 16,
                                        color: Variables.blackColor),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      productList.isEmpty ? Container() : buildTaxCheckBox(),
                      SizedBox(height: 15),
                      productList.isEmpty ? Container() : buildPriceField(),
                      SizedBox(height: 15),
                      _isTaxCheckBox
                          ? productList.isEmpty
                              ? Container()
                              : buildTaxField()
                          : Container(),
                      SizedBox(height: 15),
                      productList.isEmpty
                          ? Container()
                          : buildTotalPriceField(),
                      SizedBox(height: 15),
                      productList.isEmpty
                          ? Container()
                          : buildBottomContainer(),
                      SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  buildTaxCheckBox() {
    return Row(
      children: [
        Checkbox(
            activeColor: Variables.primaryColor,
            focusColor: Variables.primaryColor,
            value: _isTaxCheckBox,
            onChanged: (bool value) {
              //print(value);
              setState(() {
                _isTaxCheckBox = value;
              });
              var sum = 0;
              tax = 0;
              for (var i = 0; i < sellingRateList.length; i++) {
                sum += sellingRateList[i].toInt() * qtyList[i];
                tax += taxList[i];
              }
              if (!_isTaxCheckBox) {
                //print(sum);
                setState(() {
                  totalPrice = sum.toDouble();
                  _totalPriceController =
                      TextEditingController(text: totalPrice.toString());
                });
              }
              if (_isTaxCheckBox) {
                //print(tax);

                totalPrice = (sum + (sum * (tax / 100)));
                setState(() {
                  _totalPriceController =
                      TextEditingController(text: totalPrice.toString());
                });
              }
            }),
        Text(
          "include tax",
          style: TextStyle(fontSize: 16),
        )
      ],
    );
  }

  buildBottomContainer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        buildRaisedButton('Paid', Colors.green[300], Colors.white, () {
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
                      //print(_customerNameController.text);
                      String billId = Utils.getDocId();
                      String paidId = Utils.getDocId();
                      Bill bill = Bill(
                          billId: billId,
                          billNo: _billNumberController.text,
                          customerName: _customerNameController.text,
                          givenAmount: totalPrice,
                          price: totalPrice,
                          productList: productList,
                          timestamp: Timestamp.now(),
                          qtyList: qtyList,
                          sellingRateList: sellingRateList,
                          taxList: taxList,
                          productListId: productListId,
                          isTax: _isTaxCheckBox,
                          isPaid: true,
                          paidId: paidId);
                      Paid paid = Paid(billId: billId, buyId: paidId);
                      bool isBillSubmitted =
                          await _adminMethods.addBillToDb(bill);
                      if (isBillSubmitted) {
                        _adminMethods.addBuyToDb(paid);
                        Navigator.pushAndRemoveUntil(
                            context,
                            BouncyPageRoute(widget: RootScreen()),
                            (route) => true);
                        Dialogs.okDialog(context, 'Successfull',
                            'Added Successfully', Colors.green[200]);
                      } else {
                        Dialogs.okDialog(context, 'Error',
                            'Somthing went wrong', Colors.red[200]);
                      }
                    })
                  ],
                );
              });
        })
      ],
    );
  }

  Visibility buildVisibility() {
    return Visibility(
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        visible: viewVisible,
        child: Container(
            child: Column(
          children: <Widget>[
            buildProductDropdown(),
            SizedBox(
              height: 20,
            ),
          ],
        )));
  }

  Widget buildPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Price",
          style: Variables.inputLabelTextStyle,
        ),
        Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              color: Colors.yellow[100],
              borderRadius: BorderRadius.circular(8)),
          child: TextFormField(
            enabled: false,
            cursorColor: Variables.primaryColor,
            maxLines: 1,
            style: Variables.inputTextStyle,
            decoration:
                InputDecoration(border: InputBorder.none, hintText: '1234'),
            controller: _priceController,
          ),
        ),
      ],
    );
  }

  Widget buildTaxField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Tax",
          style: Variables.inputLabelTextStyle,
        ),
        Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              color: Colors.yellow[100],
              borderRadius: BorderRadius.circular(8)),
          child: TextFormField(
            enabled: false,
            cursorColor: Variables.primaryColor,
            maxLines: 1,
            style: Variables.inputTextStyle,
            decoration:
                InputDecoration(border: InputBorder.none, hintText: '1234'),
            controller: _taxController,
          ),
        ),
      ],
    );
  }

  Widget buildTotalPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Total Price",
          style: Variables.inputLabelTextStyle,
        ),
        Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              color: Colors.yellow[100],
              borderRadius: BorderRadius.circular(8)),
          child: TextFormField(
            enabled: false,
            cursorColor: Variables.primaryColor,
            maxLines: 1,
            style: Variables.inputTextStyle,
            decoration:
                InputDecoration(border: InputBorder.none, hintText: '1234'),
            controller: _totalPriceController,
          ),
        ),
      ],
    );
  }

  Widget buildProductList() {
    return Container(
      height: 200,
      padding: EdgeInsets.all(10),
      child: ListView.builder(
          physics: BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                  color: Variables.greyColor,
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Text(productList[index]),
                    Spacer(),
                    Text('(${qtyList[index]})'),
                    IconButton(
                        icon: Icon(
                          FontAwesome.times_circle,
                          color: Colors.red[200],
                        ),
                        onPressed: () {
                          //print(productList[index]);
                          int productIndex =
                              productList.indexOf(productList[index]);
                          //print(productIndex);
                          setState(() {
                            productList.removeAt(productIndex);
                            productListId.removeAt(productIndex);
                            qtyList.removeAt(productIndex);
                            taxList.removeAt(productIndex);
                            sellingRateList.removeAt(productIndex);
                          });
                          var sum = 0;
                          tax = 0;
                          totalPrice = 0;
                          if (_isTaxCheckBox) {
                            for (var i = 0; i < sellingRateList.length; i++) {
                              sum += sellingRateList[i].toInt() * qtyList[i];
                              tax += taxList[i];
                            }
                            totalPrice = (sum + (sum * (tax / 100)));
                            setState(() {
                              _totalPriceController = TextEditingController(
                                  text: totalPrice.toString());
                              _priceController =
                                  TextEditingController(text: sum.toString());
                              _taxController =
                                  TextEditingController(text: tax.toString());
                            });
                          } else if (!_isTaxCheckBox) {
                            for (var i = 0; i < sellingRateList.length; i++) {
                              sum += sellingRateList[i].toInt() * qtyList[i];
                              tax += taxList[i];
                            }
                            totalPrice = sum.toDouble();
                            setState(() {
                              _totalPriceController = TextEditingController(
                                  text: totalPrice.toString());
                              _priceController =
                                  TextEditingController(text: sum.toString());
                              _taxController =
                                  TextEditingController(text: tax.toString());
                            });
                          }
                          //print(productListId);
                          //print(productList);
                          //print(totalPrice);
                          //print(qtyList);
                          //print(taxList);
                          //print(sellingRateList);
                        })
                  ],
                ),
              ),
            );
          },
          itemCount: productList.length),
    );
  }

  createAlertDialog(BuildContext context, Product currentProduct) {
    TextEditingController qtyController = TextEditingController();

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Text("Enter Quantity"),
            content: Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                  color: Colors.yellow[100],
                  borderRadius: BorderRadius.circular(8)),
              child: TextFormField(
                cursorColor: Variables.primaryColor,
                validator: (value) {
                  if (value.isEmpty)
                    return "You cannot have an empty Purchase Price!";
                },
                maxLines: 1,
                keyboardType: TextInputType.number,
                style: Variables.inputTextStyle,
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: 'Quantity'),
                controller: qtyController,
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
                  Navigator.of(context).pop(DialogAction.Abort);

                  Category category =
                      await _adminMethods.getTaxFromHsn(currentProduct.hsnCode);
                  //print('category.hsnCode:${category.tax}');

                  if (productList.contains(currentProduct.name)) {
                    int productIndex = productList.indexOf(currentProduct.name);
                    qtyList[productIndex] =
                        qtyList[productIndex] + int.parse(qtyController.text);
                  }
                  if (!productList.contains(currentProduct.name)) {
                    qtyList.add(int.parse(qtyController.text));
                    productListId.add(currentProduct.id);
                    productList.add(currentProduct.name);
                    taxList.add(category.tax);
                    sellingRateList.add(currentProduct.sellingRate);
                  }
                  print(sellingRateList);

                  double sum = 0;
                  tax = 0;
                  totalPrice = 0;
                  if (_isTaxCheckBox) {
                    for (var i = 0; i < sellingRateList.length; i++) {
                      double qty = qtyList[i].toDouble();
                      sum += sellingRateList[i] * qty;
                      print(sellingRateList[i].toInt());
                      tax += taxList[i];
                    }
                    // print(sum);
                    totalPrice = (sum + (sum * (tax / 100)));
                    setState(() {
                      _totalPriceController =
                          TextEditingController(text: totalPrice.toString());
                      _priceController =
                          TextEditingController(text: sum.toString());
                      _taxController =
                          TextEditingController(text: tax.toString());
                    });
                  } else if (!_isTaxCheckBox) {
                    for (var i = 0; i < sellingRateList.length; i++) {
                      sum += sellingRateList[i].toInt() * qtyList[i];
                      tax += taxList[i];
                    }
                    totalPrice = sum.toDouble();
                    setState(() {
                      _totalPriceController =
                          TextEditingController(text: totalPrice.toString());
                      _priceController =
                          TextEditingController(text: sum.toString());
                      _taxController =
                          TextEditingController(text: tax.toString());
                    });
                  }

                  //print(productList);
                  //print(qtyList);
                  //print(taxList);
                  //print(sellingRateList);
                  //print(productListId);
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

  Widget buildProductDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        productList.isEmpty ? Container() : buildProductList(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                    "Product",
                    style: Variables.inputLabelTextStyle,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.yellow[100]),
                  child: StreamBuilder<QuerySnapshot>(
                      stream: _adminMethods.fetchAllProduct(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          //print(snapshot.error);
                        } else {
                          if (!snapshot.hasData) {
                            return CustomCircularLoading();
                          }

                          return new DropdownButton<DocumentSnapshot>(
                            dropdownColor: Colors.yellow[100],
                            underline: SizedBox(),
                            onChanged: (DocumentSnapshot newValue) async {
                              setState(() async {
                                currentProduct = Product.fromMap(newValue.data());
                                createAlertDialog(context, currentProduct);
                              });
                            },
                            hint: currentProduct == null
                                ? Text('Select Product')
                                : Text(currentProduct.name),
                            items: snapshot.data.docs
                                .map((DocumentSnapshot document) {
                              return new DropdownMenuItem<DocumentSnapshot>(
                                  value: document,
                                  child: new Text(
                                    document.data()['name'],
                                  ));
                            }).toList(),
                          );
                        }
                        return CustomCircularLoading();
                      }),
                ),
              ],
            ),
            buildQrCodeButton()
          ],
        ),
      ],
    );
  }

  scanQr() async {
    String barcodeScanRes;

    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      //print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;

    final bool isExists = await _adminMethods.isQrExists(barcodeScanRes);
    if (isExists) {
      Product product =
          await _adminMethods.getProductDetailsByQrCode(barcodeScanRes);

      createAlertDialog(context, product);
    } else {
      Navigator.push(
          context,
          BouncyPageRoute(
              widget: AddProduct(
            qrCode: barcodeScanRes,
          )));
    }
  }

  Widget buildQrCodeButton() {
    return FlatButton(
      color: Variables.lightGreyColor,
      onPressed: () => scanQr(),
      child: Text('Qr Code',
          style: TextStyle(
            color: Variables.primaryColor,
            letterSpacing: 0.5,
          )),
    );
  }

  Row buildBillNoField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          "Bill No: ",
          style: TextStyle(color: Variables.blackColor),
        ),
        Expanded(
          child: Container(
            height: 48,
            padding: EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
                color: Colors.yellow[100],
                borderRadius: BorderRadius.circular(8)),
            child: TextField(
              enabled: false,
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

}
