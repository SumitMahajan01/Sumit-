import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get a stream of tasks for a specific user
  Stream<List<TaskModel>> getTasksStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromFirestore(doc))
            .toList());
  }

  // Add a new task
  Future<void> addTask(String userId, TaskModel task) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .add(task.toMap());
  }

  // Update an existing task
  Future<void> updateTask(String userId, TaskModel task) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(task.id)
        .update(task.toMap());
  }

  // Update the completion status of a task
  Future<void> updateTaskCompletion(String userId, String taskId, bool isCompleted) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .update({
          'isCompleted': isCompleted,
          'completedAt': isCompleted ? FieldValue.serverTimestamp() : null,
        });
  }

  // Delete a task
  Future<void> deleteTask(String userId, String taskId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }
}
