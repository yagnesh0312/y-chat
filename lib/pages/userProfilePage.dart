import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quick_chat/model/UserModel.dart';
import 'package:quick_chat/model/db.dart';
import 'package:quick_chat/pages/Home.dart';
import 'package:quick_chat/pages/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'indicator.dart';

class userProfilePage extends StatefulWidget {
  final UserModel userModel;
  final User FireUser;

  const userProfilePage(
      {Key? key, required this.userModel, required this.FireUser})
      : super(key: key);

  @override
  State<userProfilePage> createState() => _userProfilePageState();
}

class _userProfilePageState extends State<userProfilePage> {
  File? imgFile;
  String? fullname;
  TextEditingController cfullname = new TextEditingController();
  TextEditingController cphone = new TextEditingController();
  bool switchOn = false;
  Color Dcolor = NeumorphicColors.darkBackground;
  Color Dshadow = NeumorphicColors.darkDefaultBorder;
  Color Dtext = NeumorphicColors.decorationMaxWhiteColor;

  Color color = NeumorphicColors.background;
  Color shadow = NeumorphicColors.decorationMaxWhiteColor;
  Color text = NeumorphicColors.defaultTextColor;

  getSwitch() async {
    SharedPreferences prf = await SharedPreferences.getInstance();
    setState(() {
      switchOn = prf.getBool('mode')!;
    });
  }

  @override
  void initState() {
    // h implement initState
    super.initState();

    cfullname.text = widget.userModel.fullname ?? "";
    cphone.text = widget.userModel.phone ?? "";
    getSwitch();
  }

