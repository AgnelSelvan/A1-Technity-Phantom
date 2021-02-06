import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stock_q/models/category.dart';
import 'package:stock_q/models/product.dart';
import 'package:stock_q/models/stock.dart';
import 'package:stock_q/resources/admin_methods.dart';
import 'package:stock_q/screens/custom_loading.dart';
import 'package:stock_q/widgets/custom_divider.dart';

AdminMethods _adminMethods = AdminMethods();

class StockItems extends StatefulWidget {
  StockItems({Key key}) : super(key: key);

  @override
  _StockItemsState createState() => _StockItemsState();
}

class _StockItemsState extends State<StockItems> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: buildCategoryFutureBuilder(),
    );
  }

  StreamBuilder<QuerySnapshot> buildCategoryFutureBuilder() {
    return StreamBuilder(
        stream: _adminMethods.fetchAllCategory(),
        builder: (context, snapshot) {
          var docs = snapshot.data.docs;
          if (snapshot.hasData) {
            if (snapshot.data == null) return Text("No Items in stock");

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                Category category = Category.fromMap(docs[index].data());
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(child: Text(category.productName)),
                    Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      height: MediaQuery.of(context).size.height / 6,
                      child: StreamBuilder(
                        stream:
                            _adminMethods.getProductFromHsn(category.hsnCode),
                        builder: (context, snapshot) {
                          var docs = snapshot.data.documents;
                          if (snapshot.hasData) {
                            if (snapshot.data == null)
                              return CustomCircularLoading();

                            return ListView.builder(
                              itemCount: docs.length,
                              itemBuilder: (context, index) {
                                Product product =
                                    Product.fromMap(docs[index].data);
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Container(
                                        child: Text(product.code == null
                                            ? "No items in Stock"
                                            : product.code)),
                                    StreamBuilder(
                                        stream: _adminMethods
                                            .getStockDetailsByProductId(
                                                product.id),
                                        builder: (context, snapshot) {
                                          var docs = snapshot.data.documents;
                                          if (snapshot.data == null)
                                            return Text("HIii");
                                          return Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                4,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                6,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: List.generate(
                                                  docs.length, (index) {
                                                Stock stock = Stock.fromMap(
                                                    docs[index].data);
                                                return Column(
                                                  children: <Widget>[
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: <Widget>[
                                                        // Text(stock.unitId),
                                                        Text(stock.qty == 0
                                                            ? "(No Items in stock)"
                                                            : stock.qty
                                                                .toString())
                                                      ],
                                                    ),
                                                    CustomDivider(
                                                        leftSpacing: 2,
                                                        rightSpacing: 2)
                                                  ],
                                                );
                                              }).toList(),
                                            ),
                                          );
                                        })
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
                );
              },
            );
          }
          return CustomCircularLoading();
        });
  }

  StreamBuilder<QuerySnapshot> buildProductStreamBuilder(String hsnCode) {
    return StreamBuilder(
      stream: _adminMethods.getProductFromHsn(hsnCode),
      builder: (context, snapshot) {
        var docs = snapshot.data.docs;
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              Product product = Product.fromMap(docs[index].data());
              return Row(
                children: <Widget>[
                  Text(product.code),
                  StreamBuilder(
                      stream:
                          _adminMethods.getStockDetailsByProductId(product.id),
                      builder: (context, snapshot) {
                        var docs = snapshot.data.documents;
                        return Container(
                          width: MediaQuery.of(context).size.width / 4,
                          height: MediaQuery.of(context).size.width / 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: List.generate(docs.length, (index) {
                              Stock stock = Stock.fromMap(docs[index].data);
                              return Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      // Text(stock.unitId),
                                      Text(stock.qty.toString())
                                    ],
                                  ),
                                  CustomDivider(leftSpacing: 2, rightSpacing: 2)
                                ],
                              );
                            }).toList(),
                          ),
                        );
                      })
                ],
              );
            },
          );
        }
        return CustomCircularLoading();
      },
    );
  }
}
