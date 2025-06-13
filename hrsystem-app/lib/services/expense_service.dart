import 'dart:async';
import '../models/expense.dart';
import '../models/user.dart';

class ExpenseService {
  // Simulate API delay
  static const _delay = Duration(milliseconds: 800);

  // Simulate expense data
  Future<List<Expense>> getExpenses({
    ExpenseStatus? status,
    ExpenseCategory? category,
    String? submittedById,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(_delay);

    // Simulate dummy user
    final dummyUser = User(
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
      role: 'employee',
    );

    // Simulate dummy expenses
    final List<Expense> expenses = List.generate(
      10,
      (index) => Expense(
        id: 'exp_$index',
        title: 'Expense ${index + 1}',
        description: 'Description for expense ${index + 1}',
        amount: (index + 1) * 100.0,
        date: DateTime.now().subtract(Duration(days: index)),
        category: ExpenseCategory.values[index % ExpenseCategory.values.length],
        status: ExpenseStatus.values[index % ExpenseStatus.values.length],
        submittedBy: dummyUser,
        submittedAt: DateTime.now().subtract(Duration(days: index)),
        approvedBy: index % 2 == 0 ? dummyUser : null,
        approvedAt: index % 2 == 0 ? DateTime.now() : null,
        merchantName: 'Merchant ${index + 1}',
        receiptNumber: 'R-${1000 + index}',
        attachments: [
          ExpenseAttachment(
            id: 'att_$index',
            name: 'receipt_$index.pdf',
            url: 'https://example.com/receipts/$index.pdf',
            type: 'application/pdf',
            size: 1024 * 1024,
            uploadedAt: DateTime.now(),
            uploadedBy: dummyUser,
          ),
        ],
      ),
    );

    // Apply filters if provided
    return expenses.where((expense) {
      bool matches = true;

      if (status != null) {
        matches = matches && expense.status == status;
      }

      if (category != null) {
        matches = matches && expense.category == category;
      }

      if (submittedById != null) {
        matches = matches && expense.submittedBy.id == submittedById;
      }

      if (startDate != null) {
        matches = matches && expense.date.isAfter(startDate);
      }

      if (endDate != null) {
        matches = matches && expense.date.isBefore(endDate);
      }

      return matches;
    }).toList();
  }

  Future<Expense> createExpense(Expense expense) async {
    await Future.delayed(_delay);
    // Simulate API call
    return expense.copyWith(
      id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
      submittedAt: DateTime.now(),
    );
  }

  Future<Expense> updateExpense(Expense expense) async {
    await Future.delayed(_delay);
    // Simulate API call
    return expense;
  }

  Future<void> deleteExpense(String expenseId) async {
    await Future.delayed(_delay);
    // Simulate API call
  }

  Future<ExpenseAttachment> addAttachment(
    String expenseId,
    String name,
    String url,
    String type,
    int size,
    User user,
  ) async {
    await Future.delayed(_delay);
    // Simulate API call
    return ExpenseAttachment(
      id: 'att_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      url: url,
      type: type,
      size: size,
      uploadedAt: DateTime.now(),
      uploadedBy: user,
    );
  }

  Future<ExpenseStats> getExpenseStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await Future.delayed(_delay);
    // Simulate API call
    return ExpenseStats(
      totalExpenses: 20,
      totalAmount: 5000.0,
      approvedExpenses: 12,
      approvedAmount: 3000.0,
      pendingExpenses: 5,
      pendingAmount: 1500.0,
      rejectedExpenses: 3,
      rejectedAmount: 500.0,
      categoryBreakdown: {
        ExpenseCategory.travel: 2000.0,
        ExpenseCategory.meals: 1000.0,
        ExpenseCategory.supplies: 500.0,
        ExpenseCategory.equipment: 1000.0,
        ExpenseCategory.software: 300.0,
        ExpenseCategory.training: 200.0,
      },
      monthlyTrend: List.generate(
        6,
        (index) => MonthlyExpense(
          month: DateTime.now().subtract(Duration(days: 30 * index)),
          amount: 1000.0 - (index * 100),
          count: 10 - index,
        ),
      ),
      startDate: startDate,
      endDate: endDate,
    );
  }
}

class ExpenseStats {
  final int totalExpenses;
  final double totalAmount;
  final int approvedExpenses;
  final double approvedAmount;
  final int pendingExpenses;
  final double pendingAmount;
  final int rejectedExpenses;
  final double rejectedAmount;
  final Map<ExpenseCategory, double> categoryBreakdown;
  final List<MonthlyExpense> monthlyTrend;
  final DateTime startDate;
  final DateTime endDate;

  ExpenseStats({
    required this.totalExpenses,
    required this.totalAmount,
    required this.approvedExpenses,
    required this.approvedAmount,
    required this.pendingExpenses,
    required this.pendingAmount,
    required this.rejectedExpenses,
    required this.rejectedAmount,
    required this.categoryBreakdown,
    required this.monthlyTrend,
    required this.startDate,
    required this.endDate,
  });

  double get approvalRate =>
      totalExpenses > 0 ? (approvedExpenses / totalExpenses * 100) : 0;

  double get averageExpenseAmount =>
      totalExpenses > 0 ? (totalAmount / totalExpenses) : 0;
}

class MonthlyExpense {
  final DateTime month;
  final double amount;
  final int count;

  MonthlyExpense({
    required this.month,
    required this.amount,
    required this.count,
  });
}
