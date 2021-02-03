import 'package:commune/modal/userGet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class AuthMethods {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserGet _userFromFbUser (User fbUser) {
    return fbUser != null ? UserGet(userId: fbUser.uid) : null;
  }

  Future signInWithFacebook (accessToken) async {
    try {
      AuthCredential credential = FacebookAuthProvider.getCredential(accessToken.token);
      User firebaseUser = (await FirebaseAuth.instance.signInWithCredential(credential)).user;
      return _userFromFbUser(firebaseUser);
    } catch(e) {
      print(e.toString());
    }
  }

  Future signInWithEmailAndPassword (String email, String password) async
  {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword
        (email: email, password: password);
      User firebaseUser = result.user;
      return _userFromFbUser(firebaseUser);
    } catch(e) {
      print(e.toString());
    }
  }

  Future signUpWithEmailAndPassword (String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword
        (email: email, password: password);
      User firebaseUser = result.user;
      return _userFromFbUser(firebaseUser);
    } catch (e) {
      print(e.toString());
    }
  }

  Future resetPassword (String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
    }
  }

  Future signOut () async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

}