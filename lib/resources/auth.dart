import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_q/screens/auth_screen.dart';
import 'package:stock_q/screens/root_screen.dart';

import 'auth_controller.dart';

class Auth {
  Auth._();

  static final FirebaseAuth auth = FirebaseAuth.instance;

  static handleAuth() {
    Navigator.of(Get.context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (_) => Get.find<AuthController>().user != null
                ? RootScreen()
                : AuthScreen()),
        (route) => false);
  }
}
