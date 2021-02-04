import 'package:flutter/material.dart';
import 'package:commune/helper/constants.dart';
import 'package:commune/services/database.dart';
import 'package:commune/widgets/widget.dart';

class GroupConversationScreen extends StatefulWidget {
  @override
  _GroupConversationScreenState createState() => _GroupConversationScreenState();
}

class _GroupConversationScreenState extends State<GroupConversationScreen> {

  DataBaseMethods dataBaseMethods = new DataBaseMethods();
  TextEditingController messageController = new TextEditingController();

  Stream chatMessagesStream;

  Widget GroupChatMessageList() {
    return StreamBuilder(
      stream: chatMessagesStream,
      builder: (context, snapshot) {
        return snapshot.hasData ? ListView.builder(
          itemCount: snapshot.data.documents.length,
          itemBuilder: (context, index) {
            return GroupMessageTile(snapshot.data.documents[index].data()['message'],
                snapshot.data.documents[index].data()['sentBy'] == Constants.myName,
                snapshot.data.documents[index].data()['sentBy']
            );
          },
        ) : Container();
      },
    );
  }

  sendGroupMessage () {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        'message' : messageController.text,
        'sentBy' : Constants.myName,
        'time' : DateTime.now().millisecondsSinceEpoch
      };

      dataBaseMethods.addGroupConversationMessages(messageMap);
      messageController.text = '';
    }
  }

  void initState() {

    dataBaseMethods.getGroupConversationMessages().then((value)
    {
      setState(() {
        chatMessagesStream = value;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: Container(
        child: Stack(
          children: [
            GroupChatMessageList(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black12,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                          controller: messageController,
                          decoration: InputDecoration(
                            hintText: 'Type...',
                            hintStyle: TextStyle(
                                color: Colors.grey
                            ),
                            border: InputBorder.none,
                          ),
                        )
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        sendGroupMessage();
                      },
                    ),
                    //
                      // child: Container(
                      //   GestureDetector(
              //                     //   onTap: () {
              //                     //     sendGroupMessage();
              //                     //   },
              //                     //   child: IconButton(
              //                     //     icon: Icon(Icons.send),
              //                     //   ),decoration: BoxDecoration(
                      //     color: Colors.blueGrey,
                      //     borderRadius: BorderRadius.circular(40),
                      //   ),
                      //   padding: EdgeInsets.all(12),
                      //   child: Text('Send'),
                      // ),
                    // )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GroupMessageTile extends StatelessWidget {

  final String message;
  final bool isSentByMe;
  final String sentBy;
  GroupMessageTile(this.message, this.isSentByMe, this.sentBy);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      width: MediaQuery.of(context).size.width,
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
            color: isSentByMe ? Colors.blueAccent : Colors.grey,
            borderRadius: isSentByMe ? BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10)
            ) : BorderRadius.only (
                bottomRight: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10)
            )
        ),
        child: Column(
          children:[
            if (isSentByMe != true) ... {
              Text(
                '$sentBy',
                style: TextStyle(
                    fontSize: 13.5,
                    color: Colors.amberAccent
                ),
              )
            },
            Text(
              '$message',
              style: TextStyle(
                fontSize: 17,
              )
            )
          ]
        ),
      ),
    );
  }
}