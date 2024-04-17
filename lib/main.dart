import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'pages/Home.dart';
import 'pages/Login.dart';
import 'model/UserModel.dart';
import 'model/dataGEt.dart';
import 'model/helper.dart';
import 'package:uuid/uuid.dart';
import 'package:workmanager/workmanager.dart';

User? currentUser;
String taskName = "MyNameIsYagnesh";

var uuid = const Uuid();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    UserModel? tum = await helper.getUserModelById(currentUser!.uid);
    if (tum != null) {
      runApp(LogedIn(userModel: tum, fireuser: currentUser!));
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const NeumorphicApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: NeumorphicThemeData(
        baseColor: Color(0xFFFFFFFF),
        lightSource: LightSource.topLeft,
        depth: 10,
      ),
      darkTheme: NeumorphicThemeData(
        baseColor: Color(0xFF3E3E3E),
        lightSource: LightSource.topLeft,
        depth: 6,
      ),
      home: MyHomePage(title: 'm chet'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<FirebaseApp> initFirebaseApp() async {
    FirebaseApp app = await Firebase.initializeApp();
    return app;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: initFirebaseApp(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Login();
            }
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.black,
              ),
            );
          }),
    );
  }
}

class LogedIn extends StatelessWidget {
  final UserModel userModel;
  final User fireuser;

  const LogedIn({Key? key, required this.userModel, required this.fireuser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      debugShowCheckedModeBanner: false,
      home: Home(userModel: userModel, fireuser: fireuser),
    );
  }
}
