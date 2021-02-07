import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:stock_q/constants/strings.dart';
import 'package:stock_q/models/user.dart';

import 'auth.dart';

class AuthController extends GetxController {
  Rx<User> _firebaseUser = Rx<User>();

  User get user => _firebaseUser.value;

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference _userCollection = _firestore.collection(USERS_COLLECTION);

  Rx<UserModel> userModel = Rx<UserModel>();

  Future<void> getUserData() async {
    _firestore.collection(USERS_COLLECTION).doc(user.uid).snapshots().listen((
        event) {
      userModel.value = UserModel.fromMap(event.data());
      userModel.refresh();
    });
  }

  @override
  void onInit() {
    _firebaseUser.bindStream(Auth.auth.authStateChanges());
    super.onInit();
  }
}
