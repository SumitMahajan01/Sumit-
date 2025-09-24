import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_master_app/models/task_model.dart';
import 'package:task_master_app/services/auth_service.dart';
import 'package:task_master_app/services/firestore_service.dart';

class TaskEditScreen extends StatefulWidget {
  final TaskModel? task;

  const TaskEditScreen({super.key, this.task});

  @override
  State<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _authService = AuthService();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;

  DateTime? _dueDate;
  TaskPriority _priority = TaskPriority.medium;
  List<Subtask> _subtasks = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title);
    _descriptionController = TextEditingController(text: widget.task?.description);
    _categoryController = TextEditingController(text: widget.task?.category ?? 'General');
    _dueDate = widget.task?.dueDate;
    _priority = widget.task?.priority ?? TaskPriority.medium;
    _subtasks = widget.task?.subtasks.map((s) => Subtask(title: s.title, isCompleted: s.isCompleted)).toList() ?? [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final userId = _authService.currentUserId;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in.')),
        );
        return;
      }

      final now = DateTime.now();
      final task = TaskModel(
        id: widget.task?.id ?? '',
        userId: userId,
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _dueDate!,
        priority: _priority,
        category: _categoryController.text,
        isCompleted: widget.task?.isCompleted ?? false,
        createdAt: widget.task?.createdAt ?? now,
        subtasks: _subtasks,
        isRecurring: widget.task?.isRecurring ?? false,
        xpValue: widget.task?.xpValue ?? 10,
      );

      if (widget.task == null) {
        _firestoreService.addTask(userId, task);
      } else {
        _firestoreService.updateTask(userId, task);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTask,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description (Optional)'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskPriority>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: TaskPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority.toString().split('.').last.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _priority = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _dueDate == null
                          ? 'No due date selected'
                          : 'Due: ${DateFormat.yMMMd().format(_dueDate!)}',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSubtaskManager(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubtaskManager() {
    final TextEditingController subtaskController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Subtasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: subtaskController,
                decoration: const InputDecoration(labelText: 'Add a subtask'),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (subtaskController.text.isNotEmpty) {
                  setState(() {
                    _subtasks.add(Subtask(title: subtaskController.text));
                    subtaskController.clear();
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _subtasks.length,
          itemBuilder: (context, index) {
            final subtask = _subtasks[index];
            return ListTile(
              leading: Checkbox(
                value: subtask.isCompleted,
                onChanged: (value) {
                  setState(() {
                    subtask.isCompleted = value ?? false;
                  });
                },
              ),
              title: Text(
                subtask.title,
                style: TextStyle(
                  decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _subtasks.removeAt(index);
                  });
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
