class SubjectModel {
  int id;
  String name;
  String color;

  SubjectModel({required this.id, required this.name, required this.color});

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] as int,
      name: json['name'] as String,
      color: json['color'] as String,
    );
  }
}
