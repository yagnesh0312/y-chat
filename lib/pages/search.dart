import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:quick_chat/model/db.dart';
import 'chat.dart';
import '../main.dart';
import '../model/UserModel.dart';

import '../model/ChatRoom.dart';

class search extends StatefulWidget {
  final UserModel userModel;
  final User user;

  const search({Key? key, required this.userModel, required this.user})
      : super(key: key);

  @override
  _searchState createState() => _searchState();
}

class _searchState extends State<search> {
  TextEditingController EmailSearch = new TextEditingController();

  void toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<ChatRoom?> getchatroom(UserModel targetUser) async {
    ChatRoom? chatroom;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(DB.chatroom)
        .where("participents.${widget.userModel.uid}", isEqualTo: true)
        .where("participents.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.length > 0) {
      var docData = snapshot.docs[0].data();
      ChatRoom existingChatroom =
          ChatRoom.fromMap(docData as Map<String, dynamic>);

      chatroom = existingChatroom;
    } else {
      ChatRoom newChat =
          ChatRoom(chatid: uuid.v1(), lastMsg: "", participents: {
        widget.userModel.uid.toString(): true,
        targetUser.uid.toString(): true,
      });
      await FirebaseFirestore.instance
          .collection(DB.chatroom)
          .doc(newChat.chatid)
          .set(newChat.toMap());
      toast("new chatRoom created....");
      chatroom = newChat;
    }
    return chatroom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeumorphicColors.background,
      body: Container(
        padding: EdgeInsets.symmetric(
            horizontal: 5, vertical: MediaQuery.of(context).size.height * 0.07),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 3 / 4,
                  child: Neumorphic(
                    style: NeumorphicStyle(
                        shape: NeumorphicShape.flat,
                        depth: -5,
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(20))),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: EmailSearch,
                      decoration: InputDecoration(
                          hintText: "Search with email",
                          border: InputBorder.none),
                    ),
                  ),
                ),
                NeumorphicButton(
                    style:
                        NeumorphicStyle(boxShape: NeumorphicBoxShape.circle()),
                    child: Icon(Icons.search),
                    onPressed: () {
                      setState(() {});
                    })
              ],
            ),
            SizedBox(
              height: 10,
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection(DB.user)
                  .where("email", isNotEqualTo: widget.userModel.email)
                  .where("email", isEqualTo: EmailSearch.text)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot datasnap = snapshot.data as QuerySnapshot;
                    if (datasnap.docs.length > 0) {
                      Map<String, dynamic> userMap =
                          datasnap.docs[0].data() as Map<String, dynamic>;
                      UserModel searchModel = UserModel.fromMap(userMap);
                      return Container(
                        child: ListTile(
                          onTap: () async {
                            ChatRoom? chatroomM =
                                await getchatroom(searchModel);
                            if (chatroomM != null) {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => chat(
                                            targetUser: searchModel,
                                            fireuser: widget.user,
                                            userModel: widget.userModel,
                                            chatRoom: chatroomM,
                                          )));
                            }
                          },
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(searchModel.proPic!),
                          ),
                          title: Text(searchModel.fullname!),
                          subtitle: Text(searchModel.email!),
                          trailing: Icon(Icons.subdirectory_arrow_right),
                        ),
                      );
                    } else {
                      return Text(
                        "No found",
                        style: TextStyle(color: NeumorphicColors.darkVariant),
                      );
                    }
                  } else if (snapshot.hasError) {
                    return Text("Some thing Error");
                  } else {
                    return Text("No found");
                  }
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
