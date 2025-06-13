import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/user.dart';
import '../services/expense_service.dart';

class ExpenseProvider with ChangeNotifier {
  final ExpenseService _service = ExpenseService();
  
  List<Expense> _expenses = [];
  ExpenseStats? _stats;
  bool _isLoading = false;
  String? _error;
  ExpenseStatus? _filterStatus;
  ExpenseCategory? _filterCategory;
  String? _searchQuery;
  DateTime? _startDate;
  DateTime? _endDate;

  // Getters
  List<Expense> get expenses => _filterExpenses();
  ExpenseStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ExpenseStatus? get filterStatus => _filterStatus;
  ExpenseCategory? get filterCategory => _filterCategory;
  String? get searchQuery => _searchQuery;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  // Filter expenses based on current filters and search query
  List<Expense> _filterExpenses() {
    return _expenses.where((expense) {
      bool matches = true;

      if (_filterStatus != null) {
        matches = matches && expense.status == _filterStatus;
      }

      if (_filterCategory != null) {
        matches = matches && expense.category == _filterCategory;
      }

      if (_searchQuery != null && _searchQuery!.isNotEmpty) {
        final query = _searchQuery!.toLowerCase();
        matches = matches && (
          expense.title.toLowerCase().contains(query) ||
          expense.description.toLowerCase().contains(query) ||
          expense.merchantName?.toLowerCase().contains(query) == true ||
          expense.receiptNumber?.toLowerCase().contains(query) == true
        );
      }

      if (_startDate != null) {
        matches = matches && expense.date.isAfter(_startDate!);
      }

      if (_endDate != null) {
        matches = matches && expense.date.isBefore(_endDate!.add(const Duration(days: 1)));
      }

      return matches;
    }).toList();
  }

  // Load expenses
  Future<void> loadExpenses() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _expenses = await _service.getExpenses(
        status: _filterStatus,
        category: _filterCategory,
        startDate: _startDate,
        endDate: _endDate,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load expense statistics
  Future<void> loadExpenseStats() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final now = DateTime.now();
      final startDate = _startDate ?? DateTime(now.year, now.month, 1);
      final endDate = _endDate ?? DateTime(now.year, now.month + 1, 0);

      _stats = await _service.getExpenseStats(
        startDate: startDate,
        endDate: endDate,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create new expense
  Future<Expense> createExpense(Expense expense) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final newExpense = await _service.createExpense(expense);
      _expenses.add(newExpense);

      _isLoading = false;
      notifyListeners();

      return newExpense;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update existing expense
  Future<Expense> updateExpense(Expense expense) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final updatedExpense = await _service.updateExpense(expense);
      final index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _expenses[index] = updatedExpense;
      }

      _isLoading = false;
      notifyListeners();

      return updatedExpense;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Delete expense
  Future<void> deleteExpense(String expenseId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.deleteExpense(expenseId);
      _expenses.removeWhere((expense) => expense.id == expenseId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Add attachment to expense
  Future<ExpenseAttachment> addAttachment(
    String expenseId,
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
        expenseId,
        name,
        url,
        type,
        size,
        user,
      );

      final expenseIndex = _expenses.indexWhere((e) => e.id == expenseId);
      if (expenseIndex != -1) {
        final expense = _expenses[expenseIndex];
        final attachments = List<ExpenseAttachment>.from(expense.attachments ?? [])
          ..add(attachment);
        _expenses[expenseIndex] = expense.copyWith(attachments: attachments);
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
  void setStatusFilter(ExpenseStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  // Set category filter
  void setCategoryFilter(ExpenseCategory? category) {
    _filterCategory = category;
    notifyListeners();
  }

  // Set search query
  void setSearchQuery(String? query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Set date range
  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _filterStatus = null;
    _filterCategory = null;
    _searchQuery = null;
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
