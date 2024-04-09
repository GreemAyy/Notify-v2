class Message {
  int id;
  int creatorId;
  int groupId;
  String text;
  List<MessageMedia> media;
  int replyTo;
  String createAt;

  Message({
    required this.id,
    required this.creatorId,
    required this.groupId,
    required this.text,
    required this.media,
    required this.replyTo,
    required this.createAt
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json["id"],
    creatorId: json["creator_id"],
    groupId: json["group_id"],
    text: json["text"],
    media: List<MessageMedia>.from(json["media"].map((x) => MessageMedia.fromJson(x))),
    replyTo: json["reply_to"],
    createAt: json["create_at"]
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "creator_id": creatorId,
    "group_id": groupId,
    "text": text,
    "media": List<dynamic>.from(media.map((x) => x.toJson())),
    "reply_to": replyTo,
    "create_at":createAt
  };
}

class MessageMediaDataType{
  MessageMediaDataType(String this.value);
  String? value;

  static var photo = MessageMediaDataType('photo');
  static var task = MessageMediaDataType('task');
  static var file = MessageMediaDataType('file');
}

class MessageMedia {
  MessageMediaDataType type;
  int id;

  MessageMedia({
    required this.type,
    required this.id,
  });

  factory MessageMedia.fromJson(Map<String, dynamic> json) => MessageMedia(
    type: MessageMediaDataType(json["type"]),
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "type": type.value!,
    "id": id,
  };

  @override
  bool operator == (Object other) {
    return type.value == other;
  }
}

var mockMessages = [
  Message(
      id: 1,
      creatorId: 1,
      groupId: 6,
      text: 'Hello',
      media: [
        MessageMedia(type: MessageMediaDataType.photo, id: 105),
        MessageMedia(type: MessageMediaDataType.photo, id: 107),
        MessageMedia(type: MessageMediaDataType.photo, id: 92)
      ],
      replyTo: 0,
      createAt: "15:23-31/03/2024"
  ),
  Message(
      id: 2,
      creatorId: 2,
      groupId: 6,
      text: 'Hello 2',
      media: [
        MessageMedia(type: MessageMediaDataType.task, id: 98),
        MessageMedia(type: MessageMediaDataType.task, id: 92),
        MessageMedia(type: MessageMediaDataType.photo, id: 92)
      ],
      replyTo: 0,
      createAt: "17:23-31/03/2024"
  ),
  Message(
      id: 3,
      creatorId: 1,
      groupId: 6,
      text: 'Hello 3',
      media: [MessageMedia(type: MessageMediaDataType.photo, id: 104)],
      replyTo: 0,
      createAt: "16:00-01/04/2024"
  )
];
