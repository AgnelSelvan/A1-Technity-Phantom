import 'package:connectivity_widget/connectivity_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stock_q/utils/size_utils.dart';
import 'package:stock_q/utils/utilities.dart';

class ParentScaffold extends StatelessWidget {
  final Widget child;
  final double topMargin;
  final double bottomMargin;
  final double leftMargin;
  final double rightMargin;
  final Color statusBarColor;
  final Color backgroundColor;
  final AppBar appBar;
  final BottomAppBar bottomAppBar;
  final Widget drawer;
  final FloatingActionButtonLocation floatingActionButtonLocation;
  final Widget floatingActionButton;
  final bool extendBody;
  final bool checkNetworkStatus;
  final GlobalKey globalKey;

  ParentScaffold(
      {Key key,
      this.child,
      this.topMargin = SizeUtils.marginHorizontal,
      this.bottomMargin = SizeUtils.marginHorizontal,
      this.leftMargin = SizeUtils.marginHorizontal,
      this.rightMargin = SizeUtils.marginHorizontal,
      this.statusBarColor = Colors.transparent,
      this.backgroundColor,
      this.appBar,
      this.bottomAppBar,
      this.extendBody = false,
      this.floatingActionButtonLocation,
      this.drawer,
      this.floatingActionButton,
      this.checkNetworkStatus = true,
      this.globalKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeUtils.init();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: statusBarColor),
      child: Scaffold(
        key: globalKey,
        extendBody: extendBody,
        appBar: appBar,
        drawer: drawer,
        bottomNavigationBar: bottomAppBar,
        floatingActionButtonLocation: floatingActionButtonLocation,
        floatingActionButton: floatingActionButton,
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: checkNetworkStatus
              ? StreamBuilder<bool>(
                  stream: ConnectivityUtils.instance.isPhoneConnectedStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Utils.waitingScreen();

                    return snapshot.data ? child : Utils.noInternet();
                  })
              : child,
        ),
      ),
    );
  }
}
