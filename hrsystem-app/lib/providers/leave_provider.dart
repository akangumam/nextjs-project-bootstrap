import 'package:flutter/material.dart';
import '../models/leave.dart';
import '../models/user.dart';
import '../services/leave_service.dart';

class LeaveProvider with ChangeNotifier {
  final LeaveService _service = LeaveService();
  
  List<Leave> _leaves = [];
  LeaveStats? _stats;
  bool _isLoading = false;
  String? _error;
  LeaveStatus? _filterStatus;
  LeaveType? _filterType;
  String? _searchQuery;
  DateTime? _startDate;
  DateTime? _endDate;

  // Getters
  List<Leave> get leaves => _filterLeaves();
  LeaveStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  LeaveStatus? get filterStatus => _filterStatus;
  LeaveType? get filterType => _filterType;
  String? get searchQuery => _searchQuery;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  // Filter leaves based on current filters and search query
  List<Leave> _filterLeaves() {
    return _leaves.where((leave) {
      bool matches = true;

      if (_filterStatus != null) {
        matches = matches && leave.status == _filterStatus;
      }

      if (_filterType != null) {
        matches = matches && leave.type == _filterType;
      }

      if (_searchQuery != null && _searchQuery!.isNotEmpty) {
        final query = _searchQuery!.toLowerCase();
        matches = matches && (
          leave.title.toLowerCase().contains(query) ||
          leave.description.toLowerCase().contains(query)
        );
      }

      if (_startDate != null) {
        matches = matches && leave.startDate.isAfter(_startDate!);
      }

      if (_endDate != null) {
        matches = matches && leave.endDate.isBefore(_endDate!.add(const Duration(days: 1)));
      }

      return matches;
    }).toList();
  }

  // Load leaves
  Future<void> loadLeaves() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _leaves = await _service.getLeaves(
        status: _filterStatus,
        type: _filterType,
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

  // Load leave statistics
  Future<void> loadLeaveStats() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final now = DateTime.now();
      final startDate = _startDate ?? DateTime(now.year, now.month, 1);
      final endDate = _endDate ?? DateTime(now.year, now.month + 1, 0);

      _stats = await _service.getLeaveStats(
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

  // Create new leave
  Future<Leave> createLeave(Leave leave) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final newLeave = await _service.createLeave(leave);
      _leaves.add(newLeave);

      _isLoading = false;
      notifyListeners();

      return newLeave;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update existing leave
  Future<Leave> updateLeave(Leave leave) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final updatedLeave = await _service.updateLeave(leave);
      final index = _leaves.indexWhere((l) => l.id == leave.id);
      if (index != -1) {
        _leaves[index] = updatedLeave;
      }

      _isLoading = false;
      notifyListeners();

      return updatedLeave;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Delete leave
  Future<void> deleteLeave(String leaveId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.deleteLeave(leaveId);
      _leaves.removeWhere((leave) => leave.id == leaveId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Add attachment to leave
  Future<LeaveAttachment> addAttachment(
    String leaveId,
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
        leaveId,
        name,
        url,
        type,
        size,
        user,
      );

      final leaveIndex = _leaves.indexWhere((l) => l.id == leaveId);
      if (leaveIndex != -1) {
        final leave = _leaves[leaveIndex];
        final attachments = List<LeaveAttachment>.from(leave.attachments ?? [])
          ..add(attachment);
        _leaves[leaveIndex] = leave.copyWith(attachments: attachments);
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

  // Add comment to leave
  Future<LeaveComment> addComment(
    String leaveId,
    String content,
    User user,
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final comment = await _service.addComment(
        leaveId,
        content,
        user,
      );

      final leaveIndex = _leaves.indexWhere((l) => l.id == leaveId);
      if (leaveIndex != -1) {
        final leave = _leaves[leaveIndex];
        final comments = List<LeaveComment>.from(leave.comments ?? [])
          ..add(comment);
        _leaves[leaveIndex] = leave.copyWith(comments: comments);
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

  // Set status filter
  void setStatusFilter(LeaveStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  // Set type filter
  void setTypeFilter(LeaveType? type) {
    _filterType = type;
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
    _filterType = null;
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
