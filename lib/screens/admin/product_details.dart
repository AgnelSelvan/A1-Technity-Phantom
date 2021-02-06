import 'package:stock_q/models/product.dart';
import 'package:stock_q/models/stock.dart';
import 'package:stock_q/resources/admin_methods.dart';
import 'package:stock_q/screens/custom_loading.dart';
import 'package:stock_q/utils/universal_variables.dart';
import 'package:stock_q/widgets/custom_appbar.dart';
import 'package:stock_q/widgets/header.dart';
import 'package:flutter/material.dart';

AdminMethods _adminMethods = AdminMethods();

class ProductDetails extends StatefulWidget {
  final String qrCode;
  ProductDetails({this.qrCode});

  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: Text("Annai Store", style: Variables.appBarTextStyle),
          actions: null,
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
      backgroundColor: Variables.lightGreyColor,
      body: Container(
        child: FutureBuilder(
            future: _adminMethods.getProductDetailsByQrCode(widget.qrCode),
            builder: (context, AsyncSnapshot<Product> snapshot) {
              Product product = snapshot.data;
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListView(
                    children: [
                      Center(child: BuildHeader(text: 'Product Details')),
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
                                  'Code : ',
                                  style: Variables.inputTextStyle,
                                ),
                                Text(product.code)
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Text(
                                  'HSN Code : ',
                                  style: Variables.inputTextStyle,
                                ),
                                Text(product.hsnCode)
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Text(
                                  'Name : ',
                                  style: Variables.inputTextStyle,
                                ),
                                Text(product.name)
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Text(
                                  'Unit : ',
                                  style: Variables.inputTextStyle,
                                ),
                                Text(product.unit)
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Text(
                                  'Unit Qty : ',
                                  style: Variables.inputTextStyle,
                                ),
                                Text(product.unitQty.toString())
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Text(
                                  'Purchase rate : ',
                                  style: Variables.inputTextStyle,
                                ),
                                Text(product.purchaseRate.toString())
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Text(
                                  'Selling Rate : ',
                                  style: Variables.inputTextStyle,
                                ),
                                Text(product.sellingRate.toString())
                              ],
                            ),
                            SizedBox(height: 20),
                            StreamBuilder(
                                stream: _adminMethods
                                    .getStockDetailsByProductId(product.id),
                                builder: (context, snaphot) {
                                  var docs = snaphot.data.documents;
                                  Stock stock = Stock.fromMap(docs[0].data);
                                  return Row(
                                    children: [
                                      Text(
                                        'Stock : ',
                                        style: Variables.inputTextStyle,
                                      ),
                                      stock.qty == 0
                                          ? Text(
                                              'No Items in stock',
                                              style: TextStyle(
                                                  color: Colors.red[200]),
                                            )
                                          : Text(stock.qty.toString())
                                    ],
                                  );
                                }),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }
              return CustomCircularLoading();
            }),
      ),
    );
  }
}