  void toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
    ));
  }

  saveMode() async {
    SharedPreferences prf = await SharedPreferences.getInstance();
    prf.setBool('mode', switchOn);
  }

  void selectImage(ImageSource source) async {
    XFile? picked = await ImagePicker().pickImage(source: source);

    if (picked != null) {
      cropImage(picked);
    }
  }

  void cropImage(XFile file) async {
    final CroppedFile? cropedfile = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 10);
    if (cropedfile != null) {
      setState(() {
        imgFile = File(cropedfile.path);
      });
    }
  }

  void checkValues() async {
    SharedPreferences prf = await SharedPreferences.getInstance();
    prf.setBool('mode', switchOn);
    log("$switchOn");

    fullname = cfullname.text.trim();
    if ((imgFile == null && widget.userModel.proPic == null) ||
        fullname == "") {
      toast("something missing..");
    } else if (imgFile != null) {
      indicators.LoadingDialog(context, "data Loading....");

      uploaddata();
    } else {
      widget.userModel.fullname = fullname;
      widget.userModel.phone = cphone.text;
      await FirebaseFirestore.instance
          .collection(DB.user)
          .doc(widget.userModel.uid)
          .set(widget.userModel.toMap())
          .then((value) => toast("Data Save..."));
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Home(
                  userModel: widget.userModel, fireuser: widget.FireUser)));
    }
  }

  void uploaddata() async {
    FirebaseStorage.instance
        .ref(DB.profilepic)
        .child(widget.userModel.uid!)
        .delete();
    UploadTask uploadTask = FirebaseStorage.instance
        .ref(DB.profilepic)
        .child(widget.userModel.uid.toString())
        .putFile(imgFile!);

    TaskSnapshot snapshot = await uploadTask;

    String imageurl = await snapshot.ref.getDownloadURL();

    widget.userModel.fullname = fullname;
    widget.userModel.phone = cphone.text;
    log("user phone number :${cphone.text}");
    widget.userModel.proPic = imageurl;
    await FirebaseFirestore.instance
        .collection(DB.user)
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap())
        .then((value) => toast("Data Save..."));
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                Home(userModel: widget.userModel, fireuser: widget.FireUser)));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void showPhotoOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: color,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              "Send Pic",
              style: TextStyle(color: text),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      selectImage(ImageSource.gallery);
                    },
                    icon: Icon(Icons.photo_library_outlined),
                    label: Text("From Gallery")),
                ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      selectImage(ImageSource.camera);
                    },
                    icon: Icon(Icons.photo_camera_rounded),
                    label: Text("From Camera")),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    String im = widget.userModel.proPic!;
    return Scaffold(
      backgroundColor: switchOn ? Dcolor : color,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 40,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      NeumorphicButton(
                        style: NeumorphicStyle(
                            intensity: 1,
                            color: switchOn ? Dcolor : color,
                            shadowLightColor: switchOn ? Dshadow : shadow),
                        onPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Home(
                                      userModel: widget.userModel,
                                      fireuser: widget.FireUser)));
                        },
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.teal,
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        "Profile Picture",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: switchOn ? Dtext : text),
                      ),
                    ],
                  ),
                  NeumorphicButton(
                    style: NeumorphicStyle(
                        intensity: 1,
                        color: switchOn ? Dcolor : color,
                        shadowLightColor: switchOn ? Dshadow : shadow),
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Login()));
                    },
                    child: const Icon(
                      Icons.logout,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            CupertinoButton(
              onPressed: () {
                showPhotoOptions();
              },
              child: Neumorphic(
                style: NeumorphicStyle(
                    color: switchOn ? Dcolor : color,
                    shadowLightColor: switchOn ? Dshadow : shadow,
                    depth: 5,
                    intensity: 1,
                    shape: NeumorphicShape.convex,
                    boxShape: NeumorphicBoxShape.circle()),
                child: Container(
                  alignment: Alignment.center,
                  child: CircleAvatar(
                    backgroundImage: imgFile != null
                        ? FileImage(imgFile!)
                        : im != ""
                            ? NetworkImage(im) as ImageProvider
                            : AssetImage("assets/profileImage.png"),
                    radius: 100,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: ListTile(
                title: Text(
                  "Email",
                  style: TextStyle(
                      color: switchOn ? Dtext : text,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  widget.userModel.email!,
                  style: TextStyle(color: switchOn ? Dtext : text),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Neumorphic(
                style: NeumorphicStyle(
                    color: switchOn ? Dcolor : color,
                    intensity: 1,
                    shadowLightColorEmboss: switchOn ? Dshadow : shadow,
                    depth: -5,
                    // shape: NeumorphicShape.concave,
                    boxShape: NeumorphicBoxShape.roundRect(
                        // BorderRadius.only(
                        //     topRight: Radius.circular(20),
                        //     topLeft: Radius.circular(20)),
                        BorderRadius.circular(20)),
                    lightSource: LightSource.topLeft),
                margin:
                    EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: TextField(
                  style:
                      TextStyle(fontSize: 20, color: switchOn ? Dtext : text),
                  controller: cfullname,
                  maxLines: null,
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.person_rounded,
                        color: NeumorphicColors.darkAccent,
                      ),
                      hintText: "FullName",
                      hintStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: switchOn
                              ? Dtext.withOpacity(0.5)
                              : text.withOpacity(0.5)),
                      border: InputBorder.none),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Neumorphic(
                style: NeumorphicStyle(
                    color: switchOn ? Dcolor : color,
                    intensity: 1,
                    shadowLightColorEmboss: switchOn ? Dshadow : shadow,
                    depth: -5,
                    // shape: NeumorphicShape.concave,
                    boxShape: NeumorphicBoxShape.roundRect(
                        // BorderRadius.only(
                        //     topRight: Radius.circular(20),
                        //     topLeft: Radius.circular(20)),
                        BorderRadius.circular(20)),
                    lightSource: LightSource.topLeft),
                margin:
                    EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: TextField(
                  style:
                      TextStyle(fontSize: 20, color: switchOn ? Dtext : text),
                  controller: cphone,
                  maxLines: null,
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.phone,
                        color: NeumorphicColors.darkAccent,
                      ),
                      hintText: "phoneNumber (optional)",
                      hintStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: switchOn
                              ? Dtext.withOpacity(0.5)
                              : text.withOpacity(0.5)),
                      border: InputBorder.none),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Divider(),
            Container(
              padding: EdgeInsets.only(right: 50, left: 50),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Dark Mode",
                    style: TextStyle(
                        color: switchOn ? Dtext : text,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                  NeumorphicSwitch(
                      style: NeumorphicSwitchStyle(
                          activeThumbColor: Dcolor,
                          disableDepth: switchOn ? true : false),
                      height: 30,
                      value: switchOn,
                      onChanged: (value) {
                        saveMode();
                        setState(() {
                          switchOn = value;
                        });
                      })
                ],
              ),
            ),
            Divider(),
            NeumorphicButton(
                style: NeumorphicStyle(
                  intensity: 1,
                  color: switchOn ? Dcolor : color,
                  shadowLightColor: switchOn ? Dshadow : shadow,
                ),
                onPressed: () {
                  checkValues();
                },
                child: Text(
                  "Save",
                  style: TextStyle(
                      color: NeumorphicColors.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                )),
            SizedBox(
              height: 50,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Made by ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: switchOn
                        ? Dtext.withOpacity(0.5)
                        : text.withOpacity(0.5),
                  ),
                ),
                Text(
                  "Yagensh",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: switchOn
                        ? Dtext.withOpacity(0.8)
                        : text.withOpacity(0.8),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
