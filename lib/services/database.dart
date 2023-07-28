import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:rocks/helperfunction/sharedpref_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future addUserInfoToDB(
      String? userId, Map<String, dynamic> userInfoMap) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .set(userInfoMap);
  }

    Future updateprofileToDB(
      String? userId, updateimageurl) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .update({
          'imgUrl':updateimageurl,
        });
  }
    Future updateusernameToDB(
      String? userId, updateusername) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .update({
          'username':updateusername,
        });
  }

  Future<Stream<QuerySnapshot>> getUserByUserName(String username) async {
    return FirebaseFirestore.instance
        .collection('users')
        .where("username", isEqualTo: username)
        .snapshots();
  }

  Future addmessage(String chatRoomId, String messageId,
      Map<String, dynamic> messageInfoMap) {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .doc(messageId)
        .set(messageInfoMap);
  }

  updateLastMessageSend(
      String chatRoomId, Map<String, dynamic> lastMessageInfoMAp) {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .update(lastMessageInfoMAp);
  }

  createChatRoom(
      String chatRoomId, Map<String, dynamic> chatRoomInfoMap) async {
    final snapShot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .get();

    if (snapShot.exists) {
      return true;
    } else {
      return FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatRoomId)
          .set(chatRoomInfoMap);
    }
  }

  Future<Stream<QuerySnapshot>> getChatRoomMessages(chatRoomId) async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("ts", descending: true)
        .snapshots();
  }

  Future<String?> getuserName(String? username) async {
    final auth = FirebaseAuth.instance;

    return await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser?.uid)
        .get()
        .then((value) {
      return username = value.data()!['username'];
    });
  }

  // String getUserName(String username) {
  //   DocumentReference documentReference =
  //       FirebaseFirestore.instance.collection('chatrooms').doc();
  //   return username = documentReference.id;
  // }

  // Future<String> getChatRoomId(String chatRoomId) async {
  //   String? myUserName;
  //   await getuserName(myUserName);
  // }

  Future<Stream<QuerySnapshot>> getChatRooms(String? myUserName) async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .orderBy("lastMessageSendTs", descending: true)
        .where('users', arrayContains: myUserName)
        .snapshots();
  }

  Future<QuerySnapshot> getUserInfo(String username) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: username)
        .get();
  }
}
