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

class HomePageCarousel extends StatefulWidget {
  @override
  _HomePageCarouselState createState() => _HomePageCarouselState();
}

class _HomePageCarouselState extends State<HomePageCarousel> {
  var _activeSlideIndex = 0;
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
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        height: 250,
        child: productsList != null
            ? Stack(
                children: <Widget>[
                  PageView.builder(
                      itemCount: productsList.length,
                      onPageChanged: (i) {
                        setState(() {
                          _activeSlideIndex = i;
                        });
                      },
                      itemBuilder: (BuildContext ctx, int i) {
                        return Stack(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                  margin: EdgeInsets.only(left: 8, top: 8),
                                  child: GestureDetector(
                                    child: Icon(
                                      CupertinoIcons.heart_solid,
                                      size: 40,
                                      color: Colors.pink[200],
                                    ),
                                    onTap: () {},
                                  )),
                            ),
                            ProductCard(productsList[i])
                          ],
                        );
                      }),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: productsList.map((m) {
                            var i = productsList.indexOf(m);
                            return Container(
                                alignment: Alignment.center,
                                width: 8,
                                height: 8,
                                margin: EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: _activeSlideIndex == i
                                      ? Colors.black87
                                      : Colors.black45,
                                ));
                          }).toList(),
                        ),
                      ))
                ],
              )
            : Center(child: CircularProgressIndicator()));
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  ProductCard(this.product);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext ctx) {
          return ProductPageDetailPage(product);
        }));
      },
      child: Stack(
        children: <Widget>[
          Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(
                      image: NetworkImage(product.thumbnailImage['image'])))),
          product.discount != null && product.discount > 0
              ? Align(
                  alignment: Alignment.topRight,
                  child: Container(
                      margin: EdgeInsets.only(right: 8, top: 8),
                      width: 64,
                      height: 64,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(32)),
                      child: Center(
                        child: Text(
                          product.discount.toString() + "% OFF",
                          style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      )))
              : Container()
        ],
      ),
    );
  }
}
