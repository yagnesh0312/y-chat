// ignore_for_file: sized_box_for_whitespace

import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quick_chat/model/db.dart';
import 'indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:emojis/emojis.dart' as ms; // to use Emoji utilities
import 'package:emojis/emoji.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'ImageSender.dart';
import '../main.dart';
import '../model/ChatRoom.dart';
import '../model/UserModel.dart';
import '../model/dataGEt.dart';
import '../model/emoji.dart';
import '../model/msgModel.dart';
import 'package:intl/intl.dart';
import '../model/notification.dart';
import 'profileImage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:uuid/uuid.dart';

// ignore: camel_case_types
class chat extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoom chatRoom;
  final UserModel userModel;
  final User fireuser;

  const chat(
      {Key? key,
      required this.targetUser,
      required this.chatRoom,
      required this.userModel,
      required this.fireuser})
      : super(key: key);

  @override
  _chatState createState() => _chatState();
}

// ignore: camel_case_types
class _chatState extends State<chat> with WidgetsBindingObserver {
  TextEditingController msgCont = TextEditingController();
  EmojiParser hello = EmojiParser();
  // ignore: non_constant_identifier_names
  String LastMassageId = "";
  String ts = "";
  int i = 0;
  // ignore: non_constant_identifier_names
  List emo = YaguEmoji().ya;
  FocusNode focusNode = FocusNode();
  var typing = false;
  bool Mode = false;
  Color color = NeumorphicColors.darkBackground;
  Color shadow = NeumorphicColors.darkDefaultBorder;
  Color text = NeumorphicColors.decorationMaxWhiteColor;
  File? imgFile;
  // ignore: deprecated_member_use
  final db = FirebaseDatabase.instance.reference();
  NotificationService ns = NotificationService();
  var radius = 20.0;
  var def = 3.0;
  Radius? tl;
  Radius? tr;
  Radius? br;
  Radius? bl;
  // String? ru = "";
  // String? rm = "";
  msgModel replyModel = msgModel();
  bool isReply = false;
  msgModel? msg;
  var tUserOnScreen = false;

