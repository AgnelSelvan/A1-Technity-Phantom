import 'package:flutter/material.dart';
import 'package:stock_q/views/pages/auth/auth_page.dart';
import 'package:stock_q/views/pages/home_page.dart';
import 'package:stock_q/views/pages/main_page.dart';
import 'package:stock_q/services/auth.dart';
import 'package:stock_q/services/datastore.dart';
import 'package:stock_q/views/widgets/loading.dart';

enum AuthStatus {
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class RootPage extends StatefulWidget {
  RootPage({this.auth, this.datastore});
  final BaseAuth auth;
  final BaseDatastore datastore;
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  String _userId;
  AuthStatus _authStatus = AuthStatus.NOT_LOGGED_IN;

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
        }
        _authStatus =
            user?.uid != null ? AuthStatus.LOGGED_IN : AuthStatus.NOT_LOGGED_IN;
      });
    });
  }

  void loginCallback() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user?.uid;
      });
    });
    setState(() {
      _authStatus = AuthStatus.LOGGED_IN;
    });
  }

  void logoutCallback() {
    setState(() {
      _authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_authStatus) {
      case AuthStatus.NOT_LOGGED_IN:
        return AuthPage(
            auth: widget.auth,
            datastore: widget.datastore,
            loginCallback: loginCallback);
        break;
      case AuthStatus.LOGGED_IN:
        return MainPage(
          auth: widget.auth,
          logoutCallback: logoutCallback,
          datastore: widget.datastore,
        );
        break;
      default:
        return Loading();
    }
  }
}
