import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../model/ChatRoom.dart';
import 'indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageChet extends StatefulWidget {
  final ChatRoom chatRoom;

  const ImageChet({Key? key, required this.chatRoom}) : super(key: key);

  @override
  State<ImageChet> createState() => _ImageChetState();
}

class _ImageChetState extends State<ImageChet> {
  File? imgFile;

  void selectImage(ImageSource source) async {
    XFile? picked = await ImagePicker().pickImage(source: source);

    if (picked != null) {
      cropImage(picked);
      print("Image piced !!!");
    }
  }

  void cropImage(XFile file) async {
    final CroppedFile? cropedfile = await ImageCropper()
        .cropImage(sourcePath: file.path, compressQuality: 10);
    if (cropedfile != null) {
      setState(() {
        imgFile = File(cropedfile.path);
        print("Image Croped  !!!");
        checkValues();
      });
    }
  }

  void checkValues() async {
    if ((imgFile == null)) {
      print("imageFile is null");
    } else if (imgFile != null) {
      print("imageFile is not null success full !!!");

      uploaddata();
    } else {}
  }

  void uploaddata() async {
    FirebaseStorage.instance
        .ref('chats')
        .child(widget.chatRoom.chatid!)
        .delete();
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("chats")
        .child(widget.chatRoom.chatid!)
        .putFile(imgFile!);

    TaskSnapshot snapshot = await uploadTask;

    String imageurl = await snapshot.ref.getDownloadURL();
    print("image url : ${imageurl}");
    widget.chatRoom.img = imageurl;

    await FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(widget.chatRoom.chatid)
        .update(widget.chatRoom.toMap());
  }

  void showPhotoOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Upload profile pic"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.gallery);
                  },
                  leading: Icon(Icons.photo_library_outlined),
                  title: Text("From gallary"),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);

                    selectImage(ImageSource.camera);
                  },
                  leading: Icon(Icons.photo_camera_rounded),
                  title: Text("take a photo"),
                ),
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("image url : ${widget.chatRoom.img}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: MediaQuery.of(context).size.height * 0.1,
          title: Text("Image"),
          actions: [
            CupertinoButton(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    "Set Pic",
                    style: TextStyle(color: Colors.deepOrange),
                  ),
                ),
                onPressed: () {
                  showPhotoOptions();
                })
          ],
        ),
        body: Center(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('chatrooms')
                .where('chatid', isEqualTo: widget.chatRoom.chatid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                QuerySnapshot qs = snapshot.data as QuerySnapshot;
                if (qs.size > 0 &&
                    qs.docs[0]['img'] != "" &&
                    qs.docs[0]['img'] != null) {
                  return Image.network(qs.docs[0]['img']);
                }
              }
              return Text("Image uplode please!!");
            },
          ),
        ));
  }
}
