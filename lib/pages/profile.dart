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
import 'indicator.dart';

class profile extends StatefulWidget {
  final UserModel userM;
  final User firebaseUser;

  const profile({Key? key, required this.userM, required this.firebaseUser})
      : super(key: key);

  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
  File? imgFile;
  String? fullname;
  String? phone;
  TextEditingController cfullname = new TextEditingController();
  TextEditingController cPhone = new TextEditingController();

  void toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
    ));
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

  void checkValues() {
    fullname = cfullname.text.trim();
    phone = cPhone.text.trim();
    if (fullname == "") {
      toast("Please Enter Your Name");
    } else {
      indicators.LoadingDialog(context, "Profile Creating...");

      uploaddata();
      Navigator.pop(context);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Home(
                  userModel: widget.userM, fireuser: widget.firebaseUser)));
    }
  }

  void uploaddata() async {
    if (imgFile != null) {
      UploadTask uploadTask = FirebaseStorage.instance
          .ref(DB.profilepic)
          .child(widget.userM.uid.toString())
          .putFile(imgFile!);
      TaskSnapshot snapshot = await uploadTask;
      String imageurl = await snapshot.ref.getDownloadURL();
      widget.userM.proPic = imageurl;
    }

    widget.userM.fullname = fullname;
    widget.userM.onoff = "online";
    await FirebaseFirestore.instance
        .collection(DB.user)
        .doc(widget.userM.uid)
        .set(widget.userM.toMap())
        .then((value) => toast("profile created"));
  }

  void showPhotoOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: NeumorphicColors.background,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              "Uplode Profile",
              style: TextStyle(color: NeumorphicColors.darkBackground),
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
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Center(
            child: Text(
              "Profile Page",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  fontStyle: FontStyle.italic),
            ),
          )),
      body: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
              // image: DecorationImage(
              //     image: AssetImage("assets/background4.jpg"), fit: BoxFit.cover),
              color: NeumorphicColors.background),
          child: ListView(
            children: [
              SizedBox(
                height: 60,
              ),
              NeumorphicButton(
                padding: EdgeInsets.zero,
                style: NeumorphicStyle(
                    depth: -10,
                    intensity: 1,
                    shape: NeumorphicShape.concave,
                    boxShape: NeumorphicBoxShape.circle()),
                onPressed: () {
                  showPhotoOptions();
                },
                child: Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        image: DecorationImage(
                            image: imgFile != null
                                ? FileImage(imgFile!)
                                : AssetImage("assets/profileImage.png")
                                    as ImageProvider,
                            fit: BoxFit.fitHeight))),
                // child: CircleAvatar(
                //   backgroundImage: imgFile != null ? FileImage(imgFile!) : AssetImage("assets/profileImage.png") as ImageProvider,
                //   radius: 60,
                // ),
              ),
              SizedBox(height: 20),
              Neumorphic(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
                  controller: cfullname,
                  style: TextStyle(color: NeumorphicColors.accent),
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Full Name",
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Neumorphic(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
                  controller: cPhone,
                  style: TextStyle(color: NeumorphicColors.accent),
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Phone number",
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              NeumorphicButton(
                  child: Text("Submit",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 30,
                          color: NeumorphicColors.darkAccent,
                          fontWeight: FontWeight.bold)),
                  onPressed: () {
                    checkValues();
                  }),
            ],
          )),
    );
  }
}
