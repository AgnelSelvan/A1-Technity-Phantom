import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:stock_q/models/product.dart';
import 'package:stock_q/resources/admin_methods.dart';
import 'package:stock_q/screens/admin/product_details.dart';
import 'package:stock_q/screens/custom_loading.dart';
import 'package:stock_q/utils/universal_variables.dart';
import 'package:stock_q/widgets/bouncy_page_route.dart';
import 'package:stock_q/widgets/custom_appbar.dart';
import 'package:stock_q/widgets/custom_divider.dart';
import 'package:stock_q/widgets/header.dart';
import 'package:stock_q/widgets/widgets.dart';

AdminMethods _adminMethods = AdminMethods();

class AddProduct extends StatefulWidget {
  final String qrCode;

  AddProduct({this.qrCode});

  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  TextEditingController _codeFieldController = TextEditingController();
  TextEditingController _nameFieldController = TextEditingController();
  TextEditingController _purchasePriceController = TextEditingController();
  TextEditingController _sellingPriceFieldController = TextEditingController();
  TextEditingController _unitQtyFieldController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool viewVisible = true;
  bool isLoading = false;
  String currenthsnCode;
  String currentUnit;

  @override
  void initState() {
    super.initState();
    if (widget.qrCode != null) {
      _codeFieldController = TextEditingController(text: widget.qrCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: CustomAppBar(
            title: Text("Annai Store", style: Variables.appBarTextStyle),
            actions: [
              IconButton(
                  icon: Icon(
                    FontAwesome.barcode,
                    color: Variables.primaryColor,
                  ),
                  onPressed: () => scanQR())
            ],
            leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Variables.primaryColor,
                  size: 16,
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
            centerTitle: true,
            bgColor: Colors.white),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 5),
                color: Colors.white,
                child: Stack(
                  children: [
                    isLoading ? CustomCircularLoading() : Container(),
                    buildSymbolCard(),
                  ],
                ),
              ),
            ],
          ),
        ));
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
    final bool isQrExists = await _adminMethods.isQrExists(barcodeScanRes);
    if (isQrExists) {
      Navigator.push(
          context,
          BouncyPageRoute(
              widget: ProductDetails(
                qrCode: barcodeScanRes,
              )));
    } else if (!isQrExists) {
      setState(() {
        _codeFieldController = TextEditingController(text: barcodeScanRes);
      });
    }
  }

  handleDeleteUnit(String unitId) {
    _adminMethods.deleteUnit(unitId);
    final snackBar =
    customSnackBar('Delete Successfull!', Variables.blackColor);
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void showWidget() {
    //print(viewVisible);
    setState(() {
      viewVisible = !viewVisible;
    });
    //print(viewVisible);
  }

  addProductToDb() {
    setState(() {
      isLoading = true;
    });
    _adminMethods.isProductExists(_codeFieldController.text).then((value) {
      //print(value);
      if (!value) {
        try {
          var purchasePrice = double.parse(_purchasePriceController.text);
          var sellingPrice = double.parse(_sellingPriceFieldController.text);
          int unitQty = _unitQtyFieldController.text == ''
              ? 0
              : int.parse(_unitQtyFieldController.text);
          //print(unitQty);
          _adminMethods.addProductToDb(
              _codeFieldController.text,
              _nameFieldController.text,
              purchasePrice,
              sellingPrice,
              currenthsnCode,
              currentUnit,
              unitQty);

          SnackBar snackbar =
          customSnackBar("Added Successfully", Variables.blackColor);
          _scaffoldKey.currentState.showSnackBar(snackbar);
          setState(() {
            _nameFieldController.clear();
            _codeFieldController.clear();
            _purchasePriceController.clear();
            _sellingPriceFieldController.clear();
            currenthsnCode = null;
            currentUnit = null;
          });
        } catch (e) {
          //print(e);
        }
      } else {
        SnackBar snackbar = customSnackBar(
            "${_codeFieldController.text} Already Exists", Colors.red);
        _scaffoldKey.currentState.showSnackBar(snackbar);
      }
    });
    setState(() {
      isLoading = false;
    });
  }

  Card buildSymbolCard() {
    return Card(
      elevation: 3,
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              BuildHeader(
                text: "Product",
              ),
              SizedBox(
                height: 15,
              ),
              StreamBuilder(
                  stream: _adminMethods.fetchAllProduct(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.documents.length != 0) {
                        return Column(
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Container(
                                        width: 95,
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              'Symbol',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Variables.blackColor),
                                            ),
                                            CustomDivider(
                                                leftSpacing: 2, rightSpacing: 2)
                                          ],
                                        )),
                                    Container(
                                        width: 95,
                                        child: Column(
                                          children: <Widget>[
                                            Text(
                                              "Formal Name",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Variables.blackColor),
                                            ),
                                            CustomDivider(
                                                leftSpacing: 2, rightSpacing: 2)
                                          ],
                                        )),
                                    Container(
                                      width: 5,
                                    )
                                  ],
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 100,
                                  child: StreamBuilder(
                                    stream: _adminMethods.fetchAllProduct(),
                                    builder: (context, snapshot) {
                                      var docs = snapshot.data.documents;
                                      if (snapshot.hasData) {
                                        return ListView.builder(
                                          physics: BouncingScrollPhysics(),
                                          itemCount: docs.length,
                                          itemBuilder: (context, index) {
                                            Product product = Product.fromMap(
                                                docs[index].data);
                                            return Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                              children: <Widget>[
                                                Container(
                                                    width: 95,
                                                    height: 22,
                                                    child: Text(product.unit,
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: Variables
                                                                .blackColor))),
                                                Container(
                                                    width: 95,
                                                    height: 22,
                                                    child: Text(product.name,
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: Variables
                                                                .blackColor))),
                                                GestureDetector(
                                                  onTap: () {
                                                    handleDeleteUnit(
                                                        product.id);
                                                  },
                                                  child: Container(
                                                      width: 5,
                                                      height: 20,
                                                      child: Icon(
                                                        FontAwesome
                                                            .times_circle,
                                                        size: 20,
                                                        color: Colors.red,
                                                      )),
                                                )
                                              ],
                                            );
                                          },
                                        );
                                      }
                                      return CustomCircularLoading();
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: <Widget>[
                            Container(
                              child: Text(
                                "Click Add Product for adding more products!",
                                style: TextStyle(
                                    color: Variables.blackColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: 0.5),
                              ),
                            ),
                            SizedBox(height: 20)
                          ],
                        );
                      }
                    }
                    return CustomCircularLoading();
                  }),
              viewVisible ? buildVisibility() : Container(),
              Row(
                mainAxisAlignment: viewVisible
                    ? MainAxisAlignment.spaceAround
                    : MainAxisAlignment.center,
                children: <Widget>[
                  buildCustomModelButton(),
                  if (viewVisible) buildSubmissionButton() else
                    Container(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector buildSubmissionButton() {
    return GestureDetector(
      onTap: addProductToDb,
      child: Icon(
        Icons.check_circle,
        size: 30,
        color: Colors.green[200],
      ),
    );
  }

  GestureDetector buildCustomModelButton() {
    return GestureDetector(
      onTap: () {
        showWidget();
      },
      child: Container(
        width: 170,
        decoration: BoxDecoration(
            color: Colors.grey[100], borderRadius: BorderRadius.circular(100)),
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
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
                  letterSpacing: 1, fontSize: 16, color: Variables.blackColor),
            )
          ],
        ),
      ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                buildCodeField(),
                SizedBox(
                  height: 20,
                ),
                buildNameField(),
                SizedBox(
                  height: 20,
                ),
                buildCategoryDropDown(),
                SizedBox(
                  height: 20,
                ),
                buildUnitDropDown(),
                SizedBox(
                  height: 20,
                ),
                currentUnit == 'roll' ||
                    currentUnit == 'box' ||
                    currentUnit == 'Bundle' ||
                    currentUnit == 'Litre' ||
                    currentUnit == 'pieces'
                    ? buildUnitQtyDropDown()
                    : Container(),
                currentUnit == 'roll' ||
                    currentUnit == 'box' ||
                    currentUnit == 'Bundle' ||
                    currentUnit == 'Litre' ||
                    currentUnit == 'pieces'
                    ? SizedBox(
                  height: 20,
                )
                    : Container(),
                buildPurchasePriceField(),
                SizedBox(
                  height: 20,
                ),
                buildSellingPriceField(),
                SizedBox(
                  height: 20,
                ),
              ],
            )));
  }

  Widget buildUnitQtyDropDown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          currentUnit == 'roll'
              ? 'meter'
              : currentUnit == 'box'
              ? 'Threads'
              : currentUnit == 'Bundle'
              ? 'Bundle Qty'
              : currentUnit == 'Litre' ? 'Litre' : 'Qty',
          style: Variables.inputLabelTextStyle,
        ),
        Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              color: Colors.yellow[100],
              borderRadius: BorderRadius.circular(8)),
          child: TextFormField(
            cursorColor: Variables.primaryColor,
            validator: (value) {
              if (value.isEmpty) return "You cannot have an empty unit Qty!";
            },
            maxLines: 1,
            keyboardType: TextInputType.number,
            style: Variables.inputTextStyle,
            decoration:
            InputDecoration(border: InputBorder.none, hintText: '26'),
            controller: _unitQtyFieldController,
          ),
        ),
      ],
    );
  }

  Column buildUnitDropDown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(
            "Unit",
            style: Variables.inputLabelTextStyle,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.yellow[100]),
          child: buildUnitDropdownButton(),
        ),
      ],
    );
  }

  StreamBuilder buildUnitDropdownButton() {
    return StreamBuilder<QuerySnapshot>(
        stream: _adminMethods.fetchAllUnit(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            //print(snapshot.error);
          } else {
            if (!snapshot.hasData) {
              return CustomCircularLoading();
            }

            return new DropdownButton<DocumentSnapshot>(
              dropdownColor: Colors.yellow[100],
              underline: SizedBox(),
              onChanged: (DocumentSnapshot newValue) {
                setState(() {
                  currentUnit = newValue['unit'];
                });
              },
              hint:
              currentUnit == null ? Text('Select Unit') : Text(currentUnit),
              items: snapshot.data.docs.map((DocumentSnapshot document) {
                return new DropdownMenuItem<DocumentSnapshot>(
                    value: document,
                    child: new Text(
                      document['unit'],
                    ));
              }).toList(),
            );
          }
          return CustomCircularLoading();
        });
  }

  Column buildCategoryDropDown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(
            "Category",
            style: Variables.inputLabelTextStyle,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.yellow[100]),
          child: buildCategoryDropdownButton(),
        ),
      ],
    );
  }

  StreamBuilder buildCategoryDropdownButton() {
    return StreamBuilder<QuerySnapshot>(
        stream: _adminMethods.fetchAllCategory(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            //print(snapshot.error);
          } else {
            if (!snapshot.hasData) {
              return CustomCircularLoading();
            }

            return new DropdownButton<DocumentSnapshot>(
              dropdownColor: Colors.yellow[100],
              underline: SizedBox(),
              onChanged: (DocumentSnapshot newValue) {
                setState(() {
                  currenthsnCode = newValue['hsn_code'];
                });
              },
              hint: currenthsnCode == null
                  ? Text('Select Category')
                  : Text(currenthsnCode),
              items: snapshot.data.docs.map((DocumentSnapshot document) {
                return new DropdownMenuItem<DocumentSnapshot>(
                    value: document,
                    child: Row(
                      children: <Widget>[
                        new Text(
                          document['hsn_code'],
                        ),
                        new Text(
                          "   (${document['product_name']})",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ));
              }).toList(),
            );
          }
          return CustomCircularLoading();
        });
  }

  Widget buildSellingPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Selling Price",
          style: Variables.inputLabelTextStyle,
        ),
        Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              color: Colors.yellow[100],
              borderRadius: BorderRadius.circular(8)),
          child: TextFormField(
            cursorColor: Variables.primaryColor,
            validator: (value) {
              if (value.isEmpty)
                return "You cannot have an empty Selling Price!";
            },
            maxLines: 1,
            style: Variables.inputTextStyle,
            keyboardType: TextInputType.number,
            decoration:
            InputDecoration(border: InputBorder.none, hintText: '240'),
            controller: _sellingPriceFieldController,
          ),
        ),
      ],
    );
  }

  Widget buildPurchasePriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Purchase Price",
          style: Variables.inputLabelTextStyle,
        ),
        Container(
          height: 48,
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
            decoration:
            InputDecoration(border: InputBorder.none, hintText: '230'),
            controller: _purchasePriceController,
          ),
        ),
      ],
    );
  }

  Widget buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Name",
          style: Variables.inputLabelTextStyle,
        ),
        Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              color: Colors.yellow[100],
              borderRadius: BorderRadius.circular(8)),
          child: TextFormField(
            cursorColor: Variables.primaryColor,
            validator: (value) {
              if (value.isEmpty) return "You cannot have an empty name!";
            },
            maxLines: 1,
            style: Variables.inputTextStyle,
            decoration: InputDecoration(
                border: InputBorder.none, hintText: '.25 Inch Elastic'),
            controller: _nameFieldController,
          ),
        ),
      ],
    );
  }

  Widget buildCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Code",
          style: Variables.inputLabelTextStyle,
        ),
        Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              color: Colors.yellow[100],
              borderRadius: BorderRadius.circular(8)),
          child: TextFormField(
            enabled: widget.qrCode == null ? true : false,
            cursorColor: Variables.primaryColor,
            validator: (value) {
              if (value.isEmpty) return "You cannot have an Code!";
            },
            maxLines: 1,
            style: Variables.inputTextStyle,
            decoration: InputDecoration(
                border: InputBorder.none, hintText: '0.25 Eagle'),
            controller: _codeFieldController,
          ),
        ),
      ],
    );
  }
}
