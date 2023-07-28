import 'package:flutter/material.dart';

import '../services/user_services.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            //  MaterialButton
            // (
            //     onPressed: () => UserServices.signInWithGoogle()
            //     child: Text("Login"))

            Container(
              alignment: Alignment.center,
              child: MaterialButton(
                minWidth: 200,
                child: Text("Log In With Google",
                    style: TextStyle(
                        color: Colors.lightBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
                onPressed: () async {
                  UserServices().signInWithGoogle(context);
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
          ])),
    );
  }
}
