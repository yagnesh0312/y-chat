import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:quick_chat/model/db.dart';
import 'package:quick_chat/pages/profile.dart';
import 'indicator.dart';
import '../model/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Login.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController cemail = new TextEditingController();
  TextEditingController cpass = new TextEditingController();
  TextEditingController ccpass = new TextEditingController();

  void toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void checkValue() {
    String email = cemail.text.trim();
    String pass = cpass.text.trim();
    String conPass = ccpass.text.trim();
    indicators.LoadingDialog(context, "Please wait few Minits");
    if (email.isEmpty || pass.isEmpty || conPass.isEmpty) {
      toast("Please fill all the fields");
      Navigator.pop(context);
    } else if (pass != conPass) {
      toast("please check your password");
      Navigator.pop(context);
    } else {
      signup(email, pass);
    }
  }

  void signup(String email, String pass) async {
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pass);
    } on FirebaseAuthException catch (e) {
      toast(e.code.toString());
    }
    if (credential != null) {
      String uid = credential.user!.uid;
      UserModel um = UserModel(
          uid: uid, email: email, fullname: "", proPic: "", pass: cpass.text);
      await FirebaseFirestore.instance
          .collection(DB.user)
          .doc(uid)
          .set(um.toMap())
          .then((value) {
        toast("Account created successfull");
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => profile(
                      userM: um,
                      firebaseUser: credential!.user!,
                    )));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height * 9.5 / 10,
            decoration: BoxDecoration(
                // image: DecorationImage(
                //     image: AssetImage("assets/background3.jpg"),
                //     fit: BoxFit.fitHeight),
                color: NeumorphicColors.background),
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: NeumorphicText(
                    "SignUp",
                    style: NeumorphicStyle(
                      color: NeumorphicColors.defaultTextColor,
                    ),
                    textStyle: NeumorphicTextStyle(
                        fontSize: 50, fontWeight: FontWeight.w900),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: NeumorphicText(
                    "Welcome to Y-Chat",
                    style: NeumorphicStyle(
                      color: NeumorphicColors.darkAccent,
                    ),
                    textStyle: NeumorphicTextStyle(
                        fontSize: 25, fontWeight: FontWeight.w900),
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                Neumorphic(
                  // height: 230,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                  // decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Color.fromARGB(142, 255, 255, 255), boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.black26,
                  //     spreadRadius: 2,
                  //     blurRadius: 5,
                  //     offset: Offset(2, 2), // changes position of shadow
                  //   ),
                  // ]),
                  style: NeumorphicStyle(
                    color: NeumorphicColors.background,
                  ),
                  child: Column(
                    children: [
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
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                            hintText: "Enter You Email",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.black45),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
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
                          controller: cpass,
                          obscureText: true,
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                            hintText: "Passowrd",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.black45),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
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
                          obscureText: true,
                          controller: ccpass,
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                            hintText: "Confirm Password",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.black45),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height:30),
                NeumorphicButton(
                    style: NeumorphicStyle(color: NeumorphicColors.darkAccent),
                    child: Text("SignUp",
                        style: TextStyle(
                            fontSize: 30,
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontWeight: FontWeight.bold)),
                    onPressed: () {
                      checkValue();
                    })
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Already have Account ? "),
          CupertinoButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => Login()));
              },
              child: Text("Login",
                  style: TextStyle(
                      color: Colors.black54, fontWeight: FontWeight.bold)))
        ],
      ),
    );
  }
}
