import 'dart:developer';
import 'package:quick_chat/model/db.dart';

import '../main.dart';
import '../model/ChatRoom.dart';
import '../model/UserModel.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../model/msgModel.dart';

class chatroom extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  final ChatRoom chatRoomModel;
  final UserModel targetUser;

  const chatroom(
      {Key? key,
      required this.userModel,
      required this.firebaseUser,
      required this.targetUser,
      required this.chatRoomModel})
      : super(key: key);

  @override
  State<chatroom> createState() => _chatroomState();
}

class _chatroomState extends State<chatroom> {
  TextEditingController messageController = TextEditingController();

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();

    if (msg != "") {
      // Send Message
      msgModel newMessage = msgModel(
          msgid: uuid.v1(),
          sender: widget.userModel.uid,
          createdon: DateTime.now(),
          text: msg,
          seen: false);

      FirebaseFirestore.instance
          .collection(DB.chatroom)
          .doc(widget.chatRoomModel.chatid)
          .collection("messages")
          .doc(newMessage.msgid)
          .set(newMessage.tomap());
      widget.chatRoomModel.lastMsg = msg;
      log("Message Sent!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage:
                  NetworkImage(widget.targetUser.proPic.toString()),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              widget.targetUser.fullname.toString(),
            )
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Expanded(
                  child: Container(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection(DB.chatroom)
                        .doc(widget.chatRoomModel.chatid)
                        .collection("messages").orderBy('createdon')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasData) {
                          QuerySnapshot datasnapshot =
                              snapshot.data as QuerySnapshot;
                          // log(widget.chatRoomModel.chatroomid.toString());
                          return ListView.builder(
                            itemCount: datasnapshot.docs.length,
                            itemBuilder: (context, index) {
                              msgModel correntmsg = msgModel.fromMap(
                                  datasnapshot.docs[index].data()
                                      as Map<String, dynamic>);
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: correntmsg.sender==widget.userModel.uid?MainAxisAlignment.end:MainAxisAlignment.start,
                                children: [
                                  Container(
                                decoration: BoxDecoration(color: Colors.blue),
                                padding: EdgeInsets.all(5),
                                margin: EdgeInsets.only(top: 10),

                                    child: Text(
                                      correntmsg.text.toString(),
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 20),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text("chakc internet connection"),
                          );
                        } else {
                          return Center(
                            child: Text("Say hii to new freind"),
                          );
                        }
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    }),
              )),
              Container(
                color: Colors.grey[200],
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Row(
                  children: [
                    Flexible(
                        child: TextField(
                      maxLines: null,
                      controller: messageController,
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: "Enter message"),
                    )),
                    IconButton(
                        onPressed: () {
                          sendMessage();
                        },
                        icon: Icon(Icons.send))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
