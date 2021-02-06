import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_q/views/pages/home_page.dart';
import 'package:stock_q/views/pages/product_page.dart';
import 'package:stock_q/views/pages/profile_page.dart';
import 'package:stock_q/views/pages/shopping_cart_page.dart';
import 'package:stock_q/views/services/auth.dart';
import 'package:stock_q/views/services/datastore.dart';
import 'package:stock_q/views/styles/custom.dart';
import 'package:stock_q/views/widgets/appbar.dart';
import 'package:stock_q/views/widgets/bottom_appbar.dart';

class MainPage extends StatefulWidget {
  final Auth auth;
  final Datastore datastore;
  final VoidCallback logoutCallback;
  MainPage({this.auth, this.datastore, this.logoutCallback});
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _index = 0;
  List<IconData> _bottomBarItem = [
    Icons.home,
    Icons.shopping_basket,
    Icons.shopping_cart,
    CupertinoIcons.person_solid
  ];
  Custom custom = Custom();
  List<Widget> _screens;
  var titles = ["Toys", "Products", "Shopping Cart", "Profile"];
  @override
  void initState() {
    super.initState();
    _screens = [
      HomePage(auth: widget.auth, datastore: widget.datastore,),
      ProductPage(auth: widget.auth, datastore: widget.datastore),
      ShoppingCartPage(auth: widget.auth, datastore: widget.datastore, ),
      ProfilePage(
          auth: widget.auth,
          datastore: widget.datastore,
          logoutCallback: widget.logoutCallback)
    ];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        appBar: MyAppBar(
          title: titles[_index],
        ),
        body: _screens[_index],
        bottomNavigationBar: AnimatedBottomBar(
            barItems: _bottomBarItem,
            duration: Duration(milliseconds: 200),
            onBarTap: (i) {
              setState(() {
                _index = i;
              });
            }));
  }
}
