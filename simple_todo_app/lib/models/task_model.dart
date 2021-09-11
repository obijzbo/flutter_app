class Task {
  late int id;
  late String title;
  late DateTime date;
  late String priority;
  int? status; // 0 - complete, 1- complete

  Task({required this.title, required this.date, required this.priority, this.status});
  Task.withId({required this.id, required this.title, required this.date, required this.priority, this.status});

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    map['id'] = id;
    map['title'] = title;
    map['date'] = date.toIso8601String();
    map['priority'] = priority;
    map['status'] = status;
    return map;
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task.withId(
        id: map['id'],
        title: map['title'],
        date: DateTime.parse(map['date']),
        priority: map['priority'],
        status: map['status']);
  }
}