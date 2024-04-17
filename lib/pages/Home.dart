import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:quick_chat/model/db.dart';

import 'chatroompage.dart';
import '../main.dart';
import '../model/dataGEt.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'Login.dart';
import 'chat.dart';
import '../model/ChatRoom.dart';
import '../model/UserModel.dart';
import '../model/helper.dart';
import '../model/notification.dart';
import 'profileImage.dart';
import 'search.dart';
import 'searchTest.dart';
import 'userProfilePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'indicator.dart';
import 'package:reflex/reflex.dart';

class Home extends StatefulWidget {
  final UserModel userModel;
  final User fireuser;

  const Home({Key? key, required this.userModel, required this.fireuser}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  StreamSubscription<ReflexEvent>? _subscription;

  bool Mode = true;

  // TODO: Light Mode Theme
  Color color = NeumorphicColors.background;
  Color shadow = Colors.white;
  Color text = NeumorphicColors.defaultTextColor;
  Color sText = NeumorphicColors.darkVariant;

  // TODO: Dark Mode Theme
  Color Dcolor = NeumorphicColors.darkBackground;
  Color Dshadow = NeumorphicColors.darkDefaultBorder;
  Color Dtext = NeumorphicColors.darkDefaultTextColor;
  Color DsText = NeumorphicColors.darkVariant;
  late SharedPreferences sp;
  NotificationService n = NotificationService();
  bool ActiveConnection = false;
  getMode() async {
    sp = await SharedPreferences.getInstance();
    SharedPreferences prf = await SharedPreferences.getInstance();
    FirebaseFirestore.instance.collection(DB.user).doc(widget.userModel.uid).update({
      'onoff': "online"
    });
    setState(() {
      Mode = prf.getBool('mode')!;
    });
    // log("getMode                    >> $Mode");
  }

  Future CheckUserConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // log('connected');
      }
    } on SocketException catch (_) {
      // log('not connected');
    }
  }

  @override
  void initState() {
    // CMT: implement initState
    super.initState();
    getMode();
    n.initialize();
    // log("Home inits>>>>>");
    WidgetsBinding.instance?.addObserver(this);
    if (widget.userModel.uid != null) {
      // dataGet g = dataGet(widget.userModel.uid!);
      // g.getPermission();
      // g.startListening();
      // g.getCalls();
      CheckUserConnection();
    } else {
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    WidgetsBinding.instance?.removeObserver(this);
    FirebaseFirestore.instance.collection(DB.user).doc(widget.userModel.uid).update({
      'onoff': "offline"
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    if (state == AppLifecycleState.resumed || state == AppLifecycleState.detached) {
      // log("chalu Home");
      widget.userModel.onoff = "online";
      FirebaseFirestore.instance.collection(DB.user).doc(widget.userModel.uid).update(widget.userModel.toMap());
    }
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // log("bandh Home");

      widget.userModel.onoff = "offline";
      FirebaseFirestore.instance.collection(DB.user).doc(widget.userModel.uid).update(widget.userModel.toMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Mode ? Dcolor : color,
      body: Stack(
        children: [
          // CMT: header Icon name and menu
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 12, left: 30),
            alignment: Alignment.topLeft,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Mode ? Dcolor : color,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Neumorphic(
                      style: NeumorphicStyle(intensity: 1, shadowLightColor: Mode ? Dshadow : shadow, color: Mode ? Dcolor : color, depth: 10, shape: NeumorphicShape.convex, boxShape: const NeumorphicBoxShape.circle()),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: widget.userModel.proPic != ""
                              ? NetworkImage(
                                  widget.userModel.proPic!,
                                )
                              : AssetImage("assets/profileImage.png") as ImageProvider,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        NeumorphicText(
                          "Y - Chat",
                          textStyle: NeumorphicTextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                          style: NeumorphicStyle(shadowLightColor: Mode ? Dshadow : shadow, intensity: 1, border: const NeumorphicBorder(isEnabled: true, color: Colors.black, width: 1), color: const Color.fromARGB(255, 0, 157, 255)),
                        ),
                        Container(
                          width: 150,
                          child: Text(
                            widget.userModel.fullname!.toUpperCase(),
                            style: TextStyle(
                              fontSize: 15,
                              color: NeumorphicColors.accent.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    CupertinoButton(
                      onPressed: () {
                        // print("=>");
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => userProfilePage(
                                      userModel: widget.userModel,
                                      FireUser: widget.fireuser,
                                    )));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 20),
                        child: Column(
                          children: [
                            NeumorphicIcon(
                              Icons.menu,
                              size: 25,
                              style: NeumorphicStyle(shadowLightColor: Mode ? Dshadow : shadow, intensity: 1, depth: 4, color: Colors.redAccent),
                            ),
                            const Text(
                              "Menu",
                              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Neumorphic(
            style: NeumorphicStyle(
              border: NeumorphicBorder(color: NeumorphicColors.darkVariant,width: 0.3),
                depth: 10,

                shadowLightColor: Mode ? Dshadow : shadow,
                color: Mode ? Dcolor : color,
                // shape: NeumorphicShape.concave,
                boxShape: NeumorphicBoxShape.roundRect(
                  const BorderRadius.only(topRight: Radius.circular(50), topLeft: Radius.circular(50)),
                ),
                intensity: 1,
                lightSource: LightSource.topLeft),
            margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 2 / 10),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection(DB.chatroom).where("participents.${widget.userModel.uid}", isEqualTo: true).snapshots(),
              builder: (context, snapshots) {
                if (snapshots.connectionState == ConnectionState.active) {
                  if (snapshots.hasData) {
                    QuerySnapshot chatsnap = snapshots.data as QuerySnapshot;
                    // CMT: ListView Builder
                    return ListView.builder(
                      itemCount: chatsnap.docs.length,
                      itemBuilder: (context, index) {
                        ChatRoom chatroomModel = ChatRoom.fromMap(chatsnap.docs[index].data() as Map<String, dynamic>);
                        Map<String, dynamic> partic = chatroomModel.participents!;
                        List<String> partKey = partic.keys.toList();
                        partKey.remove(widget.userModel.uid);
                        return FutureBuilder(
                          future: helper.getUserModelById(partKey[0]),
                          builder: (context, udata) {
                            if (udata.connectionState == ConnectionState.done) {
                              
                              if (udata.data != null) {

                                UserModel targetUser = udata.data as UserModel;
                        
                                return NeumorphicButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    // Navigator.push(context, MaterialPageRoute(builder: (context) => chatroom(targetUser: targetUser, chatRoomModel: chatroomModel, userModel: widget.userModel, firebaseUser: widget.fireuser)));
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => chat(targetUser: targetUser, chatRoom: chatroomModel, userModel: widget.userModel, fireuser: widget.fireuser)));
                                  },
                                  margin: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                                  style: NeumorphicStyle(color: Mode ? Dcolor : color, shadowLightColor: Mode ? Dshadow : shadow, shape: NeumorphicShape.convex, boxShape: NeumorphicBoxShape.roundRect(
                                      // BorderRadius.only(
                                      //     topRight: Radius.circular(20),
                                      //     topLeft: Radius.circular(20)),
                                      BorderRadius.circular(20)), intensity: 1, lightSource: LightSource.topLeft),
                                  child: Container(
                                    height: 70,
                                    child: ListTile(
                                      leading: CupertinoButton(
                                        padding: EdgeInsets.all(0),
                                        onPressed: () {
                                          indicators.ImageDialog(context, targetUser.fullname!, targetUser.proPic!);
                                        },
                                        // CMT: Main Tile...
                                        child: Container(
                                          height: 50,
                                          width: 50,
                                          child: Neumorphic(
                                            padding: EdgeInsets.all(2),
                                            style: NeumorphicStyle(color: targetUser.onoff == "online" ? Color.fromARGB(255, 0, 251, 8) : Colors.grey, shadowLightColor: Mode ? Dshadow : shadow, depth: -10, shape: NeumorphicShape.convex, boxShape: NeumorphicBoxShape.circle()),
                                            child: CircleAvatar(
                                              radius: 25,
                                              backgroundImage: targetUser.proPic != "" ? NetworkImage(targetUser.proPic.toString()) : AssetImage("assets/profileImage.png") as ImageProvider,
                                            ),
                                          ),
                                        ),
                                      ),
                                      title: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            targetUser.fullname.toString(),
                                            style: TextStyle(color: Mode ? Dtext : text, fontWeight: FontWeight.bold),
                                          ),
                                          StreamBuilder(
                                              stream: FirebaseFirestore.instance.collection('chatrooms').where('chatid', isEqualTo: chatsnap.docs[index]['chatid']).snapshots(),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  QuerySnapshot qs = snapshot.data as QuerySnapshot;
                                                  if (qs.docs[0][targetUser.uid!] != "") {
                                                    return Text(
                                                      " is ${qs.docs[0][targetUser.uid!]}",
                                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 82, 197, 86)),
                                                    );
                                                  }
                                                }
                                                return SizedBox();
                                              }),
                                        ],
                                      ),
                                      subtitle: Container(
                                        height: 70 - 30,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                                width: 190,
                                                child: chatroomModel.lastMsg == null || chatroomModel.lastMsg == ""
                                                    ? Text(
                                                        "Say Hey ! New Friend",
                                                        style: TextStyle(overflow: TextOverflow.fade, color: Colors.blue, fontWeight: FontWeight.bold),
                                                      )
                                                    : Text(
                                                        chatroomModel.lastMsg!,
                                                        style: TextStyle(overflow: TextOverflow.fade, color: Mode ? DsText : sText),
                                                      )),
                                            StreamBuilder(
                                                stream: FirebaseFirestore.instance.collection('chatrooms').doc(chatroomModel.chatid).collection('messages').orderBy('createdon', descending: true).snapshots(),
                                                builder: (context, snap) {
                                                  if (snap.hasData) {
                                                    QuerySnapshot dds = snap.data as QuerySnapshot;
                                                    String lastMsgID = sp.getString(targetUser.uid!) ?? "";

                                                    // CMT: New Message Notify

                                                    if (dds.size != 0 && dds.docs[0]['msgid'] != lastMsgID) {
                                                      try {
                                                    //  log("${chatsnap.docs[index]["${targetUser.uid!}os"]}");
                                                        if (chatsnap.docs[index]["${widget.userModel.uid!}os"] =="false") {
                                                      //  log("hello");
                                                        // n.instantNofitication(dds.size, targetUser.fullname!, dds.docs[0]['text']);
                                                      }
                                                      } catch (e) {
                                                      //  log("Notification error");
                                                      }
                                                      
                                                      return const Text(
                                                        "New",
                                                        style: TextStyle(fontWeight: FontWeight.bold, color: NeumorphicColors.darkAccent),
                                                      );
                                                    }
                                                  }
                                                  return SizedBox();
                                                })
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                               log("${chatsnap.docs[index]['chatid'] }");
                                return Center(
                                  
                                );
                              }
                            } else {
                              return SizedBox();
                            }
                          },
                        );
                      },
                    );
                  } else if (snapshots.hasError) {
                    return Center(
                      child: Text(snapshots.error.toString()),
                    );
                  } else {
                    return Center(
                      child: Text("No Chats"),
                    );
                  }
                } else {
                  return Center(
                    child: Text(""),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: NeumorphicFloatingActionButton(
        tooltip: "Add new Friends",
        mini: false,
        style: NeumorphicStyle(color: Mode ? Dcolor : color, shadowLightColor: Mode ? Dshadow : shadow, intensity: 1, depth: 10, shape: NeumorphicShape.convex, boxShape: NeumorphicBoxShape.circle()),
        child: Container(
          child: Icon(
            Icons.search_rounded,
            color: NeumorphicColors.darkAccent,
          ),
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => search(userModel: widget.userModel, user: widget.fireuser)));
        },
      ),
    );
  }
}
