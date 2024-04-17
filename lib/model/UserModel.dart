class UserModel {
  String? uid;
  String? fullname;
  String? email;
  String? proPic;
  String? pass;
  String? phone;
  String? onoff;

  UserModel({this.uid, this.onoff, this.phone, this.fullname, this.email, this.proPic, this.pass});
  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map["uid"];
    fullname = map["fullname"];
    email = map["email"];
    proPic = map["proPic"];
    pass = map['pass'];
    phone = map['phone'];
    onoff = map['onoff'];
  }
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "fullname": fullname,
      "email": email,
      "proPic": proPic,
      'pass': pass,
      'phone': phone,
      'onoff': onoff
    };
  }
}
