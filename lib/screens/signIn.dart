import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:commune/helper/constants.dart';
import 'package:commune/screens/chatList.dart';
import 'package:commune/services/auth.dart';
import 'package:commune/services/database.dart';
import 'package:flutter/material.dart';
import 'package:commune/widgets/widget.dart';
import 'package:commune/helper/helperfunction.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';


class SignIn extends StatefulWidget {

  final Function toggle;
  SignIn(this.toggle);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  bool loading = false;

  QuerySnapshot snapShotUserInfo;

  final formKey = GlobalKey<FormState>();
  AuthMethods authMethods = new AuthMethods();
  DataBaseMethods dataBaseMethods = new DataBaseMethods();
  TextEditingController emailText = new TextEditingController();
  TextEditingController passwordText = new TextEditingController();

  signIn() {
    if (formKey.currentState.validate()) {

      HelperFunctions.saveUserEmailSharedPreference(emailText.text);

      setState(() {
        loading = true;
      });

      dataBaseMethods.getUserByUserEmail(emailText.text).then((val) {
        setState(() {
          snapShotUserInfo = val;
          HelperFunctions.saveUserNameSharedPreference(snapShotUserInfo.docs[0].data()['name']);
        });
      });
      
      authMethods.signInWithEmailAndPassword(emailText.text, passwordText.text).then((val) {
        if (val != null) {
          HelperFunctions.saveUserLoggedInSharedPreference(true);
          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => ChatList()
          ));
        }
      });
    }
  }

  signInThroughFacebook () async {

    var profile = await authMethods.loginWithFacebook();

    setState(() {
      loading = true;
      Constants.myName = profile['name'];
    });

    HelperFunctions.saveUserNameSharedPreference(profile['name']);
    HelperFunctions.saveUserEmailSharedPreference(profile['email']);

    dataBaseMethods.getUserByUserEmail(profile['email']).then((val) {
      if (val.docs.length == 0) {
        print("No such email exists");
        Map<String, String> userInfoMap = {
          'name' : profile['name'],
          'email' : profile['email']
        };
        dataBaseMethods.uploadUserInfo(userInfoMap);
      }
    });

    //dataBaseMethods.uploadUserInfo(userInfoMap);

    HelperFunctions.saveUserLoggedInSharedPreference(true);

    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => ChatList()
    ));

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery
              .of(context)
              .size
              .height - 50,
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                          validator: (val) {
                            return RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(val) ? null : 'Invalid email';
                          },
                          controller: emailText,
                          decoration: textFieldInputDecoration('Email')
                      ),
                      TextFormField(
                          obscureText: true,
                          validator: (val) {
                            return val.length > 6 ? null : 'Invalid Password';
                          },
                          controller: passwordText,
                          decoration: textFieldInputDecoration('Password')
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 18),
                Container(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Text('Forgot Password ?'),
                  ),
                ),
                SizedBox(height: 18),
                GestureDetector(
                  onTap: () {
                    //print({'$HelperFunctions.getUserNameSharedPreference()'});
                    signIn();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.blue[300]],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text('Sign In'),
                  ),
                ),
                SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        widget.toggle();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Register now',
                          style: TextStyle(
                            fontSize: 17,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 18),
                SignInButton(
                  Buttons.Facebook,

                  onPressed: () {
                    signInThroughFacebook();
                  },
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     GestureDetector(
                //       onTap: () {
                //         loginWithFacebook();
                //       },
                //       child: Container(
                //         padding: EdgeInsets.symmetric(vertical: 8),
                //         child: Text(
                //           'Login with Facebook',
                //           style: TextStyle(
                //             fontSize: 17,
                //             decoration: TextDecoration.underline,
                //           ),
                //         ),
                //       ),
                //     )
                //   ],
                // ),
                SizedBox(height: 50)
              ],
            ),
          ),
        ),
      ),
    );
  }
}