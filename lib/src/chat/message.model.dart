class MessageModel {
  MessageModel({
    required this.message,
    required this.uid,
  });

  final String message;
  final String uid;

  factory MessageModel.fromJson(dynamic json) => MessageModel(
        message: json["message"],
        uid: json["uid"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "uid": uid,
      };
}
