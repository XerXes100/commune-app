import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:commune/helper/authenticate.dart';
import 'package:commune/helper/helperfunction.dart';
import 'package:commune/screens/chatList.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool userIsLoggedIn = false;

  getUserInfo () async {
    await HelperFunctions.getUserNameSharedPreference().then((value) => print(value));
  }

  @override
  void initState () {
    // TODO: implement initState
    getLoggedInState();
    print('$userIsLoggedIn');
    getUserInfo();
    super.initState();
  }

  getLoggedInState () async {
    await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
      setState(() {
        if (value == null) {
          userIsLoggedIn = false;
        }
        else {
          userIsLoggedIn = value;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Commune',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: userIsLoggedIn ? ChatList() : Authenticate()
    );
  }
}

class Blank extends StatefulWidget {
  @override
  _BlankState createState() => _BlankState();
}

class _BlankState extends State<Blank> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}



