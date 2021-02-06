import 'package:flutter/material.dart';
import 'package:stock_q/models/product.dart';
import 'package:stock_q/views/styles/custom.dart';
import 'package:stock_q/views/widgets/SectionTitle.dart';
import 'package:stock_q/views/widgets/appbar.dart';
import 'package:stock_q/views/widgets/in_section_spacing.dart';
import 'package:stock_q/views/widgets/preview_image_carousel.dart';
import 'package:stock_q/views/widgets/section_spacing.dart';

class ProductPageDetailPage extends StatefulWidget {
  final DummyProductModel product;
  ProductPageDetailPage(this.product);
  @override
  _ProductPageDetailPageState createState() =>
      _ProductPageDetailPageState(this.product);
}

class _ProductPageDetailPageState extends State<ProductPageDetailPage> {
  DummyProductModel _product;
  _ProductPageDetailPageState(this._product);
  Custom custom = Custom();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Product Detail', style: Custom().appbarTitleTextStyle),
        leading: IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () {
              Navigator.pop(context, true);
            }),
      ),
      body: SingleChildScrollView(
          child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _product.title,
              style: custom.bodyTextStyle,
            ),
            InSectionSpacing(),
            // Stack(children: <Widget>[
            //   Container(
            //       width: MediaQuery.of(context).size.width,
            //       height: 250,
            //       decoration: BoxDecoration(
            //           color: Colors.white,
            //           image: DecorationImage(
            //               image:
            //                   NetworkImage(_product.thumbnailImage['image'])))),
            //   _product.discount > 0
            //       ? Align(
            //           alignment: Alignment.topLeft,
            //           child: Container(
            //               width: 64,
            //               height: 64,
            //               alignment: Alignment.center,
            //               decoration: BoxDecoration(
            //                   color: Colors.red[100],
            //                   borderRadius: BorderRadius.circular(32)),
            //               child: Center(
            //                 child: Text(
            //                   _product.discount.toString() + "% OFF",
            //                   style: TextStyle(
            //                       fontSize: 10, fontWeight: FontWeight.bold),
            //                 ),
            //               )))
            //       : Container()
            // ]),
            //
            PreviewImageCarousel(product: this._product),
            InSectionSpacing(),
            Text(
              '₹ ' + _product.price.toString(),
              style: custom.titleTextStyle,
            ),
            InSectionSpacing(),
            Row(
              children: <Widget>[
                FlatButton(
                  onPressed: () {},
                  child: Text('Buy Now'),
                  color: custom.bodyTextColor,
                  textColor: Colors.white,
                ),
                SizedBox(width: 16),
                FlatButton(
                    onPressed: () {},
                    color: Colors.grey[200],
                    child: Text(
                      'Add to Cart',
                    )),
              ],
            ),
            SectionSpacing(),
            Text("About", style: custom.cardTitleTextStyle),
            InSectionSpacing(),
            Text(
              _product.description,
              style: custom.bodyTextStyle,
            )
          ],
        ),
      )),
    );
  }
}
