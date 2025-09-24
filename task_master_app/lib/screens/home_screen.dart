import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_master_app/providers/theme_provider.dart';
import 'package:task_master_app/services/auth_service.dart';
import 'package:task_master_app/services/firestore_service.dart';
import 'package:task_master_app/services/gamification_service.dart';
import 'package:task_master_app/services/motivational_quote_service.dart';
import '../models/task_model.dart';
import '../widgets/task_list_item.dart';
import 'task_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final GamificationService _gamificationService = GamificationService();
  final MotivationalQuoteService _quoteService = MotivationalQuoteService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final userId = _authService.currentUserId;

    if (userId == null) {
      return const Scaffold(
        body: Center(
          child: Text("Not logged in."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Tasks"),
        actions: [
          IconButton(
            icon: Icon(
              Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false)
                  .toggleTheme(Provider.of<ThemeProvider>(context, listen: false).themeMode != ThemeMode.dark);
            },
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildQuoteOfTheDay(),
          Expanded(
            child: StreamBuilder<List<TaskModel>>(
              stream: _firestoreService.getTasksStream(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "No tasks yet. Add one!",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                final tasks = snapshot.data!;
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return TaskListItem(
                      task: task,
                      onCompleted: (value) {
                        if (value == true) {
                          _firestoreService.updateTaskCompletion(
                              userId, task.id, true).then((_) {
                            _gamificationService.awardXp(userId, task.xpValue);
                            _gamificationService.updateStreak(userId);
                          });
                        } else {
                          _firestoreService.updateTaskCompletion(
                              userId, task.id, false);
                        }
                      },
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskEditScreen(task: task),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TaskEditScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Task',
      ),
    );
  }

  Widget _buildQuoteOfTheDay() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Quote of the Day',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            _quoteService.getDailyQuote(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
