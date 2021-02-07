import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:stock_q/models/product.dart';
import 'package:stock_q/utils/universal_variables.dart';
import 'package:stock_q/widgets/custom_divider.dart';
import 'package:stock_q/widgets/size_config.dart';

class BagScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          SizedBox(height: 15.0),
          Container(
              padding: EdgeInsets.only(right: 10.0),
              width: MediaQuery.of(context).size.width - 20.0,
              height: MediaQuery.of(context).size.height - 100.0,
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  BuildThreadCard(
                    name: 'Vardhaman Thread(100m)',
                    imgPath: 'assets/images/bag.jpg',
                    isFavorite: true,
                    context: context,
                  ),
                  BuildThreadCard(
                    name: 'Ameto cream(100m)',
                    imgPath: 'assets/images/bag.jpg',
                    isFavorite: true,
                    context: context,
                  ),
                  ExpandableTheme(
                    data: const ExpandableThemeData(
                      // iconColor: Variables.primaryColor,
                      useInkWell: true,
                    ),
                    child: ExpandableNotifier(
                      child: ScrollOnExpand(
                        scrollOnExpand: true,
                        scrollOnCollapse: false,
                        child: ExpandablePanel(
                          theme: const ExpandableThemeData(
                            headerAlignment:
                                ExpandablePanelHeaderAlignment.center,
                            tapBodyToCollapse: true,
                          ),
                          header: Padding(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                children: <Widget>[],
                              )),
                          expanded: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              ProductCard(
                                  press: () {},
                                  product: Product(
                                      id: "123",
                                      name: "Product1",
                                      sellingRate: 1234,
                                      purchaseRate: 1234)),
                              BuildThreadCard(
                                name: 'Vardhaman Thread(500m)',
                                imgPath: 'assets/images/bag.jpg',
                                isFavorite: false,
                                context: context,
                              ),
                              BuildThreadCard(
                                name: 'Coats Thread(100m)',
                                imgPath: 'assets/images/bag.jpg',
                                isFavorite: false,
                                context: context,
                              ),
                            ],
                          ),
                          builder: (_, collapsed, expanded) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  left: 10, right: 10, bottom: 10),
                              child: Expandable(
                                collapsed: collapsed,
                                expanded: expanded,
                                theme: const ExpandableThemeData(
                                    crossFadePoint: 0),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  )
                ],
              )),
          SizedBox(height: 15.0)
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({
    Key key,
    this.product,
    this.press,
  }) : super(key: key);

  final Product product;
  final Function press;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    double defaultSize = SizeConfig.defaultSize;
    return GestureDetector(
      onTap: press,
      child: Container(
        width: defaultSize * 14.5, //145
        decoration: BoxDecoration(
          color: Variables.lightPrimaryColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: AspectRatio(
          aspectRatio: 0.693,
          child: Column(
            children: <Widget>[
              AspectRatio(
                aspectRatio: 1,
                child: Hero(
                  tag: product.id,
                  child: FadeInImage.assetNetwork(
                    placeholder: "assets/images/spinner.gif",
                    image: "https://via.placeholder.com/150",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: defaultSize),
                child: Text(product.name),
              ),
              SizedBox(height: defaultSize / 2),
              Text("\$${product.purchaseRate}"),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class BuildThreadCard extends StatelessWidget {
  final String name;
  final String imgPath;
  final bool isFavorite;
  final BuildContext context;

  const BuildThreadCard(
      {this.context, this.imgPath, this.isFavorite, this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5.0, right: 5.0),
        child: InkWell(
            onTap: () {},
            child: Container(
                width: MediaQuery.of(context).size.width / 2.4,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 3.0,
                          blurRadius: 5.0)
                    ],
                    color: Colors.white),
                child: Column(children: [
                  Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            isFavorite
                                ? Icon(
                                    Icons.favorite,
                                    color: Color(0xFFEF7532),
                                    size: 16,
                                  )
                                : Icon(
                                    Icons.favorite_border,
                                    color: Color(0xFFEF7532),
                                    size: 16,
                                  )
                          ])),
                  Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(imgPath), fit: BoxFit.contain)),
                      child: Image.asset(imgPath)),
                  // Hero(
                  //     tag: imgPath,
                  //     child: Container(
                  //         height: 100.0,
                  //         width: 100.0,
                  //         decoration: BoxDecoration(
                  //             image: DecorationImage(
                  //                 image: AssetImage(imgPath),
                  //                 fit: BoxFit.contain)))),
                  SizedBox(height: 7.0),
                  Text(name,
                      style:
                          TextStyle(color: Color(0xFF575E67), fontSize: 14.0)),
                  CustomDivider(leftSpacing: 10, rightSpacing: 10),
                  Column(
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(left: 5.0, right: 5.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text('2 Bag',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Variables.blackColor,
                                        fontSize: 12.0)),
                                Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.yellow[50],
                                  ),
                                  child: Text('₹ 120',
                                      style: TextStyle(
                                          color: Variables.primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.0)),
                                ),
                              ])),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text('1 Bag',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Variables.blackColor,
                                    fontSize: 12.0)),
                            Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.yellow[50],
                              ),
                              child: Text('₹ 6',
                                  style: TextStyle(
                                      color: Variables.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.0)),
                            ),
                          ])
                    ],
                  )
                ]))));
  }
}
