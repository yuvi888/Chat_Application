import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:rocks/screens/chatscreen.dart';
import 'package:rocks/screens/homepage.dart';

import 'package:rocks/services/database.dart';

import 'chatscreen.dart';

import '../helperfunction/sharedpref_helper.dart';

class SearchScreen extends StatefulWidget {
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool isSearching = false;
  Stream? usersStream;

  String? myName, myProfilePic, myEmail;
  String? myUserName;
  TextEditingController searchUsernameEditingController =
      TextEditingController();

  getMyInfoFromSharedPreferences() async {
    myName = await SharedPreferenceHelper().getDispalyName();
    myProfilePic = await SharedPreferenceHelper().getUserProfileUrl();
    myUserName = await getuserName(myUserName);
    myEmail = await SharedPreferenceHelper().getUserEmail();
    setState(() {});
  }

  getChatRoomIdByUsernames(String a, String? b) {
    if ((a.substring(0, 1).codeUnitAt(0)) >
        ((b?.substring(0, 1).codeUnitAt(0)))!) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  onSearchButtonClick() async {
    isSearching = true;
    setState(() {});
    usersStream = await DatabaseMethods()
        .getUserByUserName(searchUsernameEditingController.text);

    setState(() {});
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

  searchListUserTile(String profileUrl, name, email, username) {
    return GestureDetector(
      onTap: () async {
        //print('this is the value that we have $myUserName $username');

        var chatRoomId =
            getChatRoomIdByUsernames(username, await getuserName(myUserName));

        Map<String, dynamic> chatRoomInfoMap = {
          "users": [myUserName, username]
        };

        DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(username, name, profileUrl)));
      },
      child: Container(
        height: 70,
        margin: EdgeInsets.only(bottom: 10, left: 10.0, right: 10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Color.fromARGB(88, 160, 156, 156),
        ),
        child: Row(
          children: [
            Container(
                height: 50,
                width: 45,
                margin: EdgeInsets.only(left: 10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7.0),
                  child: Image.network(
                    profileUrl,
                    fit: BoxFit.cover,
                  ),
                )),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    margin: EdgeInsets.only(top: 18, left: 10.0),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      name,
                      style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.bold),
                    )),
                Container(
                    margin: EdgeInsets.only(top: 5.0, left: 10.0),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      email,
                      style: TextStyle(color: Colors.white),
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget searchUserList() {
    return StreamBuilder(
      stream: usersStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? SizedBox(
                child: ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    return searchListUserTile(
                        ds["imgUrl"], ds["name"], ds["email"], ds["username"]);
                  },
                ),
              )
            : Container(
                margin: EdgeInsets.only(top: 20.0),
                child: CircularProgressIndicator(
                  color: Colors.lightBlue,
                ));
      },
    );
  }

  onScreenLoaded() async {
    await getMyInfoFromSharedPreferences();
  }

  @override
  initState() {
    onScreenLoaded();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0),
              padding: EdgeInsets.only(left: 20.0, right: 20.0),
              decoration: BoxDecoration(
                  color: Color.fromARGB(88, 160, 156, 156),
                  borderRadius: BorderRadius.circular(100.0)),
              child: Row(
                children: [
                  isSearching
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              isSearching = false;
                              searchUsernameEditingController.text = "";
                              setState(() {});
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.only(right: 10.0),
                            child: Icon(
                              Icons.arrow_back,
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                        )
                      : Container(),

                  ////////text field
                  Container(
                    child: Expanded(
                        child: TextField(
                      style: TextStyle(color: Colors.white),
                      cursorColor: Colors.lightBlue,
                      controller: searchUsernameEditingController,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "search any user",
                          hintStyle: TextStyle(color: Colors.white)),
                    )),
                  ),
                  GestureDetector(
                      onTap: () async {
                        if (searchUsernameEditingController.text != "" &&
                            searchUsernameEditingController.text !=
                                await getuserName(myUserName)) {
                          onSearchButtonClick();
                        } else {
                          Container(
                            child: Text('user does not exist '),
                          );
                        }
                      },
                      child: Icon(
                        Icons.search,
                        color: Colors.white,
                      ))
                ],
              ),
            ),
            isSearching
                ? searchUserList()
                : Container(
                    margin: EdgeInsets.only(top: 20.0),
                    child: CircularProgressIndicator(
                      color: Colors.lightBlue,
                    )),
          ],
        ),
      ),
    );
  }
}
