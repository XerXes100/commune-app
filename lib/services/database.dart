import 'package:cloud_firestore/cloud_firestore.dart';

class DataBaseMethods {

  getUserByUsername (String username) async {
    return await  FirebaseFirestore.instance.collection('users')
        .where('name', isEqualTo: username).get();
  }

  getUserByUserEmail (String userEmail) async {
    return await FirebaseFirestore.instance.collection('users')
        .where('email', isEqualTo: userEmail).get();
  }

  uploadUserInfo (userMap) {
    FirebaseFirestore.instance.collection('users').add(userMap);
  }

  addUserToGroup (String username) {
    FirebaseFirestore.instance.collection('GroupChatRoom').doc('all_users')
        .update({"users": FieldValue.arrayUnion([username])});
  }

  createChatRoom (String chatRoomId, chatRoomMap) {
    FirebaseFirestore.instance.collection('ChatRoom')
        .doc(chatRoomId).set(chatRoomMap).catchError((e){
          print(e.toString());
    });
  }

  getConversationMessages (String chatRoomId) async {
    return await FirebaseFirestore.instance.collection('ChatRoom').doc(chatRoomId)
        .collection('chats')
    .orderBy('time')
        .snapshots();
  }

  getGroupConversationMessages () async {
    return await FirebaseFirestore.instance.collection('GroupChatRoom').doc(
        'all_users')
        .collection('groupChats')
        .orderBy('time')
        .snapshots();
  }

  addConversationMessages (String chatRoomId, messageMap) {
    FirebaseFirestore.instance.collection('ChatRoom').doc(chatRoomId).collection('chats')
        .add(messageMap).catchError((e){print(e.toString());});
  }

  addGroupConversationMessages (messageMap) {
    FirebaseFirestore.instance.collection('GroupChatRoom').doc('all_users').collection('groupChats')
        .add(messageMap).catchError((e){print(e.toString());});
  }

  getChatRooms (String username) async {
    return await FirebaseFirestore.instance.collection('ChatRoom')
        .where('users', arrayContains: username).snapshots();
  }

}