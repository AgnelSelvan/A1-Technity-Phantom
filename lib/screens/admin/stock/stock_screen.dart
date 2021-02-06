import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:stock_q/models/product.dart';
import 'package:stock_q/models/stock.dart';
import 'package:stock_q/resources/admin_methods.dart';
import 'package:stock_q/screens/admin/stock/add_stock.dart';
import 'package:stock_q/screens/admin/stock/stock_items.dart';
import 'package:stock_q/utils/universal_variables.dart';
import 'package:stock_q/widgets/custom_appbar.dart';
import 'package:stock_q/widgets/dialogs.dart';

AdminMethods _adminMethods = AdminMethods();

class StockScreen extends StatefulWidget {
  StockScreen({Key key}) : super(key: key);

  @override
  _StockScreenState createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen>
    with SingleTickerProviderStateMixin {
  TabController _stockTabController;
  bool isBulkStock = false;

  @override
  void initState() {
    super.initState();
    _stockTabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Variables.lightGreyColor,
      appBar: CustomAppBar(
          bgColor: Colors.white,
          title: Text("Stock Q", style: Variables.appBarTextStyle),
          actions: [
            IconButton(
                icon: Icon(
                  FontAwesome.barcode,
                  color: Variables.primaryColor,
                ),
                onPressed: () {
                  showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Stock'),
                            ],
                          ),
                          content: SingleChildScrollView(
                            child: Container(
                              width: 300.0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  InkWell(
                                      child: Container(
                                    margin: EdgeInsets.only(top: 8.0),
                                    child: FlatButton(
                                      color: Variables.lightPrimaryColor,
                                      child: new Text(
                                        "Single Product",
                                        style: TextStyle(
                                            color: Variables.blackColor),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isBulkStock = false;
                                        });
                                        handleAddStock();
                                      },
                                    ),
                                  )),
                                  InkWell(
                                      child: Container(
                                    margin: EdgeInsets.only(top: 8.0),
                                    child: FlatButton(
                                      color: Variables.lightPrimaryColor,
                                      child: new Text(
                                        "Bulk Product",
                                        style: TextStyle(
                                            color: Variables.blackColor),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isBulkStock = true;
                                        });
                                        handleAddStock();
                                      },
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          ),
                        );
                      });
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
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: TabBar(
              controller: _stockTabController,
              indicatorColor: Colors.transparent,
              labelColor: Variables.primaryColor,
              isScrollable: true,
              labelPadding: EdgeInsets.only(right: 45.0),
              unselectedLabelColor: Color(0xFFCDCDCD),
              tabs: <Widget>[
                Tab(
                  child: Text('Add Stock',
                      style: TextStyle(
                        fontSize: 18.0,
                      )),
                ),
                Tab(
                  child: Text('Items In Stock',
                      style: TextStyle(
                        fontSize: 18.0,
                      )),
                ),
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            child: TabBarView(
                controller: _stockTabController,
                children: [AddStock(), StockItems()]),
          )
        ],
      ),
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
}

class Card1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 150,
              child: Container(
                decoration: BoxDecoration(
                  color: Variables.primaryColor,
                  shape: BoxShape.rectangle,
                ),
                child: Image.asset('assets/images/vardham-thread.jpg'),
              ),
            ),
            ScrollOnExpand(
              scrollOnExpand: true,
              scrollOnCollapse: false,
              child: ExpandablePanel(
                theme: const ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                  tapBodyToCollapse: true,
                ),
                header: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Vardhaman Thread",
                      style: Theme.of(context).textTheme.title,
                    )),
                expanded: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ExpandableNotifier(
                        child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Card(
                                elevation: 0,
                                clipBehavior: Clip.antiAlias,
                                child: Column(children: <Widget>[
                                  ScrollOnExpand(
                                      scrollOnExpand: true,
                                      scrollOnCollapse: false,
                                      child: ExpandablePanel(
                                          theme: const ExpandableThemeData(
                                            headerAlignment:
                                                ExpandablePanelHeaderAlignment
                                                    .center,
                                            tapBodyToCollapse: true,
                                          ),
                                          header: Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Text(
                                                "Boxes(100)",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle,
                                              )),
                                          expanded: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: <Widget>[
                                                    Text(
                                                      "No.",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle,
                                                    ),
                                                    Text(
                                                      "Qty",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle,
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: <Widget>[
                                                    Text(
                                                      "1",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle,
                                                    ),
                                                    Text(
                                                      "20",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle,
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: <Widget>[
                                                    Text(
                                                      "2",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle,
                                                    ),
                                                    Text(
                                                      "30",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle,
                                                    ),
                                                  ],
                                                )
                                              ])))
                                ]))))
                  ],
                ),
                builder: (_, collapsed, expanded) {
                  return Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    child: Expandable(
                      collapsed: collapsed,
                      expanded: expanded,
                      theme: const ExpandableThemeData(crossFadePoint: 0),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

class Card2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 150,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.rectangle,
                ),
                child: Image.asset('assets/images/paper-canvas.jpg'),
              ),
            ),
            ScrollOnExpand(
              scrollOnExpand: true,
              scrollOnCollapse: false,
              child: ExpandablePanel(
                theme: const ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                  tapBodyToCollapse: true,
                ),
                header: Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: <Widget>[
                        Text(
                          "Canvas",
                          style: Theme.of(context).textTheme.title,
                        ),
                      ],
                    )),
                expanded: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text(
                          "Inch",
                          style: Theme.of(context).textTheme.subtitle,
                        ),
                        Text(
                          "Qty",
                          style: Theme.of(context).textTheme.subtitle,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text(
                          "1''",
                          style: Theme.of(context).textTheme.subtitle,
                        ),
                        Text(
                          "20",
                          style: Theme.of(context).textTheme.subtitle,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text(
                          "2''",
                          style: Theme.of(context).textTheme.subtitle,
                        ),
                        Text(
                          "30",
                          style: Theme.of(context).textTheme.subtitle,
                        ),
                      ],
                    )
                  ],
                ),
                builder: (_, collapsed, expanded) {
                  return Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    child: Expandable(
                      collapsed: collapsed,
                      expanded: expanded,
                      theme: const ExpandableThemeData(crossFadePoint: 0),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
