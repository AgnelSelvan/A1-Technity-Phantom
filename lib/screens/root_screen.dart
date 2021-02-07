import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_q/screens/navigation_screens/home_screen.dart';
import 'package:stock_q/screens/navigation_screens/profile_screen.dart';
import 'package:stock_q/utils/universal_variables.dart';
import 'package:stock_q/widgets/bottom_appbar.dart';

class RootScreen extends StatefulWidget {
  @override
  _RootScreenState createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _page = 0;
  List<BarItem> _bottomBarItem = [
    BarItem(title: 'Home', iconData: Icons.home),
    BarItem(title: 'Profile', iconData: Icons.person),
  ];
  final List<Widget> _screens = [HomeScreen(), ProfileScreen()];
  @override
  void initState() {
    super.initState();
  }

  void navigationTapped(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Variables.lightGreyColor,
        body: _screens[_page],
        bottomNavigationBar: AnimatedBottomBar(
            barItems: _bottomBarItem,
            duration: Duration(milliseconds: 200),
            onBarTap: (i) {
              navigationTapped(i);
            }));
  }
}
