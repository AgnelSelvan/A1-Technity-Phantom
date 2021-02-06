import 'package:flutter/material.dart';
import 'package:stock_q/services/auth.dart';
import 'package:stock_q/services/datastore.dart';
import 'package:stock_q/widgets/SectionTitle.dart';
import 'package:stock_q/widgets/home_page_carousel.dart';
import 'package:stock_q/widgets/in_section_spacing.dart';
import 'package:stock_q/widgets/product_carousel.dart';
import 'package:stock_q/widgets/section_spacing.dart';

class HomePage extends StatefulWidget {

  final Auth auth;
  final Datastore datastore;

  HomePage({this.auth, this.datastore});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SectionSpacing(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SectionTitle("Best Sellers"),
          ),
          InSectionSpacing(),
          HomePageCarousel(),
          SectionSpacing(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SectionTitle("Top Products"),
          ),
          InSectionSpacing(),
          ProductCarousel(),
          SectionSpacing()
        ],
      ),
    ));
  }
}
