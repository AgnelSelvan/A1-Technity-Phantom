import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_q/screens/navigation_screens/home_screen.dart';
import 'package:stock_q/screens/navigation_screens/profile_screen.dart';
import 'package:stock_q/utils/universal_variables.dart';

class RootScreen extends StatefulWidget {
  @override
  _RootScreenState createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _page = 0;

  final tabs = [HomeScreen(), ProfileScreen()];

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
      body: tabs[_page],
      bottomNavigationBar: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Colors.white,
          onTap: navigationTapped,
          currentIndex: _page,
          iconSize: 19,
          selectedFontSize: 20,
          unselectedFontSize: 16,
          selectedIconTheme: IconThemeData(color: Variables.primaryColor),
          unselectedIconTheme: IconThemeData(color: Colors.grey),
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                size: 19,
              ),
              title: Text(
                "Home",
                style: TextStyle(
                    fontSize: 18,
                    color: (_page == 0) ? Variables.primaryColor : Colors.grey),
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person_outline,
                size: 19,
              ),
              title: Text(
                "Profile",
                style: TextStyle(
                    fontSize: 18,
                    color: (_page == 1) ? Variables.primaryColor : Colors.grey),
              ),
            ),
          ]),
    );
  }
}
