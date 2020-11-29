import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:commune/helper/constants.dart';
import 'package:commune/screens/conversationScreen.dart';
import 'package:commune/services/database.dart';
import 'package:commune/widgets/widget.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  DataBaseMethods dataBaseMethods = new DataBaseMethods();
  TextEditingController searchTextEditingController = new TextEditingController();
  
  QuerySnapshot snapshot;

  initiateSearch () {
    dataBaseMethods.getUserByUsername(searchTextEditingController.text)
        .then((val){
          setState(() {
            snapshot = val;
          });
    });
  }

  ///Create Chatroom, send user to conversation screen, pushreplacement

  createChatRoomAndStartConversation ({String userName}) {

    if (userName != Constants.myName){
      String chatRoomId = getChatRoomId(userName, Constants.myName);

      List<String> users = [userName, Constants.myName];
      Map <String, dynamic> chatRoomMap = {
        'users': users,
        'chatRoomId' : chatRoomId,
      };

      DataBaseMethods().createChatRoom(chatRoomId, chatRoomMap);
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => ConversationScreen(chatRoomId: chatRoomId)
      ));
    }
    else {
      print('You cannot send the message to yourself');
    }
  }

  Widget SearchTile ({String userName, String userEmail}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName, style: TextStyle(
                  fontSize: 17,
                )),
                Text(userEmail, style: TextStyle(
                  fontSize: 17,
                ),
                ),
              ]
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              createChatRoomAndStartConversation(userName: userName);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text('Message'),
            ),
          )
        ],
      ),
    );
  }

  Widget searchList () {
    return snapshot != null ? ListView.builder(
      itemCount: snapshot.docs.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return SearchTile(
          userName: snapshot.docs[index].data()['name'],
          userEmail: snapshot.docs[index].data()['email'],
        );
      },
    ) : Container();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: Container(
        child: Column(
          children: [
            Container(
              color: Colors.black12,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                        controller: searchTextEditingController,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(
                            color: Colors.grey
                          ),
                          border: InputBorder.none,
                        ),
                      )
                  ),
                  GestureDetector(
                    onTap: () {
                      initiateSearch();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Text('Search'),
                    ),
                  )
                ],
              ),
            ),
            searchList()
          ],
        ),
      ),
    );
  }
}

getChatRoomId (String a, String b) {
  if (a.substring(0,1).codeUnitAt(0) > b.substring(0,1).codeUnitAt(0)) {
    return '$b\_$a';
  }
  else {
    return '$a\_$b';
  }
}