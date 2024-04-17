import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:photo_view/photo_view.dart';

class profileimage extends StatelessWidget {
  final String ImageUrl;
  final String t;

  const profileimage({Key? key, required this.ImageUrl, required this.t}) : super(key: key);
  click(BuildContext context) {
    File f = File(ImageUrl);
    log(ImageUrl);
    GallerySaver.saveImage("$ImageUrl.jpg", albumName: "MChet");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Saved Image"),
      behavior: SnackBarBehavior.floating,
    ));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image"),
        actions: [
          Container(
              margin: EdgeInsets.all(5),
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[800]),
                  onPressed: () {
                    click(context);
                  },
                  icon: Icon(Icons.save),
                  label: Text("Save main data")))
        ],
      ),
      body: Center(
        child: Hero(tag: t, child:PhotoView(
          imageProvider: NetworkImage(ImageUrl),
        )),
      ),
    );
  }
}
