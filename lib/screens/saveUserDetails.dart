import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:rocks/helperfunction/sharedpref_helper.dart';

import 'package:rocks/services/database.dart';

import 'package:rocks/services/user_services.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'homepage.dart';

class SaveUserDetails extends StatefulWidget {
  const SaveUserDetails({super.key});

  @override
  State<SaveUserDetails> createState() => _SaveUserDetailsState();
}

class _SaveUserDetailsState extends State<SaveUserDetails> {
  TextEditingController usernameController = TextEditingController();
  final auth = FirebaseAuth.instance;
  String? checkUserName;
  String? imageUrl;

  // XFile? image;
  // String? filename;

  mapDataIntoDb() async {
    Map<String, dynamic> userInfoMap = {
      "username": usernameController.text,
      "name": auth.currentUser?.displayName,
      "email": auth.currentUser?.email,
      "imgUrl": imageUrl,
    };
    await DatabaseMethods().addUserInfoToDB(auth.currentUser?.uid, userInfoMap);
    await SharedPreferenceHelper().saveUserName(usernameController.text);
    await SharedPreferenceHelper()
        .saveDisplayName(auth.currentUser?.displayName);
    await SharedPreferenceHelper().saveUserEmail(auth.currentUser?.email);
    await SharedPreferenceHelper().saveUserId(auth.currentUser?.uid);
    await SharedPreferenceHelper().saveDisplayName(auth.currentUser?.photoURL);
  }

  Future<bool> checkUserNameMethod() async {
    QuerySnapshot querySnapshot =
        await DatabaseMethods().getUserInfo(usernameController.text);
    if (querySnapshot.docs.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  // uploadImage(String? ImageUrl) async {
  //   Reference ref = FirebaseStorage.instance.ref().child(filename!);
  //   UploadTask uploadTask = ref.putFile(File(image!.path));
  //   var downUrl = await (await uploadTask.whenComplete(() {
  //     ref.getDownloadURL();
  //   }).then((value) {
  //     return SubmitButton();
  //   }));

  //   var url = downUrl.toString();

  //   return ImageUrl = url;
  // }
  uploadImage() async {
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
        imageUrl = downloadUrl;
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
      body: Column(
        children: [
          Container(
              height: 170,
              width: 150,
              margin: EdgeInsets.only(top: 80),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                    color: Color.fromARGB(255, 255, 255, 255), width: 2.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: (imageUrl != null)
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        'https://static.toiimg.com/thumb/imgsize-123456,msid-90830889,width-200,resizemode-4/90830889.jpg',
                        fit: BoxFit.cover,
                      ),
              )),
          SizedBox(
            height: 20.0,
          ),
          Container(
            height: 50,
            width: 120,
            child: MaterialButton(
              child: Text("Upload",
                  style: TextStyle(
                      color: Colors.lightBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
              onPressed: () async {
                await uploadImage();
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                //  side: BorderSide(color: Color.fromARGB(255, 252, 255, 255))
              ),
              elevation: 5.0,
              color: Color.fromARGB(115, 48, 49, 49),
              textColor: Colors.amber,
              padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
              splashColor: Colors.lightBlue,
            ),
          ),
          Flexible(
            child: Container(
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
                    hintText: "Enter your username",
                    hintStyle: TextStyle(
                        color: Color.fromARGB(255, 227, 222, 222),
                        fontSize: 15)),
                controller: usernameController,
                // onChanged: (value) {
                //   //addMessage(false);
                // },
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 50.0),
            height: 45,
            width: 170,
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
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: MaterialButton(
              child: Text("Submit",
                  style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              onPressed: () async {
                if (await checkUserNameMethod() == true && imageUrl != null) {
                  mapDataIntoDb();
                } else {
                  showDialog(
                      context: context,
                      builder: (context) {
                        Future.delayed(Duration(seconds: 2), () {
                          Navigator.of(context).pop(true);
                        });
                        return AlertDialog(
                          title: Text(
                              'First upload photo and check your username',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 10)),
                        );
                      });
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 5.0,
              padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
              splashColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
