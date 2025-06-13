import 'package:flutter/material.dart';

enum AttendanceStatus {
  present,
  late,
  absent,
  leave,
}

class Attendance {
  final String id;
  final DateTime date;
  final DateTime checkIn;
  final DateTime? checkOut;
  final AttendanceStatus status;
  final String? notes;
  final String? location;

  Attendance({
    required this.id,
    required this.date,
    required this.checkIn,
    this.checkOut,
    required this.status,
    this.notes,
    this.location,
  });

  Duration get duration {
    if (checkOut == null) return Duration.zero;
    return checkOut!.difference(checkIn);
  }

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      checkIn: DateTime.parse(json['check_in'] as String),
      checkOut: json['check_out'] != null 
          ? DateTime.parse(json['check_out'] as String)
          : null,
      status: AttendanceStatus.values.firstWhere(
        (e) => e.toString() == 'AttendanceStatus.${json['status']}',
      ),
      notes: json['notes'] as String?,
      location: json['location'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'check_in': checkIn.toIso8601String(),
      'check_out': checkOut?.toIso8601String(),
      'status': status.toString().split('.').last,
      'notes': notes,
      'location': location,
    };
  }

  Color getStatusColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (status) {
      case AttendanceStatus.present:
        return theme.colorScheme.primary;
      case AttendanceStatus.late:
        return theme.colorScheme.error;
      case AttendanceStatus.absent:
        return theme.colorScheme.error;
      case AttendanceStatus.leave:
        return theme.colorScheme.tertiary;
    }
  }

  String getStatusText() {
    switch (status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.leave:
        return 'Leave';
    }
  }
}

class AttendanceStats {
  final int totalPresent;
  final int totalLate;
  final int totalAbsent;
  final int totalLeave;
  final double averageWorkHours;
  final DateTime monthYear;

  AttendanceStats({
    required this.totalPresent,
    required this.totalLate,
    required this.totalAbsent,
    required this.totalLeave,
    required this.averageWorkHours,
    required this.monthYear,
  });

  int get totalDays => totalPresent + totalLate + totalAbsent + totalLeave;

  double get presentPercentage => 
      totalDays > 0 ? (totalPresent + totalLate) / totalDays * 100 : 0;

  factory AttendanceStats.fromJson(Map<String, dynamic> json) {
    return AttendanceStats(
      totalPresent: json['total_present'] as int,
      totalLate: json['total_late'] as int,
      totalAbsent: json['total_absent'] as int,
      totalLeave: json['total_leave'] as int,
      averageWorkHours: json['average_work_hours'] as double,
      monthYear: DateTime.parse(json['month_year'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_present': totalPresent,
      'total_late': totalLate,
      'total_absent': totalAbsent,
      'total_leave': totalLeave,
      'average_work_hours': averageWorkHours,
      'month_year': monthYear.toIso8601String(),
    };
  }
}
