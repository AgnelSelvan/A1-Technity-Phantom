import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stock_q/models/product.dart';
import 'package:stock_q/models/wishlist.dart';
import 'package:stock_q/views/styles/custom.dart';
import 'package:stock_q/views/widgets/SectionTitle.dart';
import 'package:stock_q/views/widgets/appbar.dart';
import 'package:stock_q/views/widgets/in_section_spacing.dart';
import 'package:stock_q/views/widgets/section_spacing.dart';

class WishlistPage extends StatefulWidget {
  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<DummyProductModel> productsList = [
    DummyProductModel(
      productId: '101',
      title: 'Octopus Shootout',
      description:
          "This game is a BLAST times EIGHT! High energy, frenetic gameplay lets you and your opponent take control of your Octopus and spin them frantically back and forth as you try to score more balls into your opponents goal. Don't let your guard down and let octopus spin out of control! Highest score WINS!",
      thumbnailImage: {
        'image':
            'https://mmtcdn.blob.core.windows.net/084395e6770c4e0ebc5612f000acae8f/mmtcdn/Products26530-640x640-1897818831.jpg',
        'id': '1234'
      },
      price: 5000,
    ),
    DummyProductModel(
      productId: '102',
      title: 'Octopus Shootout',
      description:
          "This game is a BLAST times EIGHT! High energy, frenetic gameplay lets you and your opponent take control of your Octopus and spin them frantically back and forth as you try to score more balls into your opponents goal. Don't let your guard down and let octopus spin out of control! Highest score WINS!",
      discount: 20,
      thumbnailImage: {
        'image':
            'https://mmtcdn.blob.core.windows.net/084395e6770c4e0ebc5612f000acae8f/mmtcdn/Products26530-640x640-1897818831.jpg',
        'id': '1234'
      },
      price: 2200,
    ),
    DummyProductModel(
      productId: '103',
      title: 'Octopus Shootout',
      description:
          "This game is a BLAST times EIGHT! High energy, frenetic gameplay lets you and your opponent take control of your Octopus and spin them frantically back and forth as you try to score more balls into your opponents goal. Don't let your guard down and let octopus spin out of control! Highest score WINS!",
      thumbnailImage: {
        'image':
            'https://mmtcdn.blob.core.windows.net/084395e6770c4e0ebc5612f000acae8f/mmtcdn/Products26530-640x640-1897818831.jpg',
        'id': '1234'
      },
      price: 1000,
    ),
  ];

  List<Wishlist> inwishlistProductIds;
  Custom custom = Custom();
  @override
  Widget build(BuildContext context) {
    if (inwishlistProductIds == null) {
      inwishlistProductIds = List<Wishlist>();
    }
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text('Wishlist', style: Custom().appbarTitleTextStyle),
          leading: IconButton(
              icon: Icon(Icons.chevron_left),
              onPressed: () {
                Navigator.pop(context, true);
              }),
        ),
        body: SingleChildScrollView(
            child: Container(
                child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InSectionSpacing(),
            Column(
                children: productsList.map((p) {
              var w = false;
              var id;
              for (var wish in inwishlistProductIds) {
                log(wish.productId.toString());
                if (wish.productId == p.productId) {
                  w = true;
                  id = wish.id;
                  setState(() {});
                }
              }
              return Container();
                  // ? WishlistProduct(p, () {
                  //     if (id != null) {
                  //       _dbhelper.deleteWishlist(id);
                  //       inwishlistProductIds
                  //           .removeWhere((w) => w.productId == p.productId);
                  //       setState(() {});
                  //     }
                  //   })
                  // : Container();
            }).toList()),
          ],
        ))));
  }

}

class WishlistProduct extends StatefulWidget {
  final DummyProductModel product;
  final GestureTapCallback onPressed;
  WishlistProduct(this.product, this.onPressed);
  @override
  _WishlistProductState createState() =>
      _WishlistProductState(this.product, this.onPressed);
}

class _WishlistProductState extends State<WishlistProduct> {
  DummyProductModel _product;
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
                      image: NetworkImage(_product.thumbnailImage['image']))),
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
                      child: Text(_product.title, style: custom.bodyTextStyle)),
                  InSectionSpacing(),
                  Text('₹ ' + _product.price.toString(),
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
