import 'dart:convert';
import 'package:commune/screens/chatList.dart';
import 'package:flutter/material.dart';
import 'package:commune/helper/constants.dart';
import 'package:commune/helper/helperfunction.dart';
import 'package:commune/modal/userGet.dart';
import 'package:commune/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;

class AuthMethods {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  static final FacebookLogin facebookSignIn = new FacebookLogin();

  DataBaseMethods dataBaseMethods = new DataBaseMethods();

  UserGet _userFromFbUser (User fbUser) {
    return fbUser != null ? UserGet(userId: fbUser.uid) : null;
  }

  Future signInWithFacebook (accessToken) async {
    try {
      AuthCredential credential = FacebookAuthProvider.credential(accessToken.token);
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

  loginWithFacebook() async {
    final FacebookLoginResult result =
    await facebookSignIn.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        Constants.loginThroughFacebook = true;
        final FacebookAccessToken accessToken = result.accessToken;
        print('''
         Logged in!
         
         Token: ${accessToken.token}
         User id: ${accessToken.userId}
         Expires: ${accessToken.expires}
         Permissions: ${accessToken.permissions}
         Declined permissions: ${accessToken.declinedPermissions}
         
         ''');

        final graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=${accessToken.token}');

        final profile = jsonDecode(graphResponse.body);

        await signInWithFacebook(accessToken);

        return profile;
        break;

      case FacebookLoginStatus.cancelledByUser:
        print('Login cancelled by the user.');
        break;

      case FacebookLoginStatus.error:
        print('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.errorMessage}');
        break;
    }
  }

  logOutFacebook() async {
    await facebookSignIn.logOut();
  }

}