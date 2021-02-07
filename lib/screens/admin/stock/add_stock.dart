import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:stock_q/flutter_barcode_scanner.dart';
import 'package:stock_q/models/product.dart';
import 'package:stock_q/models/stock.dart';
import 'package:stock_q/models/unit.dart';
import 'package:stock_q/resources/admin_methods.dart';
import 'package:stock_q/screens/custom_loading.dart';
import 'package:stock_q/utils/universal_variables.dart';
import 'package:stock_q/widgets/dialogs.dart';

AdminMethods _adminMethods = AdminMethods();

class AddStock extends StatefulWidget {
  AddStock({Key key}) : super(key: key);

  @override
  _AddStockState createState() => _AddStockState();
}

class _AddStockState extends State<AddStock> {
  TextEditingController _qtyController = TextEditingController();
  Unit selectedUnit;
  Product selectedProduct;
  bool isBulkStock = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.all(10),
      children: <Widget>[
        SizedBox(height: 20),
        // buildQrCodeField(),
        SizedBox(height: 20),
        buildProductDropdown(),
        SizedBox(height: 20),
        buildUnitDropdown(),
        SizedBox(height: 20),
        buildQtyField(),
        SizedBox(height: 20),
        buildSubmitButton()
      ],
    );
  }

  Widget buildQrCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [buildForSingleQr(), SizedBox(height: 20), buildForBulkQr()],
    );
  }

  Future<void> handleAddStock() async {
    String barcodeScanRes;

    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      //print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;
    final bool isQrExists = await _adminMethods.isQrExists(barcodeScanRes);
    if (isQrExists) {
      Product product =
          await _adminMethods.getProductDetailsByQrCode(barcodeScanRes);
      if (!isBulkStock) {
        bool isStockExists = await _adminMethods.isStockExists(product.id);
        if (isStockExists) {
          Stock stock = await _adminMethods.getStockDetails(product.id);
          _adminMethods.updateStockById(stock.stockId, 1 + stock.qty);
        } else {
          _adminMethods.addStockToDb(product.id, product.code, 1);
        }
      } else {
        createAlertDialog(context, product);
      }
    } else {
      //print('Not Exists');
    }
  }

  buildForSingleQr() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isBulkStock = false;
        });
        handleAddStock();
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 2,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              "Single Product",
              style: TextStyle(
                color: Variables.blackColor,
                fontSize: 18,
              ),
            ),
            Icon(
              FontAwesome.qrcode,
              color: Colors.grey,
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.yellow[100],
            )
          ],
        ),
      ),
    );
  }

  buildForBulkQr() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isBulkStock = true;
        });
        handleAddStock();
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 2,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              "Bulk Product",
              style: TextStyle(
                color: Variables.blackColor,
                fontSize: 18,
              ),
            ),
            Icon(
              FontAwesome.qrcode,
              color: Colors.grey,
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.yellow[100],
            )
          ],
        ),
      ),
    );
  }

  createAlertDialog(BuildContext context, Product product) {
    TextEditingController bulkQtyController = TextEditingController();

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Text("Enter Quantity"),
            content: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("Code:"),
                      Text(
                        product.code,
                        style: Variables.inputTextStyle,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text("Name:"),
                      Text(
                        product.name,
                        style: Variables.inputTextStyle,
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text("Unit:"),
                      Text(
                        product.unit,
                        style: Variables.inputTextStyle,
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                        color: Colors.yellow[100],
                        borderRadius: BorderRadius.circular(8)),
                    child: TextFormField(
                      autofocus: true,
                      cursorColor: Variables.primaryColor,
                      validator: (value) {
                        if (value.isEmpty)
                          return "You cannot have an empty Purchase Price!";
                        if (value.length != 6) return "Enter valid pincode!";
                      },
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      style: Variables.inputTextStyle,
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: 'Quantity'),
                      controller: bulkQtyController,
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
                  bool isStockExists =
                      await _adminMethods.isStockExists(product.id);
                  if (isStockExists) {
                    Stock stock =
                        await _adminMethods.getStockDetails(product.id);
                    _adminMethods.updateStockById(stock.stockId,
                        int.parse(bulkQtyController.text) + stock.qty);
                  } else {
                    _adminMethods.addStockToDb(product.id, product.code,
                        int.parse(bulkQtyController.text));
                  }
                  Navigator.of(context).pop(DialogAction.Abort);
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

  buildSubmitButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        IconButton(
            icon: Icon(
              Icons.check_circle,
              color: Colors.green[200],
            ),
            onPressed: handleSubmitStock)
      ],
    );
  }

  handleSubmitStock() async {
    bool isExists = await _adminMethods.isStockExists(selectedProduct.id);
    if (!isExists) {
      _adminMethods.addStockToDb(selectedProduct.id, selectedProduct.code,
          int.parse(_qtyController.text));
    } else {
      Stock stock;
      stock = await _adminMethods.getStockDetails(selectedProduct.id);
      int updatedQty = stock.qty + int.parse(_qtyController.text);
      _adminMethods.updateStockById(stock.stockId, updatedQty);
    }
    setState(() {
      selectedProduct = null;
      selectedUnit = null;
      _qtyController.clear();
    });
    Dialogs.okDialog(context, "Successfull", "Added to stock successfully",
        Colors.green[200]);
  }

  Widget buildQtyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Quantity",
          style: Variables.inputLabelTextStyle,
        ),
        Container(
          height: 48,
          width: MediaQuery.of(context).size.width / 2,
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              color: Colors.yellow[100],
              borderRadius: BorderRadius.circular(8)),
          child: TextFormField(
            cursorColor: Variables.primaryColor,
            validator: (value) {
              if (value.isEmpty) return "You cannot have an empty Quantity!";
            },
            maxLines: 1,
            style: Variables.inputTextStyle,
            keyboardType: TextInputType.number,
            decoration:
                InputDecoration(border: InputBorder.none, hintText: '240'),
            controller: _qtyController,
          ),
        ),
      ],
    );
  }

  Column buildUnitDropdown() {
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
                  selectedUnit = Unit.fromMap(newValue.data());
                });
              },
              hint: selectedUnit == null
                  ? Text('Select Unit')
                  : Text(selectedUnit.unitId),
              items: snapshot.data.docs.map((DocumentSnapshot document) {
                return new DropdownMenuItem<DocumentSnapshot>(
                    value: document,
                    child: new Text(
                      document.data()['unit'],
                    ));
              }).toList(),
            );
          }
          return CustomCircularLoading();
        });
  }

  Widget buildProductDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
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
              width: MediaQuery.of(context).size.width / 2,
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
                          setState(() {
                            selectedProduct = Product.fromMap(newValue.data());
                          });
                        },
                        hint: selectedProduct == null
                            ? Text('Select Product')
                            : Text(selectedProduct.name),
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
      ],
    );
  }
}
