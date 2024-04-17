class ChatRoom {
  String? chatid;
  Map<String, dynamic>? participents;
  String? lastMsg;
  bool? typing;
  String? img;

  ChatRoom(
      {this.lastMsg, this.chatid, this.participents, this.typing, this.img});
  ChatRoom.fromMap(Map<String, dynamic> map) {
    chatid = map["chatid"];
    participents = map["participents"];
    lastMsg = map["lastmsg"];
    typing = map["typing"];
    img = map['img'];
  }

  Map<String, dynamic> toMap() {
    return {
      "chatid": chatid,
      "participents": participents,
      "lastmsg": lastMsg,
      "typing": typing,
      "img": img
    };
  }
}
