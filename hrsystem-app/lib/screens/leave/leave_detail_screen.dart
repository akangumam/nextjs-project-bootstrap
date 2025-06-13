import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/leave.dart';
import '../../providers/leave_provider.dart';
import '../../widgets/custom_app_bar.dart';
import 'leave_form.dart';

class LeaveDetailScreen extends StatelessWidget {
  final Leave leave;

  const LeaveDetailScreen({
    super.key,
    required this.leave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Leave Details',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editLeave(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Title and Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  leave.title,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: leave.getStatusColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  leave.getStatusText(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: leave.getStatusColor(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Duration and Type
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Duration',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${leave.durationInDays} ${leave.durationInDays == 1 ? 'day' : 'days'}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Type',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        leave.getTypeIcon(),
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        leave.getTypeText(),
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Description
          Text(
            'Description',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            leave.description,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Date Range
          Text(
            'Leave Period',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today),
            title: Text(
              _formatDateRange(leave.startDate, leave.endDate),
            ),
            subtitle: leave.isHalfDay ? const Text('Half Day') : null,
          ),
          const SizedBox(height: 16),

          // Submission Info
          Text(
            'Submission Details',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.person),
            title: const Text('Submitted By'),
            subtitle: Text(leave.submittedBy.name),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.access_time),
            title: const Text('Submitted On'),
            subtitle: Text(
              DateFormat('MMMM d, yyyy HH:mm').format(leave.submittedAt),
            ),
          ),
          if (leave.approvedBy != null) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.check_circle),
              title: const Text('Approved By'),
              subtitle: Text(leave.approvedBy!.name),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time),
              title: const Text('Approved On'),
              subtitle: Text(
                DateFormat('MMMM d, yyyy HH:mm').format(leave.approvedAt!),
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Notes
          if (leave.notes != null) ...[
            Text(
              'Notes',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              leave.notes!,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
          ],

          // Attachments
          if (leave.attachments != null && leave.attachments!.isNotEmpty) ...[
            Text(
              'Attachments',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...leave.attachments!.map((attachment) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.attach_file),
              title: Text(attachment.name),
              subtitle: Text(_formatFileSize(attachment.size)),
              trailing: IconButton(
                icon: const Icon(Icons.download),
                onPressed: () {
                  // TODO: Implement file download
                },
              ),
            )),
            const SizedBox(height: 24),
          ],

          // Comments
          Text(
            'Comments',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (leave.comments != null && leave.comments!.isNotEmpty)
            ...leave.comments!.map((comment) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: comment.createdBy.photoUrl != null
                              ? NetworkImage(comment.createdBy.photoUrl!)
                              : null,
                          child: comment.createdBy.photoUrl == null
                              ? Text(comment.createdBy.name[0])
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                comment.createdBy.name,
                                style: theme.textTheme.titleSmall,
                              ),
                              Text(
                                DateFormat('MMM d, yyyy HH:mm')
                                    .format(comment.createdAt),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(comment.content),
                  ],
                ),
              ),
            ))
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No comments yet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: leave.status == LeaveStatus.draft
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => _submitLeave(context),
                  child: const Text('Submit Leave'),
                ),
              ),
            )
          : null,
    );
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final startFormat = DateFormat('MMM d');
    final endFormat = DateFormat('MMM d, yyyy');
    
    if (start.year == end.year && start.month == end.month) {
      if (start.day == end.day) {
        return endFormat.format(start);
      }
      return '${startFormat.format(start)} - ${endFormat.format(end)}';
    }
    return '${endFormat.format(start)} - ${endFormat.format(end)}';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  void _editLeave(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LeaveForm(leave: leave),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Leave'),
        content: Text('Are you sure you want to delete "${leave.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<LeaveProvider>().deleteLeave(leave.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to leave list
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _submitLeave(BuildContext context) {
    final updatedLeave = leave.copyWith(
      status: LeaveStatus.pending,
      submittedAt: DateTime.now(),
    );
    
    context.read<LeaveProvider>().updateLeave(updatedLeave).then((_) {
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    });
  }
}
