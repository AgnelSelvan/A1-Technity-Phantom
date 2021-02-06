import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth{
  Future<String> signIn(String email, String password);
  Future<String> signUp(String email, String password);
  Future<User> getCurrentUser();
  Future<void> signOut();
}

class Auth implements BaseAuth{
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  @override
  Future<User> getCurrentUser() async{
    User currentUser = _firebaseAuth.currentUser;
    return currentUser;
  }

  @override
  Future<String> signIn(String email, String password) async{
    UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    User user = result.user;
    return user.uid;
  }

  @override
  Future<void> signOut() async{
    return _firebaseAuth.signOut();
  }

  @override
  Future<String> signUp(String email, String password) async{
    UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    User user = result.user;
    return user.uid;
  }

}