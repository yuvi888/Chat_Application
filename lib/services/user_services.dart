import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rocks/helperfunction/sharedpref_helper.dart';
import 'package:rocks/screens/homepage.dart';
import 'package:rocks/screens/saveUserDetails.dart';
import 'package:rocks/screens/searchscreen.dart';
import 'package:rocks/services/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/sign_in_page.dart';

class UserServices {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  getCurrentUser() async {
    return await auth.currentUser;
  }

  // signInWithGoogle(BuildContext context) async {
  //   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  //   final GoogleSignIn _googleSignIn = GoogleSignIn();

  //   final GoogleSignInAccount? googleSignInAccount =
  //       await _googleSignIn.signIn();

  //   final GoogleSignInAuthentication? googleSignInAuthentication =
  //       await googleSignInAccount?.authentication;

  //   final AuthCredential credential = GoogleAuthProvider.credential(
  //       idToken: googleSignInAuthentication?.idToken,
  //       accessToken: googleSignInAuthentication?.accessToken);

  //   UserCredential result =
  //       await _firebaseAuth.signInWithCredential(credential);
  //   User? userDetails = result.user;

  //   if (result != null) {
  //     SharedPreferenceHelper().saveUserEmail(userDetails?.email);
  //     SharedPreferenceHelper().saveUserId(userDetails?.uid);
  //     SharedPreferenceHelper().saveUserName('yuvraj');
  //     SharedPreferenceHelper().saveDisplayName(userDetails?.displayName);
  //     SharedPreferenceHelper().saveUserProfileUrl(userDetails?.photoURL);

  //     Map<String, dynamic> userInfoMap = {
  //       "email": userDetails?.email,
  //       "username": userDetails?.email?.replaceAll("@gmail.com", ""),
  //       "name": userDetails?.displayName,
  //       "imgUrl": userDetails?.photoURL,
  //     };
  //     DatabaseMethods()
  //         .addUserInfoToDB(userDetails?.uid, userInfoMap)
  //         .then((value) {
  //       Navigator.pushReplacement(context,
  //           MaterialPageRoute(builder: (context) => HomePage()));
  //     });
  //   }
  // }

  Future signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    await auth.signOut();
  }

  //////// handle auth state //////o
  // handleAuthState() {
  //   return StreamBuilder(
  //       stream: FirebaseAuth.instance.authStateChanges(),
  //       builder: (BuildContext context, snapshot) {
  //         if (snapshot.hasData) {
  //           return Text('Home Screen');
  //         } else {
  //           return const SignInPage();
  //         }
  //       });
  // }
////////// Sign in method //////////////

  signInWithGoogle(BuildContext context) async {
    final GoogleSignInAccount? googleUser =
        await GoogleSignIn(scopes: <String>["email"]).signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
   

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  // static Future<void> saveUserDetails(String username, Uint8List image) async {
  //   final auth = FirebaseAuth.instance;
  //   try {
  //     //dynamic time = DateTime.now();
  //     await FirebaseFirestore.instance
  //         .collection("users")
  //         .doc(auth.currentUser!.uid)
  //         .set({
  //       "username": username,
  //       "image": image,
  //       //"createdTimestamp":time
  //     });
  //   } catch (err) {
  //     print(err);
  //   }
  // }

  isUserExists() {
    final auth = FirebaseAuth.instance;

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(auth.currentUser?.uid)
            .snapshots()
            .map((event) => event.exists),
        builder: (BuildContext context, snapshot) {
          if (snapshot.data == true) {
            return HomePage();
          } else if (snapshot.data == false) {
            return SaveUserDetails();
          } else {
            return  Center(child: CircularProgressIndicator());
          }
        });
  }

//   pickImage(ImageSource source) async {
//     final ImagePicker _imagePicker = ImagePicker();

//     XFile? _file = await _imagePicker.pickImage(source: source);

//     if (_file != null) {
//       return await _file.readAsBytes();
//     }
//     print('No image select');
//   }
}
