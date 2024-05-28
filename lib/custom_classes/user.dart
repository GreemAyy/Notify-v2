
class User {
  int id;
  String name;
  List<int> images;

  User({
    required this.id,
    required this.name,
    required this.images
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    images: List<int>.from(json["images"])
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "images":List<dynamic>.from(images.map((x) => x))
  };
}
