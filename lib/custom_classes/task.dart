abstract class TaskStatus{
  static const uncompleted = 0;
  static const completed = 1;
}

class Task {
  int id;
  int dayFrom;
  int monthFrom;
  int yearFrom;
  int dayTo;
  int monthTo;
  int yearTo;
  int hourFrom;
  int minuteFrom;
  int hourTo;
  int minuteTo;
  String title;
  String description;
  int creatorId;
  int groupId;
  List<int> imagesId;
  int status;

  Task({
    required this.id,
    required this.dayFrom,
    required this.monthFrom,
    required this.yearFrom,
    required this.dayTo,
    required this.monthTo,
    required this.yearTo,
    required this.hourFrom,
    required this.minuteFrom,
    required this.hourTo,
    required this.minuteTo,
    required this.title,
    required this.description,
    required this.creatorId,
    required this.groupId,
    required this.imagesId,
    required this.status,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json["id"],
    dayFrom: json["day_from"],
    monthFrom: json["month_from"],
    yearFrom: json["year_from"],
    dayTo: json["day_to"],
    monthTo: json["month_to"],
    yearTo: json["year_to"],
    hourFrom: json["hour_from"],
    minuteFrom: json["minute_from"],
    hourTo: json["hour_to"],
    minuteTo: json["minute_to"],
    title: json["title"],
    description: json["description"],
    creatorId: json["creator_id"],
    groupId: json["group_id"],
    imagesId: List<int>.from(json["images_id"].map((x) => x)),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "day_from": dayFrom,
    "month_from": monthFrom,
    "year_from": yearFrom,
    "day_to": dayTo,
    "month_to": monthTo,
    "year_to": yearTo,
    "hour_from": hourFrom,
    "minute_from": minuteFrom,
    "hour_to": hourTo,
    "minute_to": minuteTo,
    "title": title,
    "description": description,
    "creator_id": creatorId,
    "group_id": groupId,
    "images_id": List<dynamic>.from(imagesId.map((x) => x)),
    "status": status,
  };
}