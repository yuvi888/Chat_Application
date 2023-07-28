import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rocks/helperfunction/sharedpref_helper.dart';
import 'package:rocks/screens/profilescreen.dart';
import 'package:rocks/screens/searchscreen.dart';
import 'package:rocks/screens/sign_in_page.dart';

import 'package:rocks/services/database.dart';
import 'package:rocks/services/user_services.dart';

import 'chatscreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Stream? chatRoomsStream;
  String? myUserName;

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

  getChatRoooms() async {
    chatRoomsStream =
        await DatabaseMethods().getChatRooms(await getuserName(myUserName));
    myUserName = await SharedPreferenceHelper().getUserName();
    setState(() {});
  }

  @override
  initState() {
    getChatRoooms();
    super.initState();
  }

  chatRoomsList() {
    return StreamBuilder(
        stream: chatRoomsStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return snapshot.data.docs.length == 0
                ? Center(
                    child: Text(
                    ' Search Any User ',
                    style: TextStyle(color: Colors.white),
                  ))
                : ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      DocumentSnapshot ds = snapshot.data.docs[index];
                      // print(ds['users'][0]);
                      return ChatRoomListTile(ds["lastMessage"], ds.id);
                    },
                  );
          } else {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.lightBlue,
              ),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.topLeft,
          stops: [
            0.1,
            0.4,
            0.6,
            0.9,
          ],
          colors: [
            Colors.lightBlue.shade600,
            Colors.lightBlue,
            Colors.lightBlue.shade400,
            Colors.lightBlue.shade700,
          ],
        )),
        child: Column(
          children: [
            Container(
              height: 150,
              color: Colors.transparent,
              child: ShowDetailsTile(),
            ),
            Expanded(
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40.0),
                      topRight: Radius.circular(40.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(255, 31, 31, 31),
                        offset: Offset(5.0, 2.0),
                        blurRadius: 10.0,
                      ),
                    ],
                  ),
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TabBar(
                          indicatorColor: Colors.lightBlue.shade400,
                          labelColor: Colors.lightBlue.shade400,
                          unselectedLabelColor:
                              Color.fromARGB(255, 124, 122, 122),
                          tabs: [
                            Tab(
                              icon: Icon(
                                Icons.message_outlined,
                              ),
                            ),
                            Tab(
                                icon: Icon(
                              Icons.search,
                            )),
                          ],
                        ),
                        Expanded(
                          child: Container(
                            child: TabBarView(children: [
                              Container(
                                margin: EdgeInsets.only(
                                  left: 10,
                                  right: 10,
                                ),
                                child: chatRoomsList(),
                              ),
                              Container(
                                child: SearchScreen(),
                              ),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId;
  ChatRoomListTile(this.lastMessage, this.chatRoomId);

  @override
  State<ChatRoomListTile> createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicUrl = "", name = "", username = "";
  String? myusername;

  Future<String> getuserName(String? username) async {
    final auth = FirebaseAuth.instance;

    return await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser?.uid)
        .get()
        .then((value) {
      return username = value.data()!['username'];
    });
  }

  Future deleteData() async {
    await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(widget.chatRoomId)
        .delete();
  }

  showAlertDialog(BuildContext context) {
    Widget okButton = TextButton(
      child: const Text(
        "Ok",
        style: TextStyle(color: Colors.red),
      ),
      onPressed: () async {
        deleteData();
        Navigator.pop(context);
      },
    );

    Widget nopeButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Delete"),
      content: const Text("Are you sure you want to delete this user ? "),
      actions: [
        nopeButton,
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  getThisUserInfo() async {
    username = widget.chatRoomId
        .replaceAll(await getuserName(myusername), "")
        .replaceAll("_", "");
    QuerySnapshot querySnapshot = await DatabaseMethods().getUserInfo(username);
    // print("Something${querySnapshot.docs[0].id}");
    name = querySnapshot.docs[0]["name"];
    profilePicUrl = querySnapshot.docs[0]["imgUrl"];
    setState(() {});
  }

  @override
  void initState() {
    getThisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return profilePicUrl != ""
        ? GestureDetector(
            onTap: () async {
              await showDialog(
                  context: context,
                  builder: (context) =>
                      ChatScreen(username, name, profilePicUrl));
              Navigator.pop(context);

              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => HomePage()));
            },
            child: Container(
                height: 80,
                margin: EdgeInsets.only(bottom: 10, left: 5.0, right: 5.0),
                decoration: BoxDecoration(
                  //backgroundBlendMode: StretchMode.blurBackground,
                  borderRadius: BorderRadius.circular(10.0),
                  color: Color.fromARGB(88, 160, 156, 156),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Color.fromARGB(94, 0, 0, 0),
                  //     offset: Offset(1.0, 2.0),
                  //     blurRadius: 5.0,
                  //   )
                  // ]
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        child: Row(
                          children: [
                            Container(
                                height: 65,
                                width: 60,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Color.fromARGB(213, 246, 252, 255),
                                      width: 1.5),
                                  borderRadius: BorderRadius.circular(9.0),
                                ),
                                margin: EdgeInsets.only(left: 10.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(7.0),
                                  child: Image.network(
                                    profilePicUrl,
                                    fit: BoxFit.cover,
                                  ),
                                )),
                            Column(
                              //mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    margin:
                                        EdgeInsets.only(left: 10.0, top: 15),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '@ ' + username,
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 255, 255, 255),
                                          fontWeight: FontWeight.bold),
                                    )),
                                Container(
                                    width: 150,
                                    margin: EdgeInsets.only(
                                      top: 10.0,
                                      left: 14.0,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: Flexible(
                                      child: Text(widget.lastMessage,
                                          style: TextStyle(
                                              color: Colors.lightBlue),
                                          overflow: TextOverflow.ellipsis),
                                    )),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 60,
                      alignment: Alignment.centerLeft,
                      child: MaterialButton(
                        child: Icon(
                          Icons.delete,
                          color: Color.fromARGB(220, 255, 255, 255),
                        ),
                        onPressed: () {
                          showAlertDialog(context);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 5.0,
                        padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                        splashColor: Colors.red.shade700,
                      ),
                    ),
                  ],
                )))
        : Container();

    // ? Flexible(
    //     child: Container(
    //       height: 450,
    //       margin: EdgeInsets.only(bottom: 15, left: 10.0, right: 10.0),
    //       decoration: BoxDecoration(
    //         borderRadius: BorderRadius.circular(10.0),
    //         color: Color.fromARGB(115, 106, 106, 106),
    //       ),
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //         children: [
    //           Container(
    //             height: 70,
    //             decoration: BoxDecoration(
    //               borderRadius: BorderRadius.only(
    //                   topLeft: Radius.circular(10.0),
    //                   topRight: Radius.circular(10.0)),
    //               color: Colors.transparent,
    //             ),
    //             child: Row(
    //               // mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //               crossAxisAlignment: CrossAxisAlignment.center,
    //               children: [
    //                 Container(
    //                     height: 55,
    //                     width: 55,
    //                     margin: EdgeInsets.only(left: 10.0),
    //                     decoration: BoxDecoration(
    //                       borderRadius: BorderRadius.circular(100),
    //                       border:
    //                           Border.all(color: Colors.white, width: 1.5),
    //                       // boxShadow: [
    //                       //   BoxShadow(
    //                       //     color: Color.fromARGB(255, 48, 47, 47),
    //                       //     offset: Offset(1.0, 2.0),
    //                       //     spreadRadius: 1.0,
    //                       //     blurRadius: 5.0,
    //                       //   ),
    //                       // ]
    //                     ),
    //                     child: ClipRRect(
    //                       borderRadius: BorderRadius.circular(100),
    //                       child: Image.network(
    //                         profilePicUrl,
    //                         fit: BoxFit.cover,
    //                       ),
    //                     )),
    //                 Container(
    //                     margin: EdgeInsets.only(left: 10.0, right: 90.0),
    //                     alignment: Alignment.centerLeft,
    //                     child: Text(
    //                       name,
    //                       style: TextStyle(
    //                           color: Color.fromARGB(220, 255, 255, 255),
    //                           fontWeight: FontWeight.bold,
    //                           fontSize: 15),
    //                     )),
    //                 Container(
    //                   width: 60,
    //                   alignment: Alignment.centerLeft,
    //                   child: MaterialButton(
    //                     child: Icon(
    //                       Icons.delete,
    //                       color: Color.fromARGB(220, 255, 255, 255),
    //                     ),
    //                     onPressed: () {},
    //                     shape: RoundedRectangleBorder(
    //                       borderRadius: BorderRadius.circular(10.0),
    //                     ),
    //                     elevation: 5.0,
    //                     padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
    //                     splashColor: Colors.red.shade700,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //           Expanded(
    //             child: Container(
    //               color: Colors.transparent,
    //               width: double.infinity,
    //               child: ClipRRect(
    //                 child: Image.network(profilePicUrl, fit: BoxFit.cover),
    //               ),
    //             ),
    //           ),
    //           Container(
    //               height: 60,
    //               decoration: BoxDecoration(
    //                 borderRadius: BorderRadius.only(
    //                     bottomLeft: Radius.circular(10.0),
    //                     bottomRight: Radius.circular(10.0)),
    //                 color: Colors.transparent,
    //               ),
    //               child: Row(
    //                   //mainAxisAlignment: MainAxisAlignment.start,
    //                   crossAxisAlignment: CrossAxisAlignment.center,
    //                   children: [
    //                     Container(
    //                         margin: EdgeInsets.only(
    //                           left: 15.0,
    //                         ),
    //                         alignment: Alignment.centerLeft,
    //                         child: Text(
    //                           '@' + username,
    //                           style: TextStyle(
    //                               color: Color.fromARGB(220, 255, 255, 255),
    //                               fontSize: 15),
    //                         )),
    //                     Container(
    //                       alignment: Alignment.center,
    //                       margin: EdgeInsets.only(
    //                         left: 45.0,
    //                       ),
    //                       //   padding: EdgeInsets.only(bottom: 50.0),
    //                       child: MaterialButton(
    //                         child: Icon(
    //                           Icons.chat_outlined,
    //                           color: Colors.lightBlue,
    //                           size: 35.0,
    //                         ),
    //                         onPressed: () {
    //                           Navigator.push(
    //                               context,
    //                               MaterialPageRoute(
    //                                   builder: (context) => ChatScreen(
    //                                       username, name, profilePicUrl)));
    //                         },
    //                         shape: RoundedRectangleBorder(
    //                           borderRadius: BorderRadius.circular(10.0),
    //                         ),
    //                         elevation: 5.0,
    //                         padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
    //                         splashColor: Colors.lightBlue,
    //                       ),
    //                     ),
    //                   ])),
    //         ],
    //       ),
    //     ),
    //   )
    // : Container();
  }
}

