import 'dart:async';
import '../models/attendance.dart';

class AttendanceService {
  // Simulate API delay
  static const _delay = Duration(milliseconds: 800);

  // Simulate API calls
  Future<void> checkIn() async {
    await Future.delayed(_delay);
    // TODO: Implement actual API call
  }

  Future<void> checkOut() async {
    await Future.delayed(_delay);
    // TODO: Implement actual API call
  }

  Future<List<Attendance>> getAttendanceHistory({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await Future.delayed(_delay);
    
    // Simulate attendance history data
    final List<Attendance> history = [];
    
    for (var i = 0; i < 30; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      
      // Simulate random attendance status
      final isWeekend = date.weekday == DateTime.saturday || 
                       date.weekday == DateTime.sunday;
      
      if (!isWeekend) {
        history.add(
          Attendance(
            id: 'att_$i',
            date: date,
            checkIn: DateTime(
              date.year,
              date.month,
              date.day,
              8 + (i % 2), // Simulate different check-in times
              30,
            ),
            checkOut: DateTime(
              date.year,
              date.month,
              date.day,
              17 + (i % 2), // Simulate different check-out times
              30,
            ),
            status: i % 5 == 0 
                ? AttendanceStatus.late 
                : AttendanceStatus.present,
            notes: i % 7 == 0 ? 'Working from home' : null,
          ),
        );
      }
    }

    return history;
  }

  Future<AttendanceStats> getAttendanceStats({
    required DateTime month,
  }) async {
    await Future.delayed(_delay);
    
    // Simulate attendance statistics
    return AttendanceStats(
      totalPresent: 20,
      totalLate: 2,
      totalAbsent: 1,
      totalLeave: 1,
      averageWorkHours: 8.5,
      monthYear: month,
    );
  }
}
