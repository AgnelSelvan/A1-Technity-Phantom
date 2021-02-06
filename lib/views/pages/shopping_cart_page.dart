import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stock_q/dbhelpers/wishlist_dbhelper.dart';
import 'package:stock_q/models/product.dart';
import 'package:stock_q/models/user.dart' as UserModel;
import 'package:stock_q/models/wishlist.dart';
import 'package:stock_q/services/auth.dart';
import 'package:stock_q/services/datastore.dart';
import 'package:stock_q/styles/custom.dart';
import 'package:stock_q/widgets/SectionTitle.dart';
import 'package:stock_q/widgets/appbar.dart';
import 'package:stock_q/widgets/in_section_spacing.dart';

class ShoppingCartPage extends StatefulWidget {
  final Datastore datastore;
  final Auth auth;
  ShoppingCartPage({this.datastore, this.auth});
  @override
  _ShoppingCartPageState createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {

  Custom custom = Custom();
  List<String> cartProducts;
  String uid;
  getCart() async{
    User user = await widget.auth.getCurrentUser();

    if (user != null)
    uid = user.uid;
      
    setState(() {
      
    });
  }
  @override
  void initState() {
    super.initState();
    getCart();
  }
  @override
  Widget build(BuildContext context) {
    return 
        uid != null ?
        StreamBuilder<DocumentSnapshot>(
          stream:  FirebaseFirestore.instance.collection("users").doc(uid).snapshots(),
          builder: (BuildContext ctx, AsyncSnapshot<DocumentSnapshot> snapshot) {

              if (snapshot.data !=null){
                Map<String, dynamic> userMap = snapshot.data.data();
                List<Map<String,dynamic>> cartProducts = userMap['cartProducts'].cast<Map<String, dynamic>>();

                return Column(children: cartProducts.map((p){
                  return WishlistProduct(p, (){});
                }).toList()
                );
    
    
    }
    else{
      return Container();
    }
    
    }
    
    ):CircularProgressIndicator();
            
  }
  
}

class WishlistProduct extends StatefulWidget {
  final Map<String, dynamic> product;
  final GestureTapCallback onPressed;
  WishlistProduct(this.product, this.onPressed);
  @override
  _WishlistProductState createState() =>
      _WishlistProductState(this.product, this.onPressed);
}

class _WishlistProductState extends State<WishlistProduct> {
  Map<String,dynamic> _product;
  GestureTapCallback _onPressed;
  _WishlistProductState(this._product, this._onPressed);
  Custom custom = Custom();
  @override
  Widget build(BuildContext context) {

    
    return Container(
        color: Colors.grey[100],
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.4,
              height: 150,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(_product['thumbnailImage']['image']))),
            ),
            SizedBox(width: 8),
            Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      width: MediaQuery.of(context).size.width -
                          MediaQuery.of(context).size.width * 0.4 -
                          40,
                      child: Text(_product['title'], style: custom.bodyTextStyle)),
                  InSectionSpacing(),
                  Text('₹ ' + _product['price'].toString(),
                      style: custom.cardTitleTextStyle),
                  SizedBox(height: 8),
                  IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.black26,
                      ),
                      onPressed: _onPressed)
                ])
          ],
        ));
  }
}
