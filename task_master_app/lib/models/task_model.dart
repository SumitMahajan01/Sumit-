import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskPriority { low, medium, high }

class Subtask {
  final String title;
  bool isCompleted;

  Subtask({required this.title, this.isCompleted = false});

  factory Subtask.fromMap(Map<String, dynamic> map) {
    return Subtask(
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isCompleted': isCompleted,
    };
  }
}

class TaskModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime dueDate;
  final TaskPriority priority;
  final String category;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final List<Subtask> subtasks;
  final bool isRecurring;
  final int xpValue;

  TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.dueDate,
    this.priority = TaskPriority.medium,
    required this.category,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.subtasks = const [],
    this.isRecurring = false,
    this.xpValue = 10,
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString() == data['priority'],
        orElse: () => TaskPriority.medium,
      ),
      category: data['category'] ?? 'General',
      isCompleted: data['isCompleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      subtasks: (data['subtasks'] as List<dynamic>?)
              ?.map((subtaskMap) => Subtask.fromMap(subtaskMap))
              .toList() ??
          [],
      isRecurring: data['isRecurring'] ?? false,
      xpValue: data['xpValue'] ?? 10,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'priority': priority.toString(),
      'category': category,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'subtasks': subtasks.map((subtask) => subtask.toMap()).toList(),
      'isRecurring': isRecurring,
      'xpValue': xpValue,
    };
  }
}
