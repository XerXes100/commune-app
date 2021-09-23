import 'package:commune/helper/helperfunction.dart';
import 'package:commune/services/auth.dart';
import 'package:commune/services/database.dart';
import 'package:flutter/material.dart';
import 'package:commune/widgets/widget.dart';
import 'package:commune/screens/chatList.dart';

class SignUp extends StatefulWidget {

  final Function toggle;
  SignUp(this.toggle);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  bool loading = false;

  AuthMethods authMethods = new AuthMethods();
  DataBaseMethods dataBaseMethods = new DataBaseMethods();
  HelperFunctions helperFunctions = new HelperFunctions();

  final formKey = GlobalKey<FormState>();
  TextEditingController userNameText = new TextEditingController();
  TextEditingController emailText = new TextEditingController();
  TextEditingController passwordText = new TextEditingController();

  signMeUp() {
    if (formKey.currentState.validate()) {

      dataBaseMethods.addUserToGroup(userNameText.text);

      setState(() {
        loading = true;
      });

      HelperFunctions.saveUserNameSharedPreference(userNameText.text);
      HelperFunctions.saveUserEmailSharedPreference(emailText.text);

      authMethods.signUpWithEmailAndPassword(emailText.text, passwordText.text).then((val) {
        //print('${val.uid}');

        Map<String, String> userInfoMap = {
          'name' : userNameText.text,
          'email' : emailText.text,
          'password' : passwordText.text
        };

        dataBaseMethods.uploadUserInfo(userInfoMap);
        HelperFunctions.saveUserLoggedInSharedPreference(true);

        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => ChatList()
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: loading ? Container(
        child: Center(child: CircularProgressIndicator()),
      ): SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height - 70,
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
                        validator: (val){
                          return val.isEmpty || val.length <= 3 ? "Please enter valid username" : null;
                        },
                        controller: userNameText,
                        decoration: textFieldInputDecoration('Username')
                      ),
                      TextFormField(
                        validator: (val){
                          return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(val) ? null : 'Invalid email';
                        },
                        controller: emailText,
                        decoration: textFieldInputDecoration('Email')
                      ),
                      TextFormField(
                        obscureText: true,
                        validator: (val){
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
                  child: Container (
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('Forgot Password ?'),
                  ),
                ),
                SizedBox(height: 18),
                GestureDetector(
                  onTap: () {
                    signMeUp();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.blue[300]],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text('Sign Up'),
                  ),
                ),
                SizedBox(height: 16),
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
                          'Sign In',
                          style: TextStyle(
                            fontSize: 17,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
