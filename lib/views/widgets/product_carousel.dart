import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stock_q/dbhelpers/wishlist_dbhelper.dart';
import 'package:stock_q/models/product.dart';
import 'package:stock_q/models/wishlist.dart';
import 'package:stock_q/pages/product_detail_page.dart';
import 'package:stock_q/styles/custom.dart';
import 'package:stock_q/widgets/in_section_spacing.dart';

class ProductCarousel extends StatefulWidget {
  @override
  _ProductCarouselState createState() => _ProductCarouselState();
}

class _ProductCarouselState extends State<ProductCarousel> {
  List<Product> productsList = [
    Product(
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
    Product(
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
    Product(
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
  var _dbhelper = WishlistDBHelper();
  void updateWishlist() {
    Future<Database> dbFuture = _dbhelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Wishlist>> wishlistFuture = _dbhelper.getWishlist();
      wishlistFuture.then((wishlists) {
        setState(() {
          inwishlistProductIds.addAll(wishlists);
          log(inwishlistProductIds.toString());
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (inwishlistProductIds == null) {
      inwishlistProductIds = [];
      updateWishlist();
    }
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        height: 250,
        child: productsList != null
            ? productsList.length > 0
                ? ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: productsList.length,
                    itemBuilder: (BuildContext ctx, int i) {
                      var w;
                      var id;

                      for (var wish in inwishlistProductIds) {
                        if (wish.productId == productsList[i].productId) {
                          w = true;
                          id = wish.id;
                        }
                      }
                      return Stack(children: <Widget>[
                        ProductCard(productsList[i]),
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                              margin: EdgeInsets.only(left: 8, top: 8),
                              child: GestureDetector(
                                child: Icon(
                                  w != null
                                      ? w
                                          ? CupertinoIcons.heart_solid
                                          : CupertinoIcons.heart
                                      : CupertinoIcons.heart,
                                  size: 32,
                                  color: Colors.pink[200],
                                ),
                                onTap: () async {
                                  if (id != null) {
                                    w = false;
                                    _dbhelper.deleteWishlist(id);
                                    inwishlistProductIds
                                        .removeWhere((w) => w.id == id);
                                    setState(() {});
                                  } else {
                                    _dbhelper.insertWishlist(Wishlist(
                                        productId: productsList[i].productId));
                                  }
                                  updateWishlist();
                                },
                              )),
                        ),
                      ]);
                    })
                : Container()
            : Center(child: CircularProgressIndicator()));
  }
}

class ProductCard extends StatefulWidget {
  final Product product;

  ProductCard(this.product);
  @override
  _ProductCardState createState() => _ProductCardState(this.product);
}

class _ProductCardState extends State<ProductCard> {
  Product _product;
  _ProductCardState(this._product);
  Custom custom = Custom();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext ctx) {
          return ProductPageDetailPage(_product);
        }));
      },
      child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          margin: EdgeInsets.only(right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                      height: 150,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          image: DecorationImage(
                              fit: BoxFit.contain,
                              image: NetworkImage(
                                  _product.thumbnailImage['image'])))),
                  _product.discount != null && _product.discount > 0
                      ? Align(
                          alignment: Alignment.topRight,
                          child: Container(
                              width: 56,
                              height: 56,
                              margin: EdgeInsets.only(top: 0, left: 8),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.red[100],
                                  borderRadius: BorderRadius.circular(32)),
                              child: Center(
                                child: Text(
                                  _product.discount.toString() + "% OFF",
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                              )))
                      : Container()
                ],
              ),
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8))),
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      InSectionSpacing(),
                      Text(
                        _product.title,
                        style: custom.bodyTextStyle,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "₹ " + _product.price.toString(),
                        style: custom.cardTitleTextStyle,
                      ),
                    ],
                  ))
            ],
          )),
    );
  }
}
