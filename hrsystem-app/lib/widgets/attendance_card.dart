import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceCard extends StatelessWidget {
  final DateTime date;
  final DateTime checkIn;
  final DateTime? checkOut;
  final String? notes;
  final AttendanceStatus status;

  const AttendanceCard({
    super.key,
    required this.date,
    required this.checkIn,
    this.checkOut,
    this.notes,
    this.status = AttendanceStatus.present,
  });

  Color _getStatusColor(BuildContext context) {
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

  String _getStatusText() {
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

  String _formatDuration() {
    if (checkOut == null) return '--:--';
    final duration = checkOut!.difference(checkIn);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE, d MMMM').format(date),
                  style: theme.textTheme.titleMedium,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: _getStatusColor(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Check In',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('HH:mm').format(checkIn),
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Check Out',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      checkOut != null
                          ? DateFormat('HH:mm').format(checkOut!)
                          : '--:--',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Duration',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDuration(),
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ],
            ),
            if (notes != null) ...[
              const SizedBox(height: 12),
              Text(
                'Notes:',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                notes!,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum AttendanceStatus {
  present,
  late,
  absent,
  leave,
}
