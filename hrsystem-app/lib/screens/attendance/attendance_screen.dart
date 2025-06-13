import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/attendance_card.dart';
import '../../widgets/custom_app_bar.dart';
import 'attendance_stats_widget.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    // Load attendance data when screen initializes
    Future.microtask(() {
      final provider = context.read<AttendanceProvider>();
      provider.loadAttendanceHistory();
      provider.loadAttendanceStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Attendance',
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              // TODO: Implement calendar view
            },
          ),
        ],
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.attendanceHistory.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.attendanceHistory.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading attendance data',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      provider.loadAttendanceHistory();
                      provider.loadAttendanceStats();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadAttendanceHistory();
              await provider.loadAttendanceStats();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Today's Attendance Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Check In',
                                style: theme.textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                provider.lastCheckIn != null
                                    ? DateFormat('HH:mm').format(provider.lastCheckIn!)
                                    : '--:--',
                                style: theme.textTheme.headlineSmall,
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'Check Out',
                                style: theme.textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                provider.lastCheckOut != null
                                    ? DateFormat('HH:mm').format(provider.lastCheckOut!)
                                    : '--:--',
                                style: theme.textTheme.headlineSmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: provider.isLoading
                            ? null
                            : () async {
                                try {
                                  if (provider.isCheckedIn) {
                                    await provider.checkOut();
                                  } else {
                                    await provider.checkIn();
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(e.toString()),
                                        backgroundColor: theme.colorScheme.error,
                                      ),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: provider.isCheckedIn
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary,
                          minimumSize: const Size(200, 48),
                        ),
                        child: Text(
                          provider.isCheckedIn ? 'Check Out' : 'Check In',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Statistics Section
                if (provider.stats != null) ...[
                  AttendanceStatsWidget(stats: provider.stats!),
                  const SizedBox(height: 24),
                ],

                // Attendance History Section
                Text(
                  'Attendance History',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                ...provider.attendanceHistory.map((attendance) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AttendanceCard(
                    date: attendance.date,
                    checkIn: attendance.checkIn,
                    checkOut: attendance.checkOut,
                    status: attendance.status,
                    notes: attendance.notes,
                  ),
                )).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
