import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:loading_indicator/loading_indicator.dart';

class indicators {
  static void LoadingDialog(BuildContext context, String title) {
    AlertDialog loading = AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), 
        backgroundColor: NeumorphicColors.background,
        content: Container(
          padding: EdgeInsets.all(30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 60,
                width: 60,
                child: Neumorphic(
                  padding: EdgeInsets.all(5),
                  style: NeumorphicStyle(boxShape: NeumorphicBoxShape.circle()),
                  child: LoadingIndicator(
                      indicatorType: Indicator.ballRotateChase,
                      colors: [
                        Colors.red,
                        Colors.yellow,
                        Colors.blueAccent,
                        Colors.teal,
                        Colors.purple
                      ]),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                width: 200,
                height: 50,
                child: NeumorphicText(
                  title,
                  textStyle: NeumorphicTextStyle(
                      fontWeight: FontWeight.bold, fontSize: 30),
                  style: NeumorphicStyle(
                      depth: 3, color: NeumorphicColors.accent, intensity: 1),
                ),
              )
            ],
          ),
        ));
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return loading;
        });
  }

  static void ImageDialog(BuildContext context, String user, String imageLink) {
    AlertDialog Imageshow = new AlertDialog(
      backgroundColor: NeumorphicColors.darkBackground,
      title: Text(
        user,
        style: TextStyle(color: Colors.white),
      ),
      contentTextStyle: TextStyle(color: Colors.blueAccent),
      content: Hero(
          tag: "3",
          child: Image.network(
            imageLink,
            fit: BoxFit.fill,
          )),
    );
    showDialog(context: context, builder: (context) => Imageshow);
  }
}
