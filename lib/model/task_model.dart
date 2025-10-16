class TaskModel {
  int id;
  String title;
  int subject;
  String dueDate;
  String status;
  String created_at;

  TaskModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.dueDate,
    required this.status,
    required this.created_at,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      title: map['title'],
      subject: map['subject'],
      dueDate: map['dueDate'],
      status: map['status'],
      created_at: map['created_at'] ?? map['createdAt'], // Handle both formats
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'dueDate': dueDate,
      'status': status,
      'createdAt': created_at,
    };
  }
}

class TaskAccordingToCreatedAt {
  String createdAt;
  List<TaskModel> tasks;

  TaskAccordingToCreatedAt({required this.createdAt, required this.tasks});
}