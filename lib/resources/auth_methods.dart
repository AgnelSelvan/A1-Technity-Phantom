import 'package:annaistore/constants/strings.dart';
import 'package:annaistore/models/user.dart';
import 'package:annaistore/utils/utilities.dart';
import 'package:annaistore/widgets/dialogs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthMethods {
  static final Firestore _firestore = Firestore.instance;

  CollectionReference _userCollection = _firestore.collection(USERS_COLLECTION);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<FirebaseUser> getCurrentUser() async {
    DataConnectionStatus connectionStatus = await checkInternet();
    if (connectionStatus == DataConnectionStatus.connected) {
      FirebaseUser currentUser;
      currentUser = await _auth.currentUser();
      return currentUser;
    } else {
      return null;
    }
  }

  Future<User> getUserDetails() async {
    FirebaseUser currentUser = await getCurrentUser();

    DocumentSnapshot documentSnapshot =
        await _userCollection.document(currentUser.uid).get();
    return User.fromMap(documentSnapshot.data);
  }

  Future<FirebaseUser> signUp(String email, String password) async {
    AuthResult result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    return user;
  }

  Future<bool> signIn(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isPhoneNoExists(FirebaseUser firebaseUser) async {
    DocumentSnapshot doc =
        await _userCollection.document(firebaseUser.uid).get();
    User user = User.fromMap(doc.data);
    return user.mobileNo == '' || user.mobileNo == null ? false : true;
  }

  Future<bool> updateMobileNumber(
      String mobileNumber, FirebaseUser user) async {
    try {
      _userCollection
          .document(user.uid)
          .updateData({MOBILE_NO_FIELD: mobileNumber.trim()});
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<FirebaseUser> googleSignIn() async {
    try {
      GoogleSignInAccount _signInAccount = await _googleSignIn.signIn();
      if (await _googleSignIn.isSignedIn()) {
        GoogleSignInAuthentication _signInAuthentication =
            await _signInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.getCredential(
            idToken: _signInAuthentication.idToken,
            accessToken: _signInAuthentication.accessToken);
        AuthResult result = await _auth.signInWithCredential(credential);
        FirebaseUser user = result.user;

        return user;
      } else {
        return null;
      }
    } catch (e) {
      //print(e);
      return null;
    }
  }

  Future<bool> authenticateUserByEmailId(FirebaseUser user) async {
    QuerySnapshot result = await _firestore
        .collection(USERS_COLLECTION)
        .where(EMAIL_FIELD, isEqualTo: user.email)
        .getDocuments();

    final List<DocumentSnapshot> docs = result.documents;

    return docs.length == 0 ? true : false;
  }

  Future<bool> authenticateUserByPhone(FirebaseUser user) async {
    QuerySnapshot result = await _userCollection
        .where(MOBILE_NO_FIELD, isEqualTo: user.phoneNumber.trim())
        .getDocuments();

    final List<DocumentSnapshot> docs = result.documents;

    return docs.length == 0 ? true : false;
  }

  Future<void> addGoogleDataToDb(FirebaseUser currentUser) async {
    String username = Utils.getUsername(currentUser.email);

    User user = User(
        email: currentUser.email,
        uid: currentUser.uid,
        name: currentUser.displayName,
        profilePhoto: currentUser.photoUrl,
        username: username,
        role: USER_STRING);

    _firestore
        .collection(USERS_COLLECTION)
        .document(currentUser.uid)
        .setData(user.toMap(user));
  }

  Future<void> addPhoneDataToDb(FirebaseUser currentUser) async {
    String displayName = Utils.getPhoneDisplayName();

    User user = User(
        uid: currentUser.uid,
        name: displayName,
        profilePhoto: currentUser.photoUrl,
        mobileNo: currentUser.phoneNumber.trim(),
        username: displayName.toLowerCase(),
        role: USER_STRING);

    _firestore
        .collection(USERS_COLLECTION)
        .document(currentUser.uid)
        .setData(user.toMap(user));
  }

  Future<void> addUserDataToDb(
      FirebaseUser currentUser, String username) async {
    String displayName = Utils.getUsername(currentUser.email);

    User user = User(
        email: currentUser.email,
        uid: currentUser.uid,
        name: displayName,
        profilePhoto: currentUser.photoUrl,
        username: username,
        role: USER_STRING);

    _firestore
        .collection(USERS_COLLECTION)
        .document(currentUser.uid)
        .setData(user.toMap(user));
  }

  Future<User> getUserDetailsById(String userId) async {
    try {
      //print("UserId: $userId");
      DocumentSnapshot doc = await _userCollection.document(userId).get();
      return User.fromMap(doc.data);
    } catch (e) {
      //print("get user by details error: $e");
      return null;
    }
  }

  Future<bool> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<QuerySnapshot> getAllUserWithUserRole() {
    return _userCollection.where('role', isEqualTo: 'user').snapshots();
  }

  Future<bool> makeAdmin(String userId) async {
    try {
      await _userCollection.document(userId).updateData({'role': 'admin'});
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> demoteAdminToUser(String userId) async {
    try {
      await _userCollection.document(userId).updateData({'role': 'user'});
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<DataConnectionStatus> checkInternet() async {
    var listener = DataConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case DataConnectionStatus.connected:
          //print("Contection is available");
          break;
        case DataConnectionStatus.disconnected:
          //print("Contection is not available");
          break;
      }
    });

    //print(await DataConnectionChecker().hasConnection);
    //print(await DataConnectionChecker().connectionStatus);

    await Future.delayed(Duration(seconds: 10));
    await listener.cancel();
    return DataConnectionChecker().connectionStatus;
  }
}
