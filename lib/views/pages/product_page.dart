import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stock_q/dbhelpers/wishlist_dbhelper.dart';
import 'package:stock_q/models/product.dart';
import 'package:stock_q/models/wishlist.dart';
import 'package:stock_q/pages/product_detail_page.dart';
import 'package:stock_q/services/auth.dart';
import 'package:stock_q/services/datastore.dart';
import 'package:stock_q/styles/custom.dart';
import 'package:stock_q/widgets/SectionTitle.dart';
import 'package:stock_q/widgets/appbar.dart';
import 'package:stock_q/widgets/home_page_carousel.dart';
import 'package:stock_q/widgets/in_section_spacing.dart';
import 'package:stock_q/widgets/section_spacing.dart';

class ProductPage extends StatefulWidget {
  final Auth auth;
  final Datastore datastore;

  ProductPage({this.auth, this.datastore});
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
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

  TextEditingController _searchController = TextEditingController();
  var filters = ['Price. Low to High', 'Price. High to Low'];
  Custom custom = Custom();
  List<Wishlist> inwishlistProductIds;
  var _dbhelper = WishlistDBHelper();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (inwishlistProductIds == null) {
      inwishlistProductIds = List<Wishlist>();
      updateWishlist();
    }
    return SingleChildScrollView(
      child: Container(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                margin: EdgeInsets.only(left: 16, top: 16, bottom: 16),
                padding: EdgeInsets.symmetric(horizontal: 8),
                height: 48,
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadiusDirectional.circular(8)),
                child: Center(
                    child: TextField(
                        style: custom.bodyTextStyle,
                        controller: _searchController,
                        decoration: InputDecoration(
                            hintStyle: custom.bodyTextStyle,
                            hintText: 'Search',
                            border: InputBorder.none))),
              ),
              Container(
                margin: EdgeInsets.only(left: 8),
                padding: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadiusDirectional.circular(8)),
                width: MediaQuery.of(context).size.width * 0.5 - 40,
                child: DropdownButton(
                    underline: SizedBox(),
                    items: filters.map((f) {
                      return DropdownMenuItem(
                        child: Text('Filters'),
                      );
                    }).toList(),
                    onChanged: (val) {}),
              )
            ],
          ),
          Column(
              children: productsList.map((p) {
            var w;
            var id;

            for (var wish in inwishlistProductIds) {
              if (wish.productId == p.productId) {
                w = true;
                id = wish.id;
              }
            }
            log(w.toString());
            return Stack(
              children: <Widget>[
                ProductCard(p),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                      margin: EdgeInsets.only(right: 24, top: 16),
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
                            int i = await _dbhelper.deleteWishlist(id);
                            inwishlistProductIds.removeWhere((w) => w.id == id);
                            setState(() {});
                          } else {
                            int i = await _dbhelper.insertWishlist(
                                Wishlist(productId: p.productId));
                          }
                          updateWishlist();
                        },
                      )),
                ),
              ],
            );
          }).toList()),
        ],
      )),
    );
  }

  void updateWishlist() {
    Future<Database> dbFuture = _dbhelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Wishlist>> wishlistFuture = _dbhelper.getWishlist();
      wishlistFuture.then((wishlists) {
        setState(() {
          inwishlistProductIds.addAll(wishlists);
        });
      });
    });
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
                        child:
                            Text(_product.title, style: custom.bodyTextStyle)),
                    InSectionSpacing(),
                    Text('₹ ' + _product.price.toString(),
                        style: custom.cardTitleTextStyle),
                  ])
            ],
          )),
    );
  }
}
