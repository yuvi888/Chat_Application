import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rocks/helperfunction/sharedpref_helper.dart';
import 'package:rocks/screens/homepage.dart';
import 'package:rocks/screens/sign_in_page.dart';

import '../services/database.dart';
import '../services/user_services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController updateusernameController = TextEditingController();
  String? myusername;
  String? myprofileurl;
  String? myusname;

  String? updateimageUrl;

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

  getThisUserInfo() async {
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getUserInfo(await getuserName(myusername));
    // print("Something${querySnapshot.docs[0].id}");
    myusname = querySnapshot.docs[0]["username"];
    myprofileurl = querySnapshot.docs[0]["imgUrl"];
    setState(() {});
  }

  @override
  void initState() {
    getThisUserInfo();
    super.initState();
  }

  Future<bool> checkUserNameMethod() async {
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getUserInfo(updateusernameController.text);
    if (querySnapshot.docs.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  updateprofile() async {
    final auth = FirebaseAuth.instance;
    await DatabaseMethods()
        .updateprofileToDB(auth.currentUser?.uid, updateimageUrl);
    await SharedPreferenceHelper().saveUserProfileUrl(updateimageUrl);
  }

  updateusername() async {
    final auth = FirebaseAuth.instance;
    await DatabaseMethods().updateusernameToDB(
        auth.currentUser?.uid, updateusernameController.text);
    await SharedPreferenceHelper()
        .saveUserProfileUrl(updateusernameController.text);
  }

  updateImage() async {
    final _firebaseStorage = FirebaseStorage.instance;
    final _imagePicker = ImagePicker();
    XFile? image;
    showDialog(
      context: context,
      builder: (context) => Center(
        child: Container(
          height: 200,
          width: 250,
          color: Color.fromARGB(126, 65, 64, 64),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(child: CircularProgressIndicator(color: Colors.lightBlue)),
              SizedBox(
                height: 20,
              ),
              Center(
                child: Text(
                  'uploading.....',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    //Select Image
    image = await _imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 65);

    if (image != null) {
      var file = File(image.path);
      final path = 'files/${image.name}';
      //Upload to Firebase
      var snapshot = await _firebaseStorage.ref().child(path).putFile(file);
      var downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        updateimageUrl = downloadUrl;
      });
    } else {
      print('No Image Path Received');
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Center(
            child: Container(
                height: 170,
                width: 150,
                margin: EdgeInsets.only(top: 40),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                      color: Color.fromARGB(255, 255, 255, 255), width: 2.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: (myprofileurl != null)
                      ? (updateimageUrl != null)
                          ? Image.network(
                              updateimageUrl!,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              myprofileurl!,
                              fit: BoxFit.cover,
                            )
                      : Center(
                          child: CircularProgressIndicator(),
                        ),
                )),
          ),
          Flexible(
            child: Container(
              margin: EdgeInsets.only(top: 10.0),
              child: MaterialButton(
                onPressed: () async {
                  updateImage();
                },
                child: Text(
                  'change profile photo',
                  style: TextStyle(color: Colors.lightBlue),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: updateimageUrl != null
                ? MaterialButton(
                    onPressed: () async {
                      await updateprofile();
                      showDialog(
                          context: context,
                          builder: (context) {
                            Future.delayed(Duration(seconds: 2), () {
                              Navigator.of(context).pop(true);
                            });
                            return AlertDialog(
                              title: Text('success!',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 10)),
                            );
                          });
                    },
                    child: Text(
                      'upload',
                      style: TextStyle(color: Colors.lightBlue),
                    ),
                  )
                : Container(),
          ),
          Container(
            padding: EdgeInsets.only(left: 20.0, right: 10.0),
            margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 20),
            decoration: BoxDecoration(
                color: Color.fromARGB(88, 160, 156, 156),
                borderRadius: BorderRadius.circular(100.0)),
            child: TextField(
              style: TextStyle(color: Colors.white),
              cursorColor: Colors.lightBlue,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Enter username",
                  hintStyle: TextStyle(
                      color: Color.fromARGB(99, 227, 222, 222), fontSize: 15)),
              controller: updateusernameController,
              // onChanged: (value) {
              //   //addMessage(false);
              // },
            ),
          ),
          Flexible(
            child: Container(
              margin: EdgeInsets.only(top: 10.0),
              child: MaterialButton(
                onPressed: () async {
                  if (updateusernameController.text != null &&
                      await checkUserNameMethod() == true) {
                    await updateusername();
                    showDialog(
                        context: context,
                        builder: (context) {
                          Future.delayed(Duration(seconds: 1), () {
                            Navigator.of(context).pop(true);
                          });
                          return AlertDialog(
                            title: Text('success!',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontSize: 10)),
                          );
                        });
                  } else {
                    showDialog(
                        context: context,
                        builder: (context) {
                          Future.delayed(Duration(seconds: 1), () {
                            Navigator.of(context).pop(true);
                          });
                          return AlertDialog(
                            title: Text('check your username!',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontSize: 10)),
                          );
                        });
                  }
                },
                child: Text(
                  'update username',
                  style: TextStyle(color: Colors.lightBlue),
                ),
              ),
            ),
          ),
          Container(
            child: MaterialButton(
              minWidth: 200,
              child: Text("Log out",
                  style: TextStyle(
                      color: Colors.lightBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
              onPressed: () async {
                await UserServices().signOut();
                Navigator.pushReplacement(
                  // Use Navigator to push the SignInPage onto the stack
                  context,
                  MaterialPageRoute(builder: (context) => SignInPage()),
               );
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(color: Colors.lightBlue)),
              //elevation: 5.0,
              color: Color.fromARGB(172, 48, 49, 49),
              textColor: Colors.lightBlue,
              padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
              splashColor: Colors.lightBlue,
            ),
          )
        ],
      ),
    );
  }
}
