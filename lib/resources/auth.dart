import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stock_q/screens/login/login.dart';
import 'package:stock_q/screens/root_screen.dart';
import 'package:stock_q/utils/utilities.dart';

import 'auth_controller.dart';

class Auth {
  Auth._();

  static final FirebaseAuth auth = FirebaseAuth.instance;

  static handleAuth() {
    Navigator.of(Get.context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (_) => Get.find<AuthController>().user != null
                ? RootScreen()
                : Login()),
        (route) => false);
  }

  static Future<bool> signInEmail(String email, String password) async {
    try {
      var result = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      print(result.user.email);
      return true;
    } catch (e) {
      FirebaseAuthException exception = e;
      log(exception.message);
      Utils.showSnackBar(text: exception.message);
      return false;
    }
  }
}
