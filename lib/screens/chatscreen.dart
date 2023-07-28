import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:random_string/random_string.dart';
import 'package:rocks/helperfunction/sharedpref_helper.dart';
import 'package:rocks/screens/homepage.dart';
import 'package:rocks/screens/saveUserDetails.dart';

import '../services/database.dart';

class ChatScreen extends StatefulWidget {
  final String chatWithUsername, name, profileUrl;
  ChatScreen(this.chatWithUsername, this.name, this.profileUrl);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? chatRoomId, messageId = "";
  Stream? messageStream;

  String? myName, myProfilePic, myUserName, myEmail;
  TextEditingController messageTextEditingController = TextEditingController();

  getMyInfoFromSharedPreferences() async {
    myName = await SharedPreferenceHelper().getDispalyName();
    myProfilePic = await SharedPreferenceHelper().getUserProfileUrl();
    myUserName = await getuserName(myUserName);
    myEmail = await SharedPreferenceHelper().getUserEmail();

    chatRoomId = getChatRoomIdByUsernames(
        widget.chatWithUsername, await getuserName(myUserName));
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

  getChatRoomIdByUsernames(String a, String? b) {
    if (a.substring(0, 1).codeUnitAt(0) > (b?.substring(0, 1).codeUnitAt(0))!) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  addMessage(bool sendClicked) {
    if (messageTextEditingController.text != "") {
      String message = messageTextEditingController.text;

      var lastMessageTs = DateTime.now();

      Map<String, dynamic> messageInfoMap = {
        "message": message,
        "sendBy": myUserName,
        "ts": lastMessageTs,
        "imgUrl": myProfilePic,
      };

      if (messageId == "") {
        messageId = randomAlphaNumeric(12);
      }

      DatabaseMethods()
          .addmessage(chatRoomId!, messageId!, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSendTs": lastMessageTs,
          "lastMessageSendBy": myUserName,
        };

        DatabaseMethods()
            .updateLastMessageSend(chatRoomId!, lastMessageInfoMap);

        if (sendClicked) {
          /////remove the text in the message
          messageTextEditingController.text = "";

          //////////////make message id blanked
          messageId = "";
        }
      });
    }
  }

  Widget chatMessageTile(String message, bool sendByMe) {
    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
              decoration: BoxDecoration(
                  color: sendByMe
                      ? Colors.lightBlue
                      : Color.fromARGB(88, 160, 156, 156),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                    bottomLeft:
                        sendByMe ? Radius.circular(10.0) : Radius.circular(0),
                    bottomRight:
                        sendByMe ? Radius.circular(0) : Radius.circular(10.0),
                  )),
              margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
              padding: EdgeInsets.all(16),
              child: Text(
                message,
                style: TextStyle(color: sendByMe ? Colors.black : Colors.white),
              )),
        ),
      ],
    );
  }

  Widget chatMessages() {
    return StreamBuilder(
      stream: messageStream,
      builder: ((context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                padding: EdgeInsets.only(top: 10, bottom: 50),
                itemCount: snapshot.data.docs.length,
                reverse: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return chatMessageTile(
                      ds["message"], myUserName == ds["sendBy"]);
                },
              )
            : Center(
                child: CircularProgressIndicator(
                color: Colors.lightBlue,
              ));
      }),
    );
  }

  getAndSetMessages() async {
    messageStream = await DatabaseMethods().getChatRoomMessages(chatRoomId);
    setState(() {});
  }

  doThisOnLaunch() async {
    await getMyInfoFromSharedPreferences();
    getAndSetMessages();
  }

  @override
  void initState() {
    doThisOnLaunch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Color.fromARGB(225, 3, 168, 244),
        automaticallyImplyLeading: false,
        leading: BackButton(
          color: Colors.black,
        ),
        title: Container(
          // margin: EdgeInsets.only(left: 20.0),
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.only(),
                child: Container(
                    height: 60,
                    width: 60,
                    margin: EdgeInsets.only(right: 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                          color: Color.fromARGB(198, 52, 51, 51), width: 1.5),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Color.fromARGB(255, 48, 47, 47),
                      //     offset: Offset(1.0, 2.0),
                      //     spreadRadius: 1.0,
                      //     blurRadius: 5.0,
                      //   ),
                      // ]
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(
                        widget.profileUrl,
                        fit: BoxFit.cover,
                      ),
                    )),
              ),
              Text(
                widget.name,
                style: TextStyle(color: Colors.black, fontSize: 17),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        color: Color.fromARGB(184, 0, 0, 0),
        child: Stack(
          children: [
            chatMessages(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  margin: EdgeInsets.only(left: 5.0, right: 5.0, bottom: 10.0),
                  padding: EdgeInsets.only(left: 20.0, right: 10.0),
                  decoration: BoxDecoration(
                      color: Color.fromARGB(88, 160, 156, 156),
                      borderRadius: BorderRadius.circular(100.0)),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          style: TextStyle(color: Colors.white),
                          cursorColor: Colors.amber,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Type message",
                              hintStyle:
                                  TextStyle(color: Colors.white, fontSize: 15)),
                          controller: messageTextEditingController,
                          // onChanged: (value) {
                          //   //addMessage(false);
                          // },
                        ),
                      ),
                      GestureDetector(
                          onTap: () {
                            addMessage(true);
                          },
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                          )),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
