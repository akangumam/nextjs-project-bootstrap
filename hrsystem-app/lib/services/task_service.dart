import 'dart:async';
import '../models/task.dart';
import '../models/user.dart';

class TaskService {
  // Simulate API delay
  static const _delay = Duration(milliseconds: 800);

  // Simulate task data
  Future<List<Task>> getTasks({
    TaskStatus? status,
    TaskPriority? priority,
    String? assignedToId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(_delay);

    // Simulate dummy tasks
    final dummyUser = User(
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
      role: 'employee',
    );

    final List<Task> tasks = List.generate(
      10,
      (index) => Task(
        id: 'task_$index',
        title: 'Task ${index + 1}',
        description: 'This is a description for task ${index + 1}',
        createdAt: DateTime.now().subtract(Duration(days: index)),
        dueDate: DateTime.now().add(const Duration(days: 7)),
        priority: TaskPriority.values[index % 3],
        status: TaskStatus.values[index % 4],
        assignedTo: dummyUser,
        createdBy: dummyUser,
        tags: ['UI/UX', 'Development'],
        comments: [
          TaskComment(
            id: 'comment_1',
            content: 'This is a comment',
            createdAt: DateTime.now(),
            createdBy: dummyUser,
          ),
        ],
        attachments: [
          TaskAttachment(
            id: 'attachment_1',
            name: 'document.pdf',
            url: 'https://example.com/document.pdf',
            type: 'application/pdf',
            size: 1024 * 1024, // 1MB
            uploadedAt: DateTime.now(),
            uploadedBy: dummyUser,
          ),
        ],
      ),
    );

    // Apply filters if provided
    return tasks.where((task) {
      bool matches = true;

      if (status != null) {
        matches = matches && task.status == status;
      }

      if (priority != null) {
        matches = matches && task.priority == priority;
      }

      if (assignedToId != null) {
        matches = matches && task.assignedTo.id == assignedToId;
      }

      if (startDate != null) {
        matches = matches && task.createdAt.isAfter(startDate);
      }

      if (endDate != null) {
        matches = matches && task.createdAt.isBefore(endDate);
      }

      return matches;
    }).toList();
  }

  Future<Task> createTask(Task task) async {
    await Future.delayed(_delay);
    // Simulate API call
    return task.copyWith(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );
  }

  Future<Task> updateTask(Task task) async {
    await Future.delayed(_delay);
    // Simulate API call
    return task;
  }

  Future<void> deleteTask(String taskId) async {
    await Future.delayed(_delay);
    // Simulate API call
  }

  Future<TaskComment> addComment(String taskId, String content, User user) async {
    await Future.delayed(_delay);
    // Simulate API call
    return TaskComment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      createdAt: DateTime.now(),
      createdBy: user,
    );
  }

  Future<TaskAttachment> addAttachment(
    String taskId,
    String name,
    String url,
    String type,
    int size,
    User user,
  ) async {
    await Future.delayed(_delay);
    // Simulate API call
    return TaskAttachment(
      id: 'attachment_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      url: url,
      type: type,
      size: size,
      uploadedAt: DateTime.now(),
      uploadedBy: user,
    );
  }

  Future<TaskStats> getTaskStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await Future.delayed(_delay);
    // Simulate API call
    return TaskStats(
      totalTasks: 20,
      completedTasks: 12,
      inProgressTasks: 5,
      reviewTasks: 2,
      todoTasks: 1,
      highPriorityTasks: 4,
      mediumPriorityTasks: 8,
      lowPriorityTasks: 8,
      startDate: startDate,
      endDate: endDate,
    );
  }
}

class TaskStats {
  final int totalTasks;
  final int completedTasks;
  final int inProgressTasks;
  final int reviewTasks;
  final int todoTasks;
  final int highPriorityTasks;
  final int mediumPriorityTasks;
  final int lowPriorityTasks;
  final DateTime startDate;
  final DateTime endDate;

  TaskStats({
    required this.totalTasks,
    required this.completedTasks,
    required this.inProgressTasks,
    required this.reviewTasks,
    required this.todoTasks,
    required this.highPriorityTasks,
    required this.mediumPriorityTasks,
    required this.lowPriorityTasks,
    required this.startDate,
    required this.endDate,
  });

  double get completionRate => 
      totalTasks > 0 ? (completedTasks / totalTasks * 100) : 0;
}
