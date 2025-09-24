import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';

class TaskListItem extends StatelessWidget {
  final TaskModel task;
  final Function(bool?) onCompleted;
  final Function() onTap;

  const TaskListItem({
    super.key,
    required this.task,
    required this.onCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Checkbox(
                value: task.isCompleted,
                onChanged: onCompleted,
                activeColor: Colors.green,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Due: ${DateFormat.yMMMd().format(task.dueDate)}',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              _buildPriorityIcon(task.priority),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIcon(TaskPriority priority) {
    IconData iconData;
    Color color;
    switch (priority) {
      case TaskPriority.high:
        iconData = Icons.flag;
        color = Colors.red;
        break;
      case TaskPriority.medium:
        iconData = Icons.flag;
        color = Colors.orange;
        break;
      case TaskPriority.low:
      default:
        iconData = Icons.flag_outlined;
        color = Colors.blue;
        break;
    }
    return Icon(iconData, color: color);
  }
}
