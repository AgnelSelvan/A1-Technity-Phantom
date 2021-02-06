import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:stock_q/constants/strings.dart';
import 'package:stock_q/models/user.dart';
import 'package:stock_q/utils/utilities.dart';

class AuthMethods {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _userCollection = _firestore.collection(USERS_COLLECTION);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User> getCurrentUser() async {
    DataConnectionStatus connectionStatus = await checkInternet();
    if (connectionStatus == DataConnectionStatus.connected) {
      User currentUser;
      currentUser = _auth.currentUser;
      return currentUser;
    } else {
      return null;
    }
  }

  Future<UserModel> getUserDetails() async {
    User currentUser = await getCurrentUser();

    DocumentSnapshot documentSnapshot =
        await _userCollection.doc(currentUser.uid).get();
    return UserModel.fromMap(documentSnapshot.data());
  }

  Future<User> signUp(String email, String password) async {
    var result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    User user = result.user;
    return user;
  }

  Future<bool> signIn(String email, String password) async {
    try {
      var result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isPhoneNoExists(User firebaseUser) async {
    DocumentSnapshot doc = await _userCollection.doc(firebaseUser.uid).get();
    UserModel user = UserModel.fromMap(doc.data());
    return user.mobileNo == '' || user.mobileNo == null ? false : true;
  }

  Future<bool> updateMobileNumber(String mobileNumber, User user) async {
    try {
      _userCollection
          .doc(user.uid)
          .update({MOBILE_NO_FIELD: mobileNumber.trim()});
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<User> googleSignIn() async {
    try {
      GoogleSignInAccount _signInAccount = await _googleSignIn.signIn();
      if (await _googleSignIn.isSignedIn()) {
        GoogleSignInAuthentication _signInAuthentication =
            await _signInAccount.authentication;

        GoogleSignInAccount googleSignInAccount = await GoogleSignIn().signIn();
        User user = await getCurrentUser();

        return user;
      } else {
        return null;
      }
    } catch (e) {
      //print(e);
      return null;
    }
  }

  Future<bool> authenticateUserByEmailId(User user) async {
    QuerySnapshot result = await _firestore
        .collection(USERS_COLLECTION)
        .where(EMAIL_FIELD, isEqualTo: user.email)
        .get();

    final List<DocumentSnapshot> docs = result.docs;

    return docs.length == 0 ? true : false;
  }

  Future<bool> authenticateUserByPhone(User user) async {
    QuerySnapshot result = await _userCollection
        .where(MOBILE_NO_FIELD, isEqualTo: user.phoneNumber.trim())
        .get();

    final List<DocumentSnapshot> docs = result.docs;

    return docs.length == 0 ? true : false;
  }

  Future<void> addGoogleDataToDb(User currentUser) async {
    String username = Utils.getUsername(currentUser.email);

    UserModel user = UserModel(
        email: currentUser.email,
        uid: currentUser.uid,
        name: currentUser.displayName,
        profilePhoto: currentUser.photoURL,
        username: username,
        role: USER_STRING);

    _firestore
        .collection(USERS_COLLECTION)
        .doc(currentUser.uid)
        .set(user.toMap(user));
  }

  Future<void> addPhoneDataToDb(User currentUser) async {
    String displayName = Utils.getPhoneDisplayName();

    UserModel user = UserModel(
        uid: currentUser.uid,
        name: displayName,
        profilePhoto: currentUser.photoURL,
        mobileNo: currentUser.phoneNumber.trim(),
        username: displayName.toLowerCase(),
        role: USER_STRING);

    _firestore
        .collection(USERS_COLLECTION)
        .doc(currentUser.uid)
        .set(user.toMap(user));
  }

  Future<void> addUserDataToDb(User currentUser, String username) async {
    String displayName = Utils.getUsername(currentUser.email);

    UserModel user = UserModel(
        email: currentUser.email,
        uid: currentUser.uid,
        name: displayName,
        profilePhoto: currentUser.photoURL,
        username: username,
        role: USER_STRING);

    _firestore
        .collection(USERS_COLLECTION)
        .doc(currentUser.uid)
        .set(user.toMap(user));
  }

  Future<UserModel> getUserDetailsById(String userId) async {
    try {
      //print("UserId: $userId");
      DocumentSnapshot doc = await _userCollection.doc(userId).get();
      return UserModel.fromMap(doc.data());
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
      await _userCollection.doc(userId).update({'role': 'admin'});
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> demoteAdminToUser(String userId) async {
    try {
      await _userCollection.doc(userId).update({'role': 'user'});
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
