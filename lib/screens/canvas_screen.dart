import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:stock_q/utils/universal_variables.dart';
import 'package:stock_q/widgets/custom_divider.dart';

class CanvasScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          SizedBox(height: 15.0),
          Container(
              padding: EdgeInsets.only(right: 15.0),
              width: MediaQuery.of(context).size.width - 30.0,
              height: MediaQuery.of(context).size.height - 50.0,
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  BuildCanvasCard(
                    name: 'Paper Canvas',
                    imgPath: 'assets/images/bag.jpg',
                    isFavorite: true,
                    context: context,
                  ),
                  BuildCanvasCard(
                    name: 'Cookie cream',
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
                        scrollOnCollapse: true,
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
                              BuildCanvasCard(
                                name: 'Cookie mint',
                                imgPath: 'assets/images/bag.jpg',
                                isFavorite: false,
                                context: context,
                              ),
                              BuildCanvasCard(
                                name: 'Cookie mint',
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

class BuildCanvasCard extends StatelessWidget {
  final String name;
  final String imgPath;
  final bool isFavorite;
  final BuildContext context;

  const BuildCanvasCard(
      {this.context, this.imgPath, this.isFavorite, this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 5.0, bottom: 10.0, left: 5.0, right: 5.0),
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
                                Text('1 Roll',
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
                            Text('1 meter',
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
