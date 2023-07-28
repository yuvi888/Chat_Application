import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rocks/screens/homepage.dart';
import 'package:rocks/screens/saveUserDetails.dart';
import 'package:rocks/screens/sign_in_page.dart';
import 'package:rocks/services/user_services.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: StreamBuilder(
          stream: UserServices.auth.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return UserServices().isUserExists();
            } else if (snapshot.data == null) {
              return SignInPage();
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        )
        // StreamBuilder(
        //   stream: UserServices.auth.authStateChanges(),
        //   builder: (context, snapshot) {
        //     if (snapshot.hasData) {
        //       if (snapshot.data == null) {
        //         return const SignInPage();
        //       } else {
        //         return UserServices().isUserExists();
        //       }
        //     }
        //     return Center(child: CircularProgressIndicator());
        //   },
        // )
        // FutureBuilder(
        //   future: UserServices().getCurrentUser(),
        //   builder: (context, AsyncSnapshot<dynamic> snapshot) {
        //     if (snapshot.hasData) {
        //       return HomePage();
        //     } else {
        //       return SignInPage();
        //     }
        //   },
        // ),
        );
  }
}