  void toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
    ));
  }

  getMode() async {
    Map<String, dynamic> m = widget.chatRoom.toMap();
    m[widget.userModel.uid!] = "";
    m[widget.targetUser.uid!] = "";
    m["${widget.userModel.uid}os"] = true;
    FirebaseFirestore.instance
        .collection(DB.chatroom)
        .doc(widget.chatRoom.chatid!)
        .update(m);

    SharedPreferences prf = await SharedPreferences.getInstance();
    setState(() {
      Mode = prf.getBool('mode') ?? false;

      if (!Mode) {
        color = NeumorphicColors.background;
        shadow = NeumorphicColors.decorationMaxWhiteColor;
        text = NeumorphicColors.defaultTextColor;
      }
      // log("Get Mode : $Mode");
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    ns.initialize();
    getMode();
    // dataGet g = dataGet(widget.userModel.uid!);

    // g.getCalls();
    getLastMsg();
  }

  void sendMessege() async {
    String msg = msgCont.text.trim();

    LastMassageId = msg;
    msgCont.clear();
    if (msg != "") {
      msgModel newMsg = msgModel(
        msgid: uuid.v1(),
        sender: widget.userModel.uid,
        createdon: DateTime.now(),
        text: msg,
        seen: false,
      );
      if (isReply) {
        newMsg = msgModel(
            msgid: uuid.v1(),
            sender: widget.userModel.uid,
            createdon: DateTime.now(),
            text: msg,
            seen: false,
            rplyMsg: replyModel.text,
            rplyUserId: replyModel.sender,
            rplyType: replyModel.type);
        setState(() {
          replyModel = msgModel();
          isReply = false;
        });
      }
      // print(DateTime.now());
      FirebaseFirestore.instance
          .collection(DB.chatroom)
          .doc(widget.chatRoom.chatid)
          .collection("messages")
          .doc(newMsg.msgid)
          .set(newMsg.tomap());
      widget.chatRoom.lastMsg = msg;
      FirebaseFirestore.instance
          .collection(DB.chatroom)
          .doc(widget.chatRoom.chatid)
          .update(widget.chatRoom.toMap());

      Map<String, dynamic> m = widget.chatRoom.toMap();
      m[widget.userModel.uid!] = "";

      FirebaseFirestore.instance
          .collection(DB.chatroom)
          .doc(widget.chatRoom.chatid!)
          .update(m);
    }
  }

  bool isAllEmoji(String text) {
    var data = EmojiParser().unemojify(text).split(" ");
    if (data.length == 1) {
      for (int i = 0; i < data.length; i++) {
        if (data[i].startsWith(":") &&
            data[i].endsWith(":") &&
            ':'.allMatches(data[i]).length == 2) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  void dispose() async {
    super.dispose();
    WidgetsBinding.instance?.removeObserver(this);
    // print("chat disposee!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    //await FirebaseFirestore.instance.collection('chatrooms').doc(widget.chatRoom.chatid!).collection("messages").do
    var qs = await FirebaseFirestore.instance
        .collection(DB.chatroom)
        .doc(widget.chatRoom.chatid)
        .collection("messages")
        .orderBy("createdon", descending: true)
        .get();
    QuerySnapshot ds = qs;
    // log("qs Size : ${ds.size} last msg = ${ds.docs[0]['text']}");
    FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(widget.chatRoom.chatid!)
        .update(
            {widget.userModel.uid!: "", "${widget.userModel.uid}os": "false"});
    if (qs.size != 0) {
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString(widget.targetUser.uid!, ds.docs[0]['msgid']);
    }
  }

  getLastMsg() async {
    SharedPreferences prf = await SharedPreferences.getInstance();
    ts = prf.getString(widget.targetUser.uid!) ?? "";
    // print("dispose >>>>>>: ts == ${ts} == ${LastMassageId}");
  }

  String underScore(int num) {
    String under = "";
    for (int j = 0; j < num; j++) {
      under += "_";
    }
    return under;
  }

  Widget replyMsgWidget(msgModel m) {
    bool me = m.sender == widget.userModel.uid;
    Color light = me
        ? NeumorphicColors.embossWhiteColor(Colors.teal, intensity: 0.5)
        : NeumorphicColors.darkDefaultBorder;
    Color dark = me
        ? NeumorphicColors.embossWhiteColor(Colors.teal, intensity: 0.5)
        : NeumorphicColors.darkDefaultBorder;
    if (m.rplyType == 'img') {
      return replyCondintion(m)
          ? Neumorphic(
              style: NeumorphicStyle(
                  color: color.withOpacity(0.2),
                  depth: 10,
                  intensity: 1,
                  shadowLightColor: Mode ? dark : light),
              child: Container(
                padding: EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.rplyUserId == widget.userModel.uid
                          ? "You"
                          : "${widget.targetUser.fullname}",
                      style: TextStyle(
                          fontSize: 10,
                          color: Color.fromARGB(255, 180, 88, 39),
                          fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            constraints: BoxConstraints(maxHeight: 100),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                m.rplyMsg!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.fitWidth,
                              ),
                            )),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Photo",
                            style: TextStyle(color: text),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            )
          : SizedBox();
    }

    return replyCondintion(m)
        ? Neumorphic(
            margin: EdgeInsets.only(left: 0),
            style: NeumorphicStyle(
                color: color.withOpacity(0.2),
                depth: 6,
                intensity: 1,
                shadowLightColor: Mode ? dark : light),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.rplyUserId == widget.userModel.uid
                        ? "You"
                        : "${widget.targetUser.fullname}",
                    style: TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(255, 180, 88, 39),
                        fontWeight: FontWeight.bold),
                  ),
                  Container(
                    constraints: BoxConstraints(maxHeight: 100),
                    child: Text(
                      "${m.rplyMsg}",
                      style: TextStyle(
                        overflow: TextOverflow.fade,
                        fontSize: 14,
                        color: text.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : SizedBox();
  }

  String getReply(String msg) {
    int num = msg.lastIndexOf("_");
    if (num != -1) {
      String temp = msg.substring(num + 1);
      msg = temp;
      // log(temp);
    }
    return msg;
  }

  getEmoji(msgModel chet) {
    TextEditingController EmojiController = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: color,
            title: Text(
              "Chose Emoji",
              style: TextStyle(color: text),
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            content: SingleChildScrollView(
              child: Container(
                height: 500,
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 200,
                          height: 50,
                          child: TextField(
                            controller: EmojiController,
                            onChanged: (value) {
                              log(value);
                              if (!isAllEmoji(value)) {
                                EmojiController.clear();
                              }
                            },
                            decoration: InputDecoration(
                                hintText: "Enter Emoji",
                                hintStyle:
                                    TextStyle(color: text.withOpacity(0.5))),
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              if (EmojiController.text != "") {
                                chet.react = EmojiController.text.toString();
                                FirebaseFirestore.instance
                                    .collection('chatrooms')
                                    .doc(widget.chatRoom.chatid)
                                    .collection('messages')
                                    .doc(chet.msgid)
                                    .update(chet.tomap());
                                Navigator.pop(context);
                                Navigator.pop(context);
                              }
                            },
                            icon: Icon(
                              Icons.send,
                              color: Colors.green,
                            ))
                      ],
                    ),
                    Container(
                        height: 400,
                        width: 200,
                        child: GridView.builder(
                          itemCount: emo.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 4.0,
                                  mainAxisSpacing: 1),
                          itemBuilder: (BuildContext context, int index) {
                            return CupertinoButton(
                              minSize: 0,
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                chet.react = emo[index].toString();
                                FirebaseFirestore.instance
                                    .collection('chatrooms')
                                    .doc(widget.chatRoom.chatid)
                                    .collection('messages')
                                    .doc(chet.msgid)
                                    .update(chet.tomap());
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: Container(
                                height: 30,
                                child: Text(
                                  emo[index].toString(),
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            );
                          },
                        )),
                  ],
                ),
              ),
            ),
          );
        });
  }

  RemoveReaction(msgModel chet) {
    chet.react = "";
    FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(widget.chatRoom.chatid)
        .collection('messages')
        .doc(chet.msgid)
        .update(chet.tomap());
    Navigator.pop(context);
  }

  Widget onOffcolor(Color on, Color off) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(DB.chatroom)
          .where('chatid', isEqualTo: widget.chatRoom.chatid)
          .snapshots(),
      builder: (context, snap) {
        if (snap.hasData) {
          QuerySnapshot querySnapshot = snap.data as QuerySnapshot;
          // log("${querySnapshot.docs[0].data()} ${widget.targetUser.uid}os");
          Color clr = Colors.yellow;

          try {
            clr = querySnapshot.docs[0]["${widget.targetUser.uid}os"] == true
                ? on
                : off;
            tUserOnScreen =
                querySnapshot.docs[0]["${widget.targetUser.uid}os"] == true
                    ? true
                    : false;
          } catch (e) {
            // log("Error : $e");
          }

          return Container(
            padding: const EdgeInsets.all(2),
            height: 15,
            width: 15,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(100)),
            child: Container(
              decoration: BoxDecoration(
                  color: clr, borderRadius: BorderRadius.circular(100)),
            ),
          );
        }
        return SizedBox();
      },
    );
  }

  Widget Message(msgModel currentMsg) {
    // Type Image ->
    if (currentMsg.type == "img") {
      return Container(
        constraints: BoxConstraints(maxHeight: 300),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: (currentMsg.sender == widget.userModel.uid)
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            ts == currentMsg.msgid
                ? const Text(
                    "Last Message",
                    style: TextStyle(color: NeumorphicColors.variant),
                  )
                : const SizedBox(),
            tl == Radius.circular(radius) &&
                    currentMsg.sender == widget.targetUser.uid
                ? Text(
                    widget.targetUser.fullname!,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: NeumorphicColors.darkAccent),
                  )
                : const SizedBox(),
            tl == const Radius.circular(0)
                ? const SizedBox(
                    height: 5,
                  )
                : const SizedBox(),
            replyMsgWidget(currentMsg),
            ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  currentMsg.text!,
                  height: 250,
                )),
            SizedBox(
              height: 5,
            ),
            Text(
              "${DateFormat.jm().format(DateTime.parse(currentMsg.createdon.toString()))}  ",
              style: TextStyle(
                  color: (currentMsg.sender == widget.userModel.uid)
                      ? NeumorphicColors.embossMaxWhiteColor
                      : NeumorphicColors.darkVariant,
                  fontSize: 10),
              overflow: TextOverflow.fade,
            )
          ],
        ),
      );
    }
    // Type Text ->
    return Column(
      crossAxisAlignment: (currentMsg.sender == widget.userModel.uid)
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        ts == currentMsg.msgid
            ? const Text(
                "Last Message",
                style: TextStyle(color: NeumorphicColors.variant),
              )
            : const SizedBox(),
        tl == Radius.circular(radius) &&
                currentMsg.sender == widget.targetUser.uid
            ? Text(
                widget.targetUser.fullname!,
                textAlign: TextAlign.left,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: NeumorphicColors.darkAccent),
              )
            : const SizedBox(),
        tl == const Radius.circular(0)
            ? const SizedBox(
                height: 5,
              )
            : const SizedBox(),
        replyMsgWidget(currentMsg),
        replyCondintion(currentMsg) ? SizedBox(height: 10) : SizedBox(),
        // CMT: Message Text...
        SelectableText(
          currentMsg.text.toString(),
          style: TextStyle(
              color: (currentMsg.sender == widget.userModel.uid)
                  ? Colors.white.withOpacity(0.8)
                  : text,
              fontSize: isAllEmoji(currentMsg.text!.toString()) ? 40 : 16),
          // overflow: TextOverflow.fade,
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          // mainAxisAlignment: MainAxisAlignment.,
          children: [
            currentMsg.sender == widget.userModel.uid
                ? const SizedBox(
                    width: 5,
                  )
                : SizedBox(),
            // CMT: Message time...
            Text(
              DateFormat.jm()
                  .format(DateTime.parse(currentMsg.createdon.toString())),
              style: TextStyle(
                  color: (currentMsg.sender == widget.userModel.uid)
                      ? NeumorphicColors.embossMaxWhiteColor
                      : NeumorphicColors.darkVariant,
                  fontSize: 10),
              overflow: TextOverflow.fade,
            ),
          ],
        ),
      ],
    );
  }

  Widget EmojiOnChat(msgModel m) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
        child: Text(m.react!),
      ),
    );
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed ||
        state == AppLifecycleState.detached) {
      // log("chalu chet");
      FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(widget.chatRoom.chatid!)
          .update({"${widget.userModel.uid}os": true});
      widget.userModel.onoff = "online";
      FirebaseFirestore.instance
          .collection(DB.user)
          .doc(widget.userModel.uid)
          .update(widget.userModel.toMap());
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // log("bandh Chet");
      FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(widget.chatRoom.chatid!)
          .update({
        widget.userModel.uid!: "",
        "${widget.userModel.uid}os": "false"
      });
      widget.userModel.onoff = "offline";
      FirebaseFirestore.instance
          .collection(DB.user)
          .doc(widget.userModel.uid)
          .update(widget.userModel.toMap());
    }
  }

  UserOnline(Color on, Color off) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(DB.user)
            .where('uid', isEqualTo: widget.targetUser.uid)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasData) {
            QuerySnapshot qs = snap.data as QuerySnapshot;
            UserModel tr =
                UserModel.fromMap(qs.docs[0].data() as Map<String, dynamic>);
            // log("${tr.onoff}");
            Color clr = tr.onoff == "online" ? on : off;
            return Container(
              decoration: BoxDecoration(
                  color: clr, borderRadius: BorderRadius.circular(100)),
              padding: EdgeInsets.all(2),
              child: Hero(
                tag: "1",
                child: CircleAvatar(
                  backgroundImage: widget.targetUser.proPic != ""
                      ? NetworkImage(widget.targetUser.proPic!)
                      : AssetImage("assets/profileImage.png") as ImageProvider,
                ),
              ),
            );
          }
          return SizedBox();
        });
  }

  bool replyCondintion(msgModel m) {
    bool condition = (m.rplyMsg.toString().isNotEmpty &&
        m.rplyUserId.toString().isNotEmpty &&
        m.rplyMsg != null &&
        m.rplyUserId != null);
    // log("msg condition is ${m.rplyMsg} $condition");
    return condition;
  }

  void selectImage(ImageSource source) async {
    XFile? picked = await ImagePicker().pickImage(source: source);

    if (picked != null) {
      cropImage(picked);
    }
  }

  void showPhotoOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AlertDialog(
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
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
            ),
          );
        });
  }

  void cropImage(XFile file) async {
    final CroppedFile? cropedfile = await ImageCropper()
        .cropImage(sourcePath: file.path, compressQuality: 15);
    if (cropedfile != null) {
      setState(() {
        imgFile = File(cropedfile.path);
      });
      checkValues();
    }
  }

  void checkValues() async {
    if (imgFile == null) {
      toast("something missing..");
    } else if (imgFile != null) {
      // indicators.LoadingDialog(context, "data Loading....");
      toast("Data Uploading Start...");

      uploaddata();
    }
  }

  void uploaddata() async {
    // FirebaseStorage.instance.ref('data').child(Uuid().v1()).delete();
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("data")
        .child(Uuid().v1())
        .putFile(imgFile!);

    TaskSnapshot snapshot = await uploadTask;

    String imageurl = await snapshot.ref.getDownloadURL();
    msgModel newMsg = msgModel(
      msgid: uuid.v1(),
      sender: widget.userModel.uid,
      createdon: DateTime.now(),
      text: imageurl,
      type: "img",
      seen: false,
    );
    FirebaseFirestore.instance
        .collection(DB.chatroom)
        .doc(widget.chatRoom.chatid)
        .collection("messages")
        .doc(newMsg.msgid)
        .set(newMsg.tomap());
    widget.chatRoom.lastMsg = "📸 Photo";
    FirebaseFirestore.instance
        .collection(DB.chatroom)
        .doc(widget.chatRoom.chatid)
        .update(widget.chatRoom.toMap());
    // Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: CupertinoButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back),
        ),
        titleSpacing: 0,
        backgroundColor: color,
        title: SingleChildScrollView(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CupertinoButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => profileimage(
                                ImageUrl: widget.targetUser.proPic!,
                                t: "1",
                              )));
                },
                child: Container(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      // CMT: Targeted User Profile...
                      // Container(
                      //   decoration: BoxDecoration(
                      //       color: NeumorphicColors.darkAccent,
                      //       borderRadius: BorderRadius.circular(100)),
                      //   child: Hero(
                      //     tag: "1",
                      //     child: CircleAvatar(
                      //       backgroundImage: NetworkImage(widget.targetUser.proPic!),
                      //     ),
                      //   ),
                      // ),
                      UserOnline(Color.fromARGB(255, 0, 251, 8),
                          Color.fromARGB(255, 62, 62, 62)),
                      onOffcolor(Color.fromARGB(255, 0, 162, 255), Colors.grey)
                    ],
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: Text(
                          widget.targetUser.fullname!.toString().split(" ")[0],
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 20,
                              color: Colors.teal,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('chatrooms')
                              .where('chatid',
                                  isEqualTo: widget.chatRoom.chatid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              QuerySnapshot qs = snapshot.data as QuerySnapshot;
                              if (qs.docs.length != 0) {
                                return (qs.docs[0][widget.targetUser.uid!] !=
                                        "")
                                    ? Text(
                                        " is ${qs.docs[0][widget.targetUser.uid!]}",
                                        style: TextStyle(
                                            fontSize: 15, color: text),
                                      )
                                    : const SizedBox();
                              }
                            }
                            return const SizedBox();
                          }),
                    ],
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Text(
                      widget.targetUser.email!,
                      style: const TextStyle(
                          color: Colors.teal,
                          fontSize: 15,
                          fontWeight: FontWeight.w300),
                    ),
                  ),
                ],
              ),
              IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: AlertDialog(
                              content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CupertinoButton(
                                        color: Colors.red,
                                        child: Text(
                                          "Delete",
                                          style: TextStyle(color: color),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          FirebaseFirestore.instance
                                              .collection('chatrooms')
                                              .doc(widget.chatRoom.chatid)
                                              .delete();
                                        })
                                  ]),
                            ),
                          );
                        });
                  },
                  icon: Icon(
                    Icons.delete_rounded,
                    color: text,
                  ))
            ],
          ),
        ),
      ),
      body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: Mode
                    ? AssetImage("assets/chetbg1.jpg")
                    : AssetImage("assets/chetbg2.jpg"),
                fit: BoxFit.fill),
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection(DB.chatroom)
                        .doc(widget.chatRoom.chatid)
                        .collection("messages")
                        .orderBy("createdon", descending: true)
                        .snapshots(),
                    builder: (context, snapshots) {
                      if (snapshots.connectionState == ConnectionState.active) {
                        if (snapshots.hasData) {
                          QuerySnapshot datasnap =
                              snapshots.data as QuerySnapshot;
              
                          return Container(
                            decoration:
                                BoxDecoration(color: Colors.transparent),
                            padding: EdgeInsets.only(left: 5, right: 5),
                            child: ListView.builder(
                              reverse: true,
                              itemCount: datasnap.docs.length <= 50
                                  ? datasnap.size
                                  : 50,
                              itemBuilder: (context, index) {
                                msgModel currentMsg = msgModel.fromMap(
                                    datasnap.docs[index].data()
                                        as Map<String, dynamic>);
                                // CMT: item Build...
                                if (i == 0) {
                                  LastMassageId = currentMsg.msgid!;
                                }
                                i++;
              
                                tl = Radius.circular(def);
                                tr = Radius.circular(def);
                                br = Radius.circular(def);
                                bl = Radius.circular(def);
              
                                if (currentMsg.sender == widget.userModel.uid) {
                                  tl = Radius.circular(radius);
                                  bl = Radius.circular(radius);
                                  if ((datasnap.docs.length - 1 > index &&
                                          datasnap.docs[index + 1]['sender'] !=
                                              widget.userModel.uid) ||
                                      index == datasnap.size - 1) {
                                    tr = Radius.circular(radius);
                                  }
                                  if ((index != 0 &&
                                          datasnap.docs[index - 1]['sender'] !=
                                              widget.userModel.uid) ||
                                      index == 0) {
                                    br = Radius.circular(radius);
                                  }
                                }
                                if (currentMsg.sender ==
                                    widget.targetUser.uid) {
                                  tr = Radius.circular(radius);
                                  br = Radius.circular(radius);
                                  if ((datasnap.docs.length - 1 > index &&
                                          datasnap.docs[index + 1]['sender'] !=
                                              widget.targetUser.uid) ||
                                      index == datasnap.size - 1) {
                                    tl = Radius.circular(radius);
                                  }
                                  if ((index != 0 &&
                                          datasnap.docs[index - 1]['sender'] !=
                                              widget.targetUser.uid) ||
                                      index == 0) {
                                    bl = Radius.circular(radius);
                                  }
                                }
              
                                return SwipeTo(
                                  rightSwipeWidget: CircleAvatar(
                                    backgroundColor:
                                        Colors.black.withOpacity(0.4),
                                    child: Icon(
                                      Icons.reply_rounded,
                                      color: text,
                                    ),
                                  ),
                                  onRightSwipe: (d) {
                                    setState(() {
                                      focusNode.requestFocus();
                                      replyModel = currentMsg;
                                      isReply = true;
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.zero,
                                    child: Row(
                                      mainAxisAlignment: (currentMsg.sender ==
                                              widget.userModel.uid)
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          child: Container(
                                            alignment: (currentMsg.sender ==
                                                    widget.userModel.uid)
                                                ? Alignment.centerRight
                                                : Alignment.centerLeft,
                                            child: Stack(
                                              alignment: currentMsg.react !=
                                                          "" &&
                                                      currentMsg.react !=
                                                          null &&
                                                      currentMsg.sender ==
                                                          widget.userModel.uid
                                                  ? Alignment.bottomLeft
                                                  : Alignment.bottomRight,
                                              children: [
                                                GestureDetector(
                                                  onDoubleTap: () {
                                                    FirebaseFirestore.instance
                                                        .collection(DB.chatroom)
                                                        .doc(widget
                                                            .chatRoom.chatid)
                                                        .collection("messages")
                                                        .doc(datasnap
                                                            .docs[index].id)
                                                        .update({"react": "❤"});
                                                  },
                                                  onLongPress: () {
                                                    // CMT: show DialogBox Message Long Press
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return BackdropFilter(
                                                            filter: ImageFilter
                                                                .blur(
                                                                    sigmaX: 10,
                                                                    sigmaY: 10),
                                                            child: AlertDialog(
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              30)),
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              backgroundColor:
                                                                  color,
                                                              title: Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.2,
                                                                height: 50,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    currentMsg.sender ==
                                                                            widget.targetUser.uid
                                                                        ? Text(
                                                                            widget.targetUser.fullname!,
                                                                            style: TextStyle(
                                                                                color: NeumorphicColors.darkAccent,
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 15),
                                                                          )
                                                                        : Text(
                                                                            "You",
                                                                            style: TextStyle(
                                                                                color: NeumorphicColors.darkAccent,
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 15),
                                                                          ),
                                                                    Container(
                                                                      height:
                                                                          30,
                                                                      child:
                                                                          Text(
                                                                        "${currentMsg.text!}",
                                                                        overflow:
                                                                            TextOverflow.fade,
                                                                        style: TextStyle(
                                                                            color:
                                                                                text),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              content:
                                                                  Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                decoration: BoxDecoration(
                                                                    color:
                                                                        color,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20)),
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.59,
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    // Container(
                                                                    //   color:
                                                                    //       text,
                                                                    //   height:
                                                                    //       0.3,
                                                                    // ),
                                                                    ElevatedButton(
                                                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                                        child:
                                                                            Text(
                                                                          "Delete message",
                                                                          style:
                                                                              TextStyle(color: Colors.white),
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          if (currentMsg.sender ==
                                                                              widget.userModel.uid!) {
                                                                            FirebaseFirestore.instance.collection(DB.chatroom).doc(widget.chatRoom.chatid).collection("messages").doc(datasnap.docs[index].id).delete();
                                                                            Navigator.pop(context);
                                                                          } else {
                                                                            toast("Sorry Do not Have permission.");
                                                                            Navigator.pop(context);
                                                                          }
                                                                        }),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        ElevatedButton.icon(
                                                                            icon: Icon(Icons.copy),
                                                                            label: Text(
                                                                              "Copy",
                                                                              style: TextStyle(color: NeumorphicColors.accent),
                                                                            ),
                                                                            onPressed: () {
                                                                              Clipboard.setData(new ClipboardData(text: currentMsg.text!));
                                                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                                content: Text("Copied to Clipboard",style: TextStyle(color: NeumorphicColors.accent),),
                                                                                behavior: SnackBarBehavior.floating,
                                                                              ));
                                                                              Navigator.pop(context);
                                                                            }),
                                                                        SizedBox(
                                                                          width:
                                                                              20,
                                                                        ),
                                                                        ElevatedButton(
                                                                            child:
                                                                                Text(
                                                                              "❤ Like",
                                                                              style: TextStyle(color: NeumorphicColors.accent),
                                                                            ),
                                                                            onPressed:
                                                                                () {
                                                                              FirebaseFirestore.instance.collection(DB.chatroom).doc(widget.chatRoom.chatid).collection("messages").doc(datasnap.docs[index].id).update({
                                                                                "react": "❤"
                                                                              });
                                                                              Navigator.pop(context);
                                                                            }),
                                                                      ],
                                                                    ),
                                                                    ElevatedButton(
                                                                        child:
                                                                            Text(
                                                                          "Custom Reaction",
                                                                          style:
                                                                              TextStyle(color: NeumorphicColors.accent),
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          getEmoji(
                                                                              currentMsg);
                                                                        }),
                                                                    ElevatedButton(
                                                                        child:
                                                                            Text(
                                                                          "Remove Reaction",
                                                                          style:
                                                                              TextStyle(color: NeumorphicColors.accent),
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          RemoveReaction(
                                                                              currentMsg);
                                                                        })
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        });
                                                  },
                                                  onTap: () {
                                                    if (currentMsg.type ==
                                                        "img") {
                                                      log(currentMsg.text!);
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  profileimage(
                                                                      ImageUrl:
                                                                          currentMsg
                                                                              .text!,
                                                                      t: "2")));
                                                    }
                                                  },
                                                  child: Neumorphic(
                                                      style: NeumorphicStyle(
                                                          depth: 10,
                                                          border: currentMsg.sender !=
                                                                  widget
                                                                      .userModel
                                                                      .uid
                                                              ? NeumorphicBorder(
                                                                  color: Color.fromARGB(
                                                                      255, 0, 91, 82),
                                                                  width: 0.5)
                                                              : NeumorphicBorder
                                                                  .none(),
              
                                                          //Todo:Hllooooooooooooooooooooooo
                                                          color: (currentMsg.sender ==
                                                                  widget
                                                                      .userModel
                                                                      .uid)
                                                              ? Colors.teal[800]
                                                              : color,
                                                          shadowLightColor:
                                                              shadow,
                                                          shape: NeumorphicShape
                                                              .concave,
                                                          boxShape: NeumorphicBoxShape.roundRect(
                                                              BorderRadius.only(
                                                                  topLeft: tl!,
                                                                  topRight: tr!,
                                                                  bottomRight: br!,
                                                                  bottomLeft: bl!)),
                                                          intensity: 1,
                                                          lightSource: LightSource.topLeft),
                                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                                      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                                                      child: Message(currentMsg)),
                                                ),
                                                // CMT: User Reaction....
                                                currentMsg.react == null ||
                                                        currentMsg.react == ""
                                                    ? SizedBox()
                                                    : EmojiOnChat(currentMsg)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        } else if (snapshots.hasError) {
                          return const Center(
                            child: Text("Some thing error"),
                          );
                        } else {
                          return const Center(
                            child: Text("Say hey !"),
                          );
                        }
                      } else {
                        return Center(
                            child: Container(
                          height: 50,
                          width: 50,
                          child: const LoadingIndicator(
                            indicatorType: Indicator.ballPulseRise,
                            colors: [
                              Colors.redAccent,
                              Colors.yellowAccent,
                              Colors.blueAccent,
                              Colors.green
                            ],
                          ),
                        ));
                      }
                    },
                  ),
                ),
              ),
              Neumorphic(
                style: NeumorphicStyle(
                    color: color,
                    shadowLightColorEmboss:
                        NeumorphicColors.darkDefaultBorder,
                    depth: -5,
                    // shape: NeumorphicShape.concave,
                    border: NeumorphicBorder(color: Colors.teal, width: 0.3),
                    boxShape: NeumorphicBoxShape.roundRect(
                        // BorderRadius.only(
                        //     topRight: Radius.circular(20),
                        //     topLeft: Radius.circular(20)),
                        BorderRadius.circular(20)),
                    intensity: 1,
                    lightSource: LightSource.topLeft),
                margin: const EdgeInsets.only(
                    top: 10, left: 10, right: 10, bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width - 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          isReply
                              ? Neumorphic(
                                  style: NeumorphicStyle(
                                      color: color.withOpacity(0.2),
                                      depth: 6,
                                      intensity: 1,
                                      shadowLightColor:
                                          NeumorphicColors.darkDefaultBorder),
                                  child: Container(
                                    padding:
                                        EdgeInsets.only(left: 20, right: 10),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              replyModel.sender ==
                                                      widget.userModel.uid
                                                  ? "You"
                                                  : "${widget.targetUser.fullname}",
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: NeumorphicColors
                                                      .darkAccent
                                                      .withOpacity(0.7),
                                                  fontWeight:
                                                      FontWeight.bold),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  replyModel = msgModel();
                                                  isReply = false;
                                                  focusNode.nextFocus();
                                                });
                                              },
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                    top: 5, bottom: 5),
                                                child: Icon(
                                                  Icons.close_rounded,
                                                  size: 15,
                                                  color: text,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        replyModel.type == "img"
                                            ? Row(
                                                children: [
                                                  Container(
                                                      margin:
                                                          EdgeInsets.all(5),
                                                      child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10),
                                                          child:
                                                              Image.network(
                                                            replyModel.text!,
                                                            height: 50,
                                                            width: 50,
                                                            fit: BoxFit
                                                                .fitWidth,
                                                          ))),
                                                  Text(
                                                    "  Photo",
                                                    style: TextStyle(
                                                        color: text,
                                                        fontWeight:
                                                            FontWeight.w300),
                                                  )
                                                ],
                                              )
                                            : Container(
                                                padding: EdgeInsets.all(10),
                                                child: Text(
                                                  replyModel.text!,
                                                  style:
                                                      TextStyle(color: text),
                                                ),
                                              )
                                      ],
                                    ),
                                  ),
                                )
                              : SizedBox(),
                          TextField(
                            onChanged: (value) {
                              if (msgCont.text.isNotEmpty &&
                                  typing == false) {
                                FirebaseFirestore.instance
                                    .collection('chatrooms')
                                    .doc(widget.chatRoom.chatid!)
                                    .update(
                                        {widget.userModel.uid!: "typing..."});
                                typing = true;
                              } else {
                                FirebaseFirestore.instance
                                    .collection('chatrooms')
                                    .doc(widget.chatRoom.chatid!)
                                    .update({widget.userModel.uid!: ""});
                                typing = false;
                              }
                            },
                            focusNode: focusNode,
                            controller: msgCont,
                            maxLines: null,
                            style: const TextStyle(
                                color: NeumorphicColors.darkVariant,
                                fontSize: 20),
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                                prefixIcon: GestureDetector(
                                  child: const Icon(
                                    Icons.photo_library_outlined,
                                    color: NeumorphicColors.darkAccent,
                                  ),
                                  onLongPress: () {
                                    msgCont.clear();
                                  },
                                  onTap: () {
                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) => ImageChet(
                                    //               chatRoom: widget.chatRoom,
                                    //             )));
                                    showPhotoOptions();
                                  },
                                ),
                                hintText: "Massage",
                                hintStyle: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                    color: NeumorphicColors.darkVariant
                                        .withOpacity(0.5)),
                                border: InputBorder.none),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        sendMessege();
                        LastMassageId = msgCont.text;
                      },
                      icon: NeumorphicIcon(
                        Icons.send,
                        size: 30,
                        style: NeumorphicStyle(
                            shadowLightColor: shadow,
                            color: NeumorphicColors.darkAccent),
                      ),
                    )
                  ],
                ),
              )
            ],
          )),
    );
  }
}
