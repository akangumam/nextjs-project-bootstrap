import 'dart:async';
import '../models/leave.dart';
import '../models/user.dart';

class LeaveService {
  // Simulate API delay
  static const _delay = Duration(milliseconds: 800);

  // Simulate leave data
  Future<List<Leave>> getLeaves({
    LeaveStatus? status,
    LeaveType? type,
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

    // Simulate dummy leaves
    final List<Leave> leaves = List.generate(
      10,
      (index) => Leave(
        id: 'leave_$index',
        title: 'Leave Request ${index + 1}',
        description: 'Description for leave request ${index + 1}',
        startDate: DateTime.now().add(Duration(days: index * 2)),
        endDate: DateTime.now().add(Duration(days: index * 2 + 1)),
        type: LeaveType.values[index % LeaveType.values.length],
        status: LeaveStatus.values[index % LeaveStatus.values.length],
        submittedBy: dummyUser,
        submittedAt: DateTime.now().subtract(Duration(days: index)),
        approvedBy: index % 2 == 0 ? dummyUser : null,
        approvedAt: index % 2 == 0 ? DateTime.now() : null,
        durationInDays: 1.0,
        isHalfDay: index % 3 == 0,
        notes: index % 2 == 0 ? 'Additional notes for leave ${index + 1}' : null,
        attachments: index % 2 == 0
            ? [
                LeaveAttachment(
                  id: 'att_$index',
                  name: 'document_$index.pdf',
                  url: 'https://example.com/documents/$index.pdf',
                  type: 'application/pdf',
                  size: 1024 * 1024,
                  uploadedAt: DateTime.now(),
                  uploadedBy: dummyUser,
                ),
              ]
            : null,
        comments: index % 2 == 0
            ? [
                LeaveComment(
                  id: 'comment_$index',
                  content: 'Comment for leave ${index + 1}',
                  createdAt: DateTime.now(),
                  createdBy: dummyUser,
                ),
              ]
            : null,
      ),
    );

    // Apply filters if provided
    return leaves.where((leave) {
      bool matches = true;

      if (status != null) {
        matches = matches && leave.status == status;
      }

      if (type != null) {
        matches = matches && leave.type == type;
      }

      if (submittedById != null) {
        matches = matches && leave.submittedBy.id == submittedById;
      }

      if (startDate != null) {
        matches = matches && leave.startDate.isAfter(startDate);
      }

      if (endDate != null) {
        matches = matches && leave.endDate.isBefore(endDate);
      }

      return matches;
    }).toList();
  }

  Future<Leave> createLeave(Leave leave) async {
    await Future.delayed(_delay);
    // Simulate API call
    return leave.copyWith(
      id: 'leave_${DateTime.now().millisecondsSinceEpoch}',
      submittedAt: DateTime.now(),
    );
  }

  Future<Leave> updateLeave(Leave leave) async {
    await Future.delayed(_delay);
    // Simulate API call
    return leave;
  }

  Future<void> deleteLeave(String leaveId) async {
    await Future.delayed(_delay);
    // Simulate API call
  }

  Future<LeaveAttachment> addAttachment(
    String leaveId,
    String name,
    String url,
    String type,
    int size,
    User user,
  ) async {
    await Future.delayed(_delay);
    // Simulate API call
    return LeaveAttachment(
      id: 'att_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      url: url,
      type: type,
      size: size,
      uploadedAt: DateTime.now(),
      uploadedBy: user,
    );
  }

  Future<LeaveComment> addComment(
    String leaveId,
    String content,
    User user,
  ) async {
    await Future.delayed(_delay);
    // Simulate API call
    return LeaveComment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      createdAt: DateTime.now(),
      createdBy: user,
    );
  }

  Future<LeaveStats> getLeaveStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await Future.delayed(_delay);
    // Simulate API call
    return LeaveStats(
      totalLeaves: 20,
      approvedLeaves: 12,
      pendingLeaves: 5,
      rejectedLeaves: 3,
      totalDays: 30.0,
      approvedDays: 18.0,
      pendingDays: 8.0,
      rejectedDays: 4.0,
      typeBreakdown: {
        LeaveType.annual: 10.0,
        LeaveType.sick: 5.0,
        LeaveType.personal: 8.0,
        LeaveType.maternity: 0.0,
        LeaveType.paternity: 0.0,
        LeaveType.bereavement: 2.0,
        LeaveType.unpaid: 3.0,
        LeaveType.other: 2.0,
      },
      monthlyTrend: List.generate(
        6,
        (index) => MonthlyLeave(
          month: DateTime.now().subtract(Duration(days: 30 * index)),
          days: 5.0 - (index * 0.5),
          count: 5 - index,
        ),
      ),
      startDate: startDate,
      endDate: endDate,
    );
  }
}

class LeaveStats {
  final int totalLeaves;
  final int approvedLeaves;
  final int pendingLeaves;
  final int rejectedLeaves;
  final double totalDays;
  final double approvedDays;
  final double pendingDays;
  final double rejectedDays;
  final Map<LeaveType, double> typeBreakdown;
  final List<MonthlyLeave> monthlyTrend;
  final DateTime startDate;
  final DateTime endDate;

  LeaveStats({
    required this.totalLeaves,
    required this.approvedLeaves,
    required this.pendingLeaves,
    required this.rejectedLeaves,
    required this.totalDays,
    required this.approvedDays,
    required this.pendingDays,
    required this.rejectedDays,
    required this.typeBreakdown,
    required this.monthlyTrend,
    required this.startDate,
    required this.endDate,
  });

  double get approvalRate =>
      totalLeaves > 0 ? (approvedLeaves / totalLeaves * 100) : 0;

  double get averageLeaveDuration =>
      totalLeaves > 0 ? (totalDays / totalLeaves) : 0;
}

class MonthlyLeave {
  final DateTime month;
  final double days;
  final int count;

  MonthlyLeave({
    required this.month,
    required this.days,
    required this.count,
  });
}
