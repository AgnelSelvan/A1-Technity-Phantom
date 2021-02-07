import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_q/resources/auth.dart';
import 'package:stock_q/widgets/parent_scaffold.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(Duration(seconds: 2), () {
      Auth.handleAuth();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ParentScaffold(
      child: Center(
        child: Text(
          'STOCK Q',
          style: Get.textTheme.headline5,
        ),
      ),
    );
  }
}
