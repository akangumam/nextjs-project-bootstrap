import 'package:flutter/material.dart';
import 'user.dart';

enum LeaveStatus {
  draft,
  pending,
  approved,
  rejected,
  cancelled
}

enum LeaveType {
  annual,
  sick,
  personal,
  maternity,
  paternity,
  bereavement,
  unpaid,
  other
}

class Leave {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final LeaveType type;
  final LeaveStatus status;
  final User submittedBy;
  final User? approvedBy;
  final DateTime submittedAt;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final List<LeaveAttachment>? attachments;
  final String? notes;
  final bool isHalfDay;
  final double durationInDays;
  final List<LeaveComment>? comments;

  Leave({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.status,
    required this.submittedBy,
    required this.submittedAt,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    this.attachments,
    this.notes,
    this.isHalfDay = false,
    required this.durationInDays,
    this.comments,
  });

  factory Leave.fromJson(Map<String, dynamic> json) {
    return Leave(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      type: LeaveType.values.firstWhere(
        (e) => e.toString() == 'LeaveType.${json['type']}',
      ),
      status: LeaveStatus.values.firstWhere(
        (e) => e.toString() == 'LeaveStatus.${json['status']}',
      ),
      submittedBy: User.fromJson(json['submitted_by'] as Map<String, dynamic>),
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      approvedBy: json['approved_by'] != null
          ? User.fromJson(json['approved_by'] as Map<String, dynamic>)
          : null,
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String)
          : null,
      rejectionReason: json['rejection_reason'] as String?,
      attachments: json['attachments'] != null
          ? (json['attachments'] as List)
              .map((attachment) => LeaveAttachment.fromJson(attachment))
              .toList()
          : null,
      notes: json['notes'] as String?,
      isHalfDay: json['is_half_day'] as bool? ?? false,
      durationInDays: json['duration_in_days'] as double,
      comments: json['comments'] != null
          ? (json['comments'] as List)
              .map((comment) => LeaveComment.fromJson(comment))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'submitted_by': submittedBy.toJson(),
      'submitted_at': submittedAt.toIso8601String(),
      'approved_by': approvedBy?.toJson(),
      'approved_at': approvedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'attachments': attachments?.map((attachment) => attachment.toJson()).toList(),
      'notes': notes,
      'is_half_day': isHalfDay,
      'duration_in_days': durationInDays,
      'comments': comments?.map((comment) => comment.toJson()).toList(),
    };
  }

  Color getStatusColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (status) {
      case LeaveStatus.draft:
        return theme.colorScheme.secondary;
      case LeaveStatus.pending:
        return theme.colorScheme.primary;
      case LeaveStatus.approved:
        return theme.colorScheme.tertiary;
      case LeaveStatus.rejected:
        return theme.colorScheme.error;
      case LeaveStatus.cancelled:
        return theme.colorScheme.outline;
    }
  }

  String getStatusText() {
    switch (status) {
      case LeaveStatus.draft:
        return 'Draft';
      case LeaveStatus.pending:
        return 'Pending';
      case LeaveStatus.approved:
        return 'Approved';
      case LeaveStatus.rejected:
        return 'Rejected';
      case LeaveStatus.cancelled:
        return 'Cancelled';
    }
  }

  String getTypeText() {
    switch (type) {
      case LeaveType.annual:
        return 'Annual Leave';
      case LeaveType.sick:
        return 'Sick Leave';
      case LeaveType.personal:
        return 'Personal Leave';
      case LeaveType.maternity:
        return 'Maternity Leave';
      case LeaveType.paternity:
        return 'Paternity Leave';
      case LeaveType.bereavement:
        return 'Bereavement Leave';
      case LeaveType.unpaid:
        return 'Unpaid Leave';
      case LeaveType.other:
        return 'Other Leave';
    }
  }

  IconData getTypeIcon() {
    switch (type) {
      case LeaveType.annual:
        return Icons.beach_access;
      case LeaveType.sick:
        return Icons.medical_services;
      case LeaveType.personal:
        return Icons.person;
      case LeaveType.maternity:
        return Icons.child_care;
      case LeaveType.paternity:
        return Icons.family_restroom;
      case LeaveType.bereavement:
        return Icons.sentiment_very_dissatisfied;
      case LeaveType.unpaid:
        return Icons.money_off;
      case LeaveType.other:
        return Icons.more_horiz;
    }
  }

  Leave copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    LeaveType? type,
    LeaveStatus? status,
    User? submittedBy,
    User? approvedBy,
    DateTime? submittedAt,
    DateTime? approvedAt,
    String? rejectionReason,
    List<LeaveAttachment>? attachments,
    String? notes,
    bool? isHalfDay,
    double? durationInDays,
    List<LeaveComment>? comments,
  }) {
    return Leave(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      type: type ?? this.type,
      status: status ?? this.status,
      submittedBy: submittedBy ?? this.submittedBy,
      approvedBy: approvedBy ?? this.approvedBy,
      submittedAt: submittedAt ?? this.submittedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      attachments: attachments ?? this.attachments,
      notes: notes ?? this.notes,
      isHalfDay: isHalfDay ?? this.isHalfDay,
      durationInDays: durationInDays ?? this.durationInDays,
      comments: comments ?? this.comments,
    );
  }
}

class LeaveAttachment {
  final String id;
  final String name;
  final String url;
  final String type;
  final int size;
  final DateTime uploadedAt;
  final User uploadedBy;

  LeaveAttachment({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.size,
    required this.uploadedAt,
    required this.uploadedBy,
  });

  factory LeaveAttachment.fromJson(Map<String, dynamic> json) {
    return LeaveAttachment(
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

class LeaveComment {
  final String id;
  final String content;
  final DateTime createdAt;
  final User createdBy;

  LeaveComment({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.createdBy,
  });

  factory LeaveComment.fromJson(Map<String, dynamic> json) {
    return LeaveComment(
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
