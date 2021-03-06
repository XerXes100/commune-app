import 'package:commune/helper/authenticate.dart';
import 'package:commune/helper/constants.dart';
import 'package:commune/helper/helperfunction.dart';

import 'package:commune/screens/conversationScreen.dart';
import 'package:commune/screens/groupConversationScreen.dart';
import 'package:commune/screens/search.dart';

import 'package:commune/services/auth.dart';
import 'package:commune/services/database.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class ChatList extends StatefulWidget {
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {

  AuthMethods authMethods = new AuthMethods();
  DataBaseMethods dataBaseMethods = new DataBaseMethods();

  Stream chatRoomsStream;

  Widget ChatRoomsList() {
    dynamic user = FirebaseAuth.instance.currentUser;
    print('Current user email: ${user.email}');
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (context, snapshot) {
        return snapshot.hasData ? ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: snapshot.data.documents.length,
          itemBuilder: (context, index) {
            return ChatRoomsTile(
              snapshot.data.docs[index].data()['chatRoomId']
                  .toString().replaceAll('_', '').replaceAll(Constants.myName, ''),
                snapshot.data.docs[index].data()['chatRoomId']
            );
          }
        ): Container();
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    getUserInfo();
    super.initState();
  }

  getUserInfo() async {
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    dataBaseMethods.getChatRooms(Constants.myName).then((value) {
      setState(() {
        chatRoomsStream = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Commune'),
        actions: [
          GestureDetector(
            onTap: () async {
              HelperFunctions.saveUserLoggedInSharedPreference(false);
              print("Login Through Facebook: ${Constants.loginThroughFacebook}");
              if (Constants.loginThroughFacebook == true) {
                await authMethods.logOutFacebook();
              }
              authMethods.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) => Authenticate()
              ));
            },
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.exit_to_app)
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          GroupChatTile(),
          ChatRoomsList()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => SearchScreen()
          ));
        },
      ),
    );
  }
}

class ChatRoomsTile extends StatelessWidget {
  final String userName;
  final String chatRoomId;
  ChatRoomsTile(this.userName, this.chatRoomId);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => ConversationScreen(chatRoomId: chatRoomId)
        ));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        color: Colors.grey[200],
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(40)
              ),
              child: Text('${userName.substring(0,1).toUpperCase()}'),
            ),
            SizedBox(width: 8),
            Text(userName, style: TextStyle(
              fontSize: 17
            ))
          ],
        ),
      ),
    );
  }
}

class GroupChatTile extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => GroupConversationScreen()
        ));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        color: Colors.grey[200],
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(40)
              ),
              child: Text('W'),
            ),
            SizedBox(width: 8),
            Text('Welcome to the community.',
                style: TextStyle(
                fontSize: 17
            ))
          ],
        ),
      ),
    );
  }
}