class ShowDetailsTile extends StatefulWidget {
  const ShowDetailsTile({super.key});

  @override
  State<ShowDetailsTile> createState() => _ShowDetailsTileState();
}

class _ShowDetailsTileState extends State<ShowDetailsTile> {
  String myyProfilePicUrl = "", myyUserName = "";
  String? myusername;

Future<String> getuserName(String? username) async {
  final auth = FirebaseAuth.instance;

  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(auth.currentUser?.uid)
      .get();

  final data = snapshot.data();
  if (data != null && data.containsKey('username')) {
    return data['username'];
  } else {
    // Handle the case when 'username' is not found or data is null
    return ''; // Return a default value or handle the error as per your requirement.
  }
}

  getThisUserInfo() async {
    myusername = await getuserName(myusername);
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getUserInfo(myusername!);
    // print("Something${querySnapshot.docs[0].id}");
    myyUserName = querySnapshot.docs[0]["username"];
    myyProfilePicUrl = querySnapshot.docs[0]["imgUrl"];
    setState(() {});
  }

  @override
  void initState() {
    getThisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return myyProfilePicUrl != ""
        ? Container(
            margin: EdgeInsets.only(top: 50),
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: Row(
              children: [
                Container(
                    height: 75,
                    width: 75,
                    margin: EdgeInsets.only(left: 15.0),
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
                        myyProfilePicUrl,
                        fit: BoxFit.cover,
                      ),
                    )),
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 40, left: 10),
                      child: Text(
                        'Hello User,',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color.fromARGB(228, 0, 0, 0),
                          // shadows: [
                          //   Shadow(
                          //       color: Colors.black,
                          //       offset: Offset(0.2, 0.5),
                          //       blurRadius: 3.0)
                          // ]
                        ),
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(top: 2.0),
                        alignment: Alignment.center,
                        child: Text(
                          '@ ' + myyUserName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color.fromARGB(228, 0, 0, 0),
                            // shadows: [
                            //   Shadow(
                            //       color: Colors.black,
                            //       offset: Offset(0.5, 1.0),
                            //       blurRadius: 3.0)
                            // ]
                          ),
                        )),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(left: 110, top: 40),
                  child: Column(
                    children: [
                      Container(),
                      Container(
                        child: GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProfileScreen()))
                                .whenComplete(getThisUserInfo);
                          },
                          child: Icon(
                            Icons.person,
                            size: 30,
                            color: Color.fromARGB(204, 0, 0, 0),

                            // shadows: [
                            //   Shadow(
                            //       color: Colors.black,
                            //       offset: Offset(0.5, 1.0),
                            //       blurRadius: 8.0)
                            // ],
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(204, 0, 0, 0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ))
        : Container(
            child: Text('hello'),
          );
  }
}
