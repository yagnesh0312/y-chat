import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quick_chat/model/db.dart';
import '../model/UserModel.dart';

class helper {
  static Future<UserModel?> getUserModelById(String uid) async {
    UserModel? usermodel;
    DocumentSnapshot docsnap =
        await FirebaseFirestore.instance.collection(DB.user).doc(uid).get();

    if (docsnap.data() != null) {
      usermodel = UserModel.fromMap(docsnap.data() as Map<String, dynamic>);
    }
    return usermodel;
  }
}
