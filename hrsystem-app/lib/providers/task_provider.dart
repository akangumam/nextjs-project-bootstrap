import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/user.dart';
import '../services/task_service.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _service = TaskService();
  
  List<Task> _tasks = [];
  TaskStats? _stats;
  bool _isLoading = false;
  String? _error;
  TaskStatus? _filterStatus;
  TaskPriority? _filterPriority;
  String? _searchQuery;

  // Getters
  List<Task> get tasks => _filterTasks();
  TaskStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  TaskStatus? get filterStatus => _filterStatus;
  TaskPriority? get filterPriority => _filterPriority;
  String? get searchQuery => _searchQuery;

  // Filter tasks based on current filters and search query
  List<Task> _filterTasks() {
    return _tasks.where((task) {
      bool matches = true;

      if (_filterStatus != null) {
        matches = matches && task.status == _filterStatus;
      }

      if (_filterPriority != null) {
        matches = matches && task.priority == _filterPriority;
      }

      if (_searchQuery != null && _searchQuery!.isNotEmpty) {
        final query = _searchQuery!.toLowerCase();
        matches = matches && (
          task.title.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query) ||
          task.assignedTo.name.toLowerCase().contains(query)
        );
      }

      return matches;
    }).toList();
  }

  // Load tasks
  Future<void> loadTasks() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _tasks = await _service.getTasks(
        status: _filterStatus,
        priority: _filterPriority,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load task statistics
  Future<void> loadTaskStats() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final now = DateTime.now();
      _stats = await _service.getTaskStats(
        startDate: DateTime(now.year, now.month, 1),
        endDate: DateTime(now.year, now.month + 1, 0),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create new task
  Future<Task> createTask(Task task) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final newTask = await _service.createTask(task);
      _tasks.add(newTask);

      _isLoading = false;
      notifyListeners();

      return newTask;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update existing task
  Future<Task> updateTask(Task task) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final updatedTask = await _service.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
      }

      _isLoading = false;
      notifyListeners();

      return updatedTask;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.deleteTask(taskId);
      _tasks.removeWhere((task) => task.id == taskId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Add comment to task
  Future<TaskComment> addComment(String taskId, String content, User user) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final comment = await _service.addComment(taskId, content, user);
      final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      
      if (taskIndex != -1) {
        final task = _tasks[taskIndex];
        final comments = List<TaskComment>.from(task.comments ?? [])..add(comment);
        _tasks[taskIndex] = task.copyWith(comments: comments);
      }

      _isLoading = false;
      notifyListeners();

      return comment;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Add attachment to task
  Future<TaskAttachment> addAttachment(
    String taskId,
    String name,
    String url,
    String type,
    int size,
    User user,
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final attachment = await _service.addAttachment(
        taskId,
        name,
        url,
        type,
        size,
        user,
      );

      final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        final task = _tasks[taskIndex];
        final attachments = List<TaskAttachment>.from(task.attachments ?? [])
          ..add(attachment);
        _tasks[taskIndex] = task.copyWith(attachments: attachments);
      }

      _isLoading = false;
      notifyListeners();

      return attachment;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Set status filter
  void setStatusFilter(TaskStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  // Set priority filter
  void setPriorityFilter(TaskPriority? priority) {
    _filterPriority = priority;
    notifyListeners();
  }

  // Set search query
  void setSearchQuery(String? query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _filterStatus = null;
    _filterPriority = null;
    _searchQuery = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
