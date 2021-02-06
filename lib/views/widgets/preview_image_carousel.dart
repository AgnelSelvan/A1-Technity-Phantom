import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stock_q/models/product.dart';
import 'package:stock_q/models/wishlist.dart';
import 'package:stock_q/views/pages/product_detail_page.dart';

class PreviewImageCarousel extends StatefulWidget {
  final Product product;
  PreviewImageCarousel({this.product});
  @override
  _PreviewImageCarouselState createState() => _PreviewImageCarouselState();
}

class _PreviewImageCarouselState extends State<PreviewImageCarousel> {
  var _activeSlideIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        height: 250,
        child: widget.product.previewImages != null
            ? Stack(
                children: <Widget>[
                  PageView.builder(
                      itemCount: widget.product.previewImages.length,
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
                            ProductCard(
                                previewImage: widget.product.previewImages[i]
                                    ['image'],
                                discount: widget.product.discount)
                          ],
                        );
                      }),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: widget.product.previewImages.map((m) {
                            var i = widget.product.previewImages.indexOf(m);
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
  final String previewImage;
  final int discount;
  ProductCard({this.previewImage, this.discount});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Colors.grey,
                image: DecorationImage(
                    fit: BoxFit.cover, image: NetworkImage(previewImage)))),
        discount != null && discount > 0
            ? Align(
                alignment: Alignment.topLeft,
                child: Container(
                    margin: EdgeInsets.only(left: 8, top: 8),
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(32)),
                    child: Center(
                      child: Text(
                        discount.toString() + "% OFF",
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    )))
            : Container()
      ],
    );
  }
}
