import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class Task {
  final String id;
  String title;
  String description;
  String? dueDate;
  String priority;
  String status;
  List<String> filePaths; // New Update

  Task({
    String? id,
    required this.title,
    required this.description,
    this.dueDate,
    required this.priority,
    this.status = 'Not Started',
    this.filePaths = const [], // New Update
  }) : id = id ?? uuid.v4();

  // Convert Task to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'priority': priority,
      'status': status,
      'filePaths': filePaths, // New Update
    };
  }

  // Convert JSON to Task
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: json['dueDate'],
      priority: json['priority'],
      status: json['status'] ?? 'Not Started',
      filePaths: List<String>.from(json['filePaths'] ?? []), // New Update
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'priority': priority,
      'status': status,
    };
  }

  // Optionally, you can add a fromMap constructor to easily create Task objects from maps
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: map['dueDate'] ?? '',
      priority: map['priority'] ?? '',
      status: map['status'] ?? '',
    );
  }
}
