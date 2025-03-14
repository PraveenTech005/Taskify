import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:taskify/models/task.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  // ignore: prefer_final_fields
  List<Task> _deletedTasks = [];

  String selectedSorting = "A - Z";

  List<Task> get tasks => _tasks;
  List<Task> get deletedTasks => _deletedTasks;

  void setTasks(List<Task> newTasks) {
    _tasks = newTasks;
    notifyListeners();
  }

  void setSortingPreference(String sorting) {
    selectedSorting = sorting;
    _applySorting();
  }

  void _applySorting() {
    if (selectedSorting == "Priority Ascending") {
      tasks.sort((a, b) => a.priority.compareTo(b.priority));
    } else if (selectedSorting == "Priority Descending") {
      tasks.sort((a, b) => b.priority.compareTo(a.priority));
    } else {
      // Implement other sorting methods here like alphabetical, due date, etc.
    }
    notifyListeners();
  }

  TaskProvider() {
    Future.microtask(() => _loadTasks());
  }

  void addTask(Task task) {
    _tasks.add(task);
    _saveTasks(); // Save to SharedPreferences
    notifyListeners();
  }

  void removeTasksByStatus(String status) {
    List<Task> tasksToRemove = _tasks.where((t) => t.status == status).toList();

    if (tasksToRemove.isNotEmpty) {
      _deletedTasks.addAll(tasksToRemove);
      _tasks.removeWhere((task) => task.status == status);
      _saveTasks();
      notifyListeners();
    }
  }

  void removeTask(String id) {
    Task? task = _tasks.firstWhereOrNull((t) => t.id == id);

    if (task != null) {
      _deletedTasks
          .add(task); // Move to Recycle Bin instead of deleting permanently
      _tasks.removeWhere((task) => task.id == id);
      _saveTasks(); // Save changes
      notifyListeners();
    }
  }

  void restoreTask(String id) {
    Task? task = _deletedTasks
        .firstWhereOrNull((t) => t.id == id); // Fix: Look in _deletedTasks

    if (task != null) {
      _tasks.add(task); // Restore task
      _deletedTasks.removeWhere((t) => t.id == id); // Remove from Recycle Bin
      _saveTasks(); // Save changes
      notifyListeners();
    }
  }

  void emptyRecycleBin() {
    _deletedTasks.clear(); // Permanently delete all recycled tasks
    notifyListeners();
  }

  void toggleTaskCompletion(String taskId) {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      _tasks[taskIndex].status =
          _tasks[taskIndex].status == "Completed" ? "In Progress" : "Completed";
      _saveTasks();
      notifyListeners();
    }
  }

  void updateTask(Task oldTask, Task newTask) {
    int index = _tasks.indexWhere((task) => task.id == oldTask.id);
    if (index != -1) {
      _tasks[index] = newTask;
      _saveTasks();
      notifyListeners();
    }
  }

  void insertTask(int index, Task task) {
    _tasks.insert(index, task);
    notifyListeners();
  }

  // void removeCompletedTasks() {
  //   _tasks.removeWhere((task) => task.status == "Completed");
  //   _saveTasks();
  //   notifyListeners();
  // }

  // Convert Task list to JSON and save in SharedPreferences
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> tasksJson =
        _tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList('tasks', tasksJson);
  }

  // Load tasks from SharedPreferences
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? tasksJson = prefs.getStringList('tasks');

    if (tasksJson != null) {
      _tasks.clear();
      _tasks.addAll(
          tasksJson.map((taskStr) => Task.fromJson(jsonDecode(taskStr))));
      notifyListeners();
    }
  }
}

extension ListExtensions<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
