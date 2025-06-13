import 'package:flutter/material.dart';
import 'user.dart';

enum TaskPriority {
  low,
  medium,
  high,
}

enum TaskStatus {
  todo,
  inProgress,
  review,
  done,
}

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final User assignedTo;
  final User createdBy;
  final List<TaskComment>? comments;
  final List<TaskAttachment>? attachments;
  final List<String>? tags;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.dueDate,
    required this.priority,
    required this.status,
    required this.assignedTo,
    required this.createdBy,
    this.comments,
    this.attachments,
    this.tags,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      dueDate: DateTime.parse(json['due_date'] as String),
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString() == 'TaskPriority.${json['priority']}',
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.toString() == 'TaskStatus.${json['status']}',
      ),
      assignedTo: User.fromJson(json['assigned_to'] as Map<String, dynamic>),
      createdBy: User.fromJson(json['created_by'] as Map<String, dynamic>),
      comments: json['comments'] != null
          ? (json['comments'] as List)
              .map((comment) => TaskComment.fromJson(comment))
              .toList()
          : null,
      attachments: json['attachments'] != null
          ? (json['attachments'] as List)
              .map((attachment) => TaskAttachment.fromJson(attachment))
              .toList()
          : null,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'priority': priority.toString().split('.').last,
      'status': status.toString().split('.').last,
      'assigned_to': assignedTo.toJson(),
      'created_by': createdBy.toJson(),
      'comments': comments?.map((comment) => comment.toJson()).toList(),
      'attachments': attachments?.map((attachment) => attachment.toJson()).toList(),
      'tags': tags,
    };
  }

  Color getPriorityColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (priority) {
      case TaskPriority.low:
        return theme.colorScheme.primary;
      case TaskPriority.medium:
        return theme.colorScheme.tertiary;
      case TaskPriority.high:
        return theme.colorScheme.error;
    }
  }

  String getPriorityText() {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  Color getStatusColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (status) {
      case TaskStatus.todo:
        return theme.colorScheme.secondary;
      case TaskStatus.inProgress:
        return theme.colorScheme.primary;
      case TaskStatus.review:
        return theme.colorScheme.tertiary;
      case TaskStatus.done:
        return theme.colorScheme.primary;
    }
  }

  String getStatusText() {
    switch (status) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.review:
        return 'Review';
      case TaskStatus.done:
        return 'Done';
    }
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
    User? assignedTo,
    User? createdBy,
    List<TaskComment>? comments,
    List<TaskAttachment>? attachments,
    List<String>? tags,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      createdBy: createdBy ?? this.createdBy,
      comments: comments ?? this.comments,
      attachments: attachments ?? this.attachments,
      tags: tags ?? this.tags,
    );
  }
}

class TaskComment {
  final String id;
  final String content;
  final DateTime createdAt;
  final User createdBy;

  TaskComment({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.createdBy,
  });

  factory TaskComment.fromJson(Map<String, dynamic> json) {
    return TaskComment(
      id: json['id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      createdBy: User.fromJson(json['created_by'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy.toJson(),
    };
  }
}

class TaskAttachment {
  final String id;
  final String name;
  final String url;
  final String type;
  final int size;
  final DateTime uploadedAt;
  final User uploadedBy;

  TaskAttachment({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.size,
    required this.uploadedAt,
    required this.uploadedBy,
  });

  factory TaskAttachment.fromJson(Map<String, dynamic> json) {
    return TaskAttachment(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      type: json['type'] as String,
      size: json['size'] as int,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
      uploadedBy: User.fromJson(json['uploaded_by'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'type': type,
      'size': size,
      'uploaded_at': uploadedAt.toIso8601String(),
      'uploaded_by': uploadedBy.toJson(),
    };
  }
}
