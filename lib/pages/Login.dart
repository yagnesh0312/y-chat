import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:quick_chat/model/db.dart';
import 'package:quick_chat/pages/signup.dart';
import 'indicator.dart';

import 'Home.dart';
import '../model/UserModel.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController cemail = new TextEditingController();
  TextEditingController cpassword = new TextEditingController();

  void toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void checkValues() {
    String email = cemail.text.trim();
    String password = cpassword.text.trim();

    if (email == "" || password == "") {
      toast("fill all the fields");
    } else {
      indicators.LoadingDialog(context, "Loading...");
      logIn(email, password);
    }
  }

  void logIn(String email, String password) async {
    UserCredential? credential;
    toast("login in....");

    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);
      toast(ex.code.toString());
    }

    if (credential != null) {
      String uid = credential.user!.uid;
      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection(DB.user).doc(uid).get();
      UserModel userModel =
          UserModel.fromMap(userData.data() as Map<String, dynamic>);
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return Home(userModel: userModel, fireuser: credential!.user!);
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height * 9.5 / 10,
          decoration: BoxDecoration(color: NeumorphicColors.background
              // image: DecorationImage(image: AssetImage("assets/background2.jpg"), fit: BoxFit.fitHeight),
              ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height / 8),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: NeumorphicText(
                      "Login",
                      textStyle: NeumorphicTextStyle(
                          fontSize: 50,

                          // color: Colors.black45,

                          fontWeight: FontWeight.w900),
                      style: NeumorphicStyle(color: NeumorphicColors.darkBackground),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: NeumorphicText(
                      "Welcome to Y-Chat",
                      textStyle: NeumorphicTextStyle(
                          fontSize: 30,

                          // color: Colors.black45,

                          fontWeight: FontWeight.w900),
                      style: NeumorphicStyle(color: NeumorphicColors.accent),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Neumorphic(
                    padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                    
                    style: NeumorphicStyle(
                      color: NeumorphicColors.background,
                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20))
                    ),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Neumorphic(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          style: NeumorphicStyle(
                              // border: NeumorphicBorder(
                              //     color: Colors.white, width: 2),
                              color: Colors.transparent,
                              shadowLightColorEmboss:
                                  NeumorphicColors.decorationMaxWhiteColor,
                              shadowDarkColorEmboss:
                                  NeumorphicColors.decorationMaxDarkColor,
                              depth: -5,
                              intensity: 0.5),
                          child: TextField(
                            controller: cemail,
                            style: TextStyle(color: NeumorphicColors.accent),
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "UserName",
                             ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Neumorphic(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          style: NeumorphicStyle(
                              // border: NeumorphicBorder(
                              //     color: Colors.white, width: 2),
                              color: Colors.transparent,
                              shadowLightColorEmboss:
                                  NeumorphicColors.decorationMaxWhiteColor,
                              shadowDarkColorEmboss:
                                  NeumorphicColors.decorationMaxDarkColor,
                              depth: -5,
                              intensity: 0.5),
                          child: TextField(
                            controller: cpassword,
                            style: TextStyle(color: NeumorphicColors.accent),
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Password",
                             ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                          onTap: () {},
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(color: Colors.white),
                          ))),
                  const SizedBox(
                    height: 20,
                  ),
                  NeumorphicButton(
                    style: NeumorphicStyle(
                        intensity: 1,
                        color: NeumorphicColors.accent,
                        shadowLightColor:
                            NeumorphicColors.decorationMaxWhiteColor),
                    child: const Text("Login",
                        style: TextStyle(
                            fontSize: 30,
                            color: NeumorphicColors.background,
                            fontWeight: FontWeight.w900)),
                    onPressed: () {
                    checkValues();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("haven't Account ? "),
          CupertinoButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => SignUp()));
              },
              child: Text("Sign Up",
                  style: TextStyle(
                      color: Colors.black54, fontWeight: FontWeight.bold)))
        ],
      ),
    );
  }
}
