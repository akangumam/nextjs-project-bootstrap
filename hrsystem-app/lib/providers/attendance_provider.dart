import 'package:flutter/material.dart';
import '../models/attendance.dart';
import '../services/attendance_service.dart';

class AttendanceProvider with ChangeNotifier {
  final AttendanceService _service = AttendanceService();
  
  List<Attendance> _attendanceHistory = [];
  AttendanceStats? _stats;
  bool _isLoading = false;
  String? _error;
  bool _isCheckedIn = false;
  DateTime? _lastCheckIn;
  DateTime? _lastCheckOut;

  // Getters
  List<Attendance> get attendanceHistory => _attendanceHistory;
  AttendanceStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isCheckedIn => _isCheckedIn;
  DateTime? get lastCheckIn => _lastCheckIn;
  DateTime? get lastCheckOut => _lastCheckOut;

  // Load attendance history
  Future<void> loadAttendanceHistory() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, 1);
      final endDate = DateTime(now.year, now.month + 1, 0);

      _attendanceHistory = await _service.getAttendanceHistory(
        startDate: startDate,
        endDate: endDate,
      );

      // Update check-in status based on today's attendance
      final todayAttendance = _attendanceHistory.firstWhere(
        (attendance) => 
          attendance.date.year == now.year &&
          attendance.date.month == now.month &&
          attendance.date.day == now.day,
        orElse: () => Attendance(
          id: '',
          date: now,
          checkIn: now,
          status: AttendanceStatus.absent,
        ),
      );

      _isCheckedIn = todayAttendance.checkIn != null && 
                     todayAttendance.checkOut == null;
      _lastCheckIn = todayAttendance.checkIn;
      _lastCheckOut = todayAttendance.checkOut;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load attendance statistics
  Future<void> loadAttendanceStats() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final now = DateTime.now();
      _stats = await _service.getAttendanceStats(
        month: DateTime(now.year, now.month),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check in
  Future<void> checkIn() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.checkIn();
      
      _isCheckedIn = true;
      _lastCheckIn = DateTime.now();
      
      await loadAttendanceHistory(); // Refresh attendance history
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Check out
  Future<void> checkOut() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _service.checkOut();
      
      _isCheckedIn = false;
      _lastCheckOut = DateTime.now();
      
      await loadAttendanceHistory(); // Refresh attendance history
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
