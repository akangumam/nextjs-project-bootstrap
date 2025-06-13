import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';
import '../../providers/task_provider.dart';
import '../../widgets/custom_app_bar.dart';
import 'task_form.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Task Details',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editTask(context),
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
                  task.title,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: task.getStatusColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  task.getStatusText(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: task.getStatusColor(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Priority and Due Date
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: task.getPriorityColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  task.getPriorityText(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: task.getPriorityColor(context),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.calendar_today,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                DateFormat('MMM d, yyyy').format(task.dueDate),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
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
            task.description,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Tags
          if (task.tags != null && task.tags!.isNotEmpty) ...[
            Text(
              'Tags',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: task.tags!.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '#$tag',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Assigned To
          Text(
            'Assigned To',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundImage: task.assignedTo.photoUrl != null
                  ? NetworkImage(task.assignedTo.photoUrl!)
                  : null,
              child: task.assignedTo.photoUrl == null
                  ? Text(task.assignedTo.name[0])
                  : null,
            ),
            title: Text(task.assignedTo.name),
            subtitle: Text(task.assignedTo.position ?? 'No position'),
          ),
          const SizedBox(height: 24),

          // Comments
          Text(
            'Comments',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (task.comments != null && task.comments!.isNotEmpty)
            ...task.comments!.map((comment) => _CommentItem(comment: comment))
          else
            Text(
              'No comments yet',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 16),
          _AddCommentField(taskId: task.id),
          const SizedBox(height: 24),

          // Attachments
          if (task.attachments != null && task.attachments!.isNotEmpty) ...[
            Text(
              'Attachments',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...task.attachments!.map((attachment) => _AttachmentItem(
              attachment: attachment,
            )),
          ],
        ],
      ),
    );
  }

  void _editTask(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskForm(task: task),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<TaskProvider>().deleteTask(task.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to task list
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  final TaskComment comment;

  const _CommentItem({required this.comment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
                      DateFormat('MMM d, yyyy HH:mm').format(comment.createdAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
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
    );
  }
}

class _AttachmentItem extends StatelessWidget {
  final TaskAttachment attachment;

  const _AttachmentItem({required this.attachment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.attach_file),
      title: Text(attachment.name),
      subtitle: Text(
        _formatFileSize(attachment.size),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.download),
        onPressed: () {
          // TODO: Implement file download
        },
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class _AddCommentField extends StatefulWidget {
  final String taskId;

  const _AddCommentField({required this.taskId});

  @override
  State<_AddCommentField> createState() => _AddCommentFieldState();
}

class _AddCommentFieldState extends State<_AddCommentField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Add a comment...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: _controller.text.isEmpty ? null : _submitComment,
        ),
      ],
    );
  }

  void _submitComment() async {
    if (_controller.text.isEmpty) return;

    try {
      // Dummy user for now
      final user = User(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        role: 'employee',
      );

      await context.read<TaskProvider>().addComment(
        widget.taskId,
        _controller.text,
        user,
      );

      _controller.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
