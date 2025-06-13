import 'package:flutter/material.dart';
import 'user.dart';

enum ExpenseStatus {
  draft,
  submitted,
  approved,
  rejected,
  reimbursed
}

enum ExpenseCategory {
  travel,
  meals,
  supplies,
  equipment,
  software,
  training,
  others
}

class Expense {
  final String id;
  final String title;
  final String description;
  final double amount;
  final DateTime date;
  final ExpenseCategory category;
  final ExpenseStatus status;
  final User submittedBy;
  final User? approvedBy;
  final DateTime submittedAt;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final List<ExpenseAttachment>? attachments;
  final String? notes;
  final String? receiptNumber;
  final String? merchantName;
  final bool isReimbursable;

  Expense({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
    required this.status,
    required this.submittedBy,
    required this.submittedAt,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    this.attachments,
    this.notes,
    this.receiptNumber,
    this.merchantName,
    this.isReimbursable = true,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      amount: json['amount'] as double,
      date: DateTime.parse(json['date'] as String),
      category: ExpenseCategory.values.firstWhere(
        (e) => e.toString() == 'ExpenseCategory.${json['category']}',
      ),
      status: ExpenseStatus.values.firstWhere(
        (e) => e.toString() == 'ExpenseStatus.${json['status']}',
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
              .map((attachment) => ExpenseAttachment.fromJson(attachment))
              .toList()
          : null,
      notes: json['notes'] as String?,
      receiptNumber: json['receipt_number'] as String?,
      merchantName: json['merchant_name'] as String?,
      isReimbursable: json['is_reimbursable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category.toString().split('.').last,
      'status': status.toString().split('.').last,
      'submitted_by': submittedBy.toJson(),
      'submitted_at': submittedAt.toIso8601String(),
      'approved_by': approvedBy?.toJson(),
      'approved_at': approvedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'attachments': attachments?.map((attachment) => attachment.toJson()).toList(),
      'notes': notes,
      'receipt_number': receiptNumber,
      'merchant_name': merchantName,
      'is_reimbursable': isReimbursable,
    };
  }

  Color getStatusColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (status) {
      case ExpenseStatus.draft:
        return theme.colorScheme.secondary;
      case ExpenseStatus.submitted:
        return theme.colorScheme.primary;
      case ExpenseStatus.approved:
        return theme.colorScheme.tertiary;
      case ExpenseStatus.rejected:
        return theme.colorScheme.error;
      case ExpenseStatus.reimbursed:
        return theme.colorScheme.primary;
    }
  }

  String getStatusText() {
    switch (status) {
      case ExpenseStatus.draft:
        return 'Draft';
      case ExpenseStatus.submitted:
        return 'Submitted';
      case ExpenseStatus.approved:
        return 'Approved';
      case ExpenseStatus.rejected:
        return 'Rejected';
      case ExpenseStatus.reimbursed:
        return 'Reimbursed';
    }
  }

  String getCategoryText() {
    switch (category) {
      case ExpenseCategory.travel:
        return 'Travel';
      case ExpenseCategory.meals:
        return 'Meals';
      case ExpenseCategory.supplies:
        return 'Supplies';
      case ExpenseCategory.equipment:
        return 'Equipment';
      case ExpenseCategory.software:
        return 'Software';
      case ExpenseCategory.training:
        return 'Training';
      case ExpenseCategory.others:
        return 'Others';
    }
  }

  IconData getCategoryIcon() {
    switch (category) {
      case ExpenseCategory.travel:
        return Icons.flight;
      case ExpenseCategory.meals:
        return Icons.restaurant;
      case ExpenseCategory.supplies:
        return Icons.shopping_cart;
      case ExpenseCategory.equipment:
        return Icons.computer;
      case ExpenseCategory.software:
        return Icons.code;
      case ExpenseCategory.training:
        return Icons.school;
      case ExpenseCategory.others:
        return Icons.more_horiz;
    }
  }

  Expense copyWith({
    String? id,
    String? title,
    String? description,
    double? amount,
    DateTime? date,
    ExpenseCategory? category,
    ExpenseStatus? status,
    User? submittedBy,
    User? approvedBy,
    DateTime? submittedAt,
    DateTime? approvedAt,
    String? rejectionReason,
    List<ExpenseAttachment>? attachments,
    String? notes,
    String? receiptNumber,
    String? merchantName,
    bool? isReimbursable,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      status: status ?? this.status,
      submittedBy: submittedBy ?? this.submittedBy,
      approvedBy: approvedBy ?? this.approvedBy,
      submittedAt: submittedAt ?? this.submittedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      attachments: attachments ?? this.attachments,
      notes: notes ?? this.notes,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      merchantName: merchantName ?? this.merchantName,
      isReimbursable: isReimbursable ?? this.isReimbursable,
    );
  }
}

class ExpenseAttachment {
  final String id;
  final String name;
  final String url;
  final String type;
  final int size;
  final DateTime uploadedAt;
  final User uploadedBy;

  ExpenseAttachment({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.size,
    required this.uploadedAt,
    required this.uploadedBy,
  });

  factory ExpenseAttachment.fromJson(Map<String, dynamic> json) {
    return ExpenseAttachment(
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
