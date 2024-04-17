class msgModel {
  String? msgid;
  String? sender;
  String? text;
  bool? seen;
  DateTime? createdon;
  String? react;
  String? rplyUserId;
  String? rplyMsg;
  String? rplyType;
  String? type;

  msgModel(
      {this.msgid,
      this.sender,
      this.text,
      this.seen,
      this.createdon,
      this.react,
      this.type,
      this.rplyMsg,
      this.rplyType,
      this.rplyUserId});

  msgModel.fromMap(Map<String, dynamic> map) {
    msgid = map['msgid'];
    sender = map['sender'];
    text = map['text'];
    seen = map['seen'];
    createdon = map['createdon'].toDate();
    react = map['react'];
    rplyMsg = map['rplymsg'];
    rplyUserId = map['rplyuid'];
    rplyType = map['rplytype'];
    type = map['type'];
  }

  Map<String, dynamic> tomap() {
    return {
      'msgid': msgid,
      'sender': sender,
      'text': text,
      'seen': seen,
      'createdon': createdon,
      'react': react,
      'rplymsg': rplyMsg,
      'rplyuid': rplyUserId,
      'type': type,
      'rplytype': rplyType,
    };
  }
}
