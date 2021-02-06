import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stock_q/models/product.dart';
import 'package:stock_q/views/pages/add_product_page.dart';
import 'package:stock_q/views/pages/product_detail_page.dart';
import 'package:stock_q/views/services/auth.dart';
import 'package:stock_q/views/services/datastore.dart';
import 'package:stock_q/views/styles/custom.dart';
import 'package:stock_q/views/widgets/in_section_spacing.dart';

class ViewAllProductPage extends StatefulWidget {
  final Datastore datastore;
  final Auth auth;
  ViewAllProductPage({this.datastore, this.auth});
  @override
  _ViewAllProductPageState createState() => _ViewAllProductPageState();
}

class _ViewAllProductPageState extends State<ViewAllProductPage> {
  String uid;


  getUserId() async {
    User user = await widget.auth.getCurrentUser();
    uid = user.uid;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getUserId();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'All Products',
          style: Custom().appbarTitleTextStyle,
        ),
        leading: IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (BuildContext ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
            return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (BuildContext cx, int i) {
                  Map<String, dynamic> productMap =
                      snapshot.data.docs[i].data();
                  List<Map<String, dynamic>> previewImages =
                      productMap['previewImages'].cast<Map<String, dynamic>>();
                  Product _product = Product(
                      productId: productMap["productId"],
                      title: productMap["title"],
                      description: productMap["description"],
                      price: productMap["price"],
                      discount: productMap["discount"],
                      stock: productMap["stock"],
                      thumbnailImage: productMap["thumbImage"],
                      previewImages: previewImages);
                  return ProductCard(_product, widget.datastore, uid);
                });
          }),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext ctx) {
              return AddProductPage(
                datastore: widget.datastore,
              );
            }));
          }),
    );
  }
}

class ProductCard extends StatefulWidget {
  final Product product;
  final Datastore datastore;
  final String uid;
  ProductCard(this.product, this.datastore, this.uid);
  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext ctx) {
          return ProductPageDetailPage(widget.product);
        }));
      },
      child: Container(
          color: Colors.grey[100],
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: <Widget>[
              widget.product.thumbnailImage['image'] != null
                  ? Stack(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          height: 150,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                      widget.product.thumbnailImage['image']))),
                        ),
                        widget.product.discount != null &&
                                widget.product.discount > 0
                            ? Align(
                                alignment: Alignment.topLeft,
                                child: Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                        color: Colors.pink[100],
                                        borderRadius:
                                            BorderRadius.circular(64)),
                                    child: Center(
                                      child: Text(
                                        widget.product.discount.toString() +
                                            '% OFF',
                                        style: Custom().captionTextStyle,
                                      ),
                                    )),
                              )
                            : Container(),
                      ],
                    )
                  : Container(),
              SizedBox(width: 16),
              Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        width: MediaQuery.of(context).size.width -
                            MediaQuery.of(context).size.width * 0.4 -
                            48,
                        child: Text(widget.product.title,
                            style: Custom().cardTitleTextStyle)),
                    InSectionSpacing(),
                    Text('₹ ' + widget.product.price.toString(),
                        style: Custom().bodyTextStyle),
                    Row(
                      children: <Widget>[
                        IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (BuildContext ctx) {
                                return AddProductPage(
                                  datastore: widget.datastore,
                                  product: widget.product,
                                );
                              }));
                            }),
                        IconButton(
                            icon: Icon(Icons.delete, color: Colors.grey),
                            onPressed: () async {
                              log('delete');
                              log(widget.product.productId);
                              String status = await widget.datastore
                                  .deleteProduct(widget.product.productId);

                              log(status);
                            }),
                        IconButton(
                            icon: Icon(Icons.shopping_basket,
                                color: Colors.red[200]),
                            onPressed: () async {
                              String status = await widget.datastore.addProductToCart(
                                  widget.uid,
                                  widget.product.stock - 1,
                                  widget.product.toMap());

                              log(status);
                            }),
                      ],
                    )
                  ])
            ],
          )),
    );
  }
}
