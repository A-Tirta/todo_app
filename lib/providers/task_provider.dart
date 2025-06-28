import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  TaskCategory? _selectedCategory;
  String _searchQuery = '';
  bool _showCompleted = true;

  List<Task> get tasks {
    List<Task> filteredTasks = _tasks;

    // Filter by category
    if (_selectedCategory != null) {
      filteredTasks = filteredTasks
          .where((task) => task.category == _selectedCategory)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredTasks = filteredTasks
          .where((task) =>
      task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          task.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Filter completed tasks
    if (!_showCompleted) {
      filteredTasks = filteredTasks.where((task) => !task.isCompleted).toList();
    }

    return filteredTasks;
  }

  List<Task> get pendingTasks =>
      _tasks.where((task) => !task.isCompleted).toList();

  List<Task> get completedTasks =>
      _tasks.where((task) => task.isCompleted).toList();

  List<Task> get overdueTasks =>
      _tasks.where((task) => task.isOverdue).toList();

  List<Task> get todayTasks =>
      _tasks.where((task) => task.isDueToday && !task.isCompleted).toList();

  TaskCategory? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get showCompleted => _showCompleted;

  int get completionPercentage {
    if (_tasks.isEmpty) return 0;
    return (completedTasks.length * 100 / _tasks.length).round();
  }

  TaskProvider() {
    loadTasks();
  }

  Future<void> loadTasks() async {
    _tasks = await DatabaseService.getAllTasks();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await DatabaseService.insertTask(task);
    _tasks.insert(0, task);

    if (task.dueDate != null) {
      await NotificationService.scheduleTaskReminder(task);
    }

    notifyListeners();
  }

  Future<void> updateTask(Task updatedTask) async {
    await DatabaseService.updateTask(updatedTask);

    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;

      // Update notification
      await NotificationService.cancelTaskReminder(updatedTask.id);
      if (updatedTask.dueDate != null && !updatedTask.isCompleted) {
        await NotificationService.scheduleTaskReminder(updatedTask);
      }

      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    await DatabaseService.deleteTask(taskId);
    await NotificationService.cancelTaskReminder(taskId);
    _tasks.removeWhere((task) => task.id == taskId);
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      final updatedTask = task.copyWith(
        isCompleted: !task.isCompleted,
        completedAt: !task.isCompleted ? DateTime.now() : null,
      );
      await updateTask(updatedTask);
    }
  }

  void setSelectedCategory(TaskCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleShowCompleted() {
    _showCompleted = !_showCompleted;
    notifyListeners();
  }

  Map<TaskCategory, int> getCategoryStats() {
    final stats = <TaskCategory, int>{};
    for (final category in TaskCategory.values) {
      stats[category] = _tasks.where((task) =>
      task.category == category && !task.isCompleted).length;
    }
    return stats;
  }
}