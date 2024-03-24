class Group {
  final int id;
  final String name;
  final int creatorId;
  final int imageId;

  const Group({
    required this.id,
    required this.name,
    required this.creatorId,
    required this.imageId,
  });

  factory Group.fromJson(Map<String, dynamic> json) => Group(
    id: json["id"],
    name: json["name"],
    creatorId: json["creator_id"],
    imageId: json["image_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "creator_id": creatorId,
    "image_id": imageId,
    "group":0
  };
}