import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'auth.dart';

class AuthController extends GetxController {
  Rx<User> _firebaseUser = Rx<User>();

  User get user => _firebaseUser.value;

  @override
  void onInit() {
    _firebaseUser.bindStream(Auth.auth.authStateChanges());
    super.onInit();
  }
}
