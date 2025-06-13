import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../models/user.dart';
import '../../providers/task_provider.dart';

class TaskForm extends StatefulWidget {
  final Task? task;

  const TaskForm({
    super.key,
    this.task,
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _dueDate;
  late TaskPriority _priority;
  late TaskStatus _status;
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title);
    _descriptionController = TextEditingController(text: widget.task?.description);
    _dueDate = widget.task?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    _priority = widget.task?.priority ?? TaskPriority.medium;
    _status = widget.task?.status ?? TaskStatus.todo;
    _tags = widget.task?.tags?.toList() ?? [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'New Task'),
        actions: [
          TextButton(
            onPressed: _submitForm,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Due Date',
                        style: theme.textTheme.labelMedium,
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _selectDueDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.colorScheme.outline,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                                style: theme.textTheme.bodyLarge,
                              ),
                              Icon(
                                Icons.calendar_today,
                                size: 20,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Priority',
              style: theme.textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<TaskPriority>(
              segments: TaskPriority.values.map((priority) {
                return ButtonSegment<TaskPriority>(
                  value: priority,
                  label: Text(priority.toString().split('.').last),
                );
              }).toList(),
              selected: {_priority},
              onSelectionChanged: (Set<TaskPriority> selection) {
                setState(() {
                  _priority = selection.first;
                });
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Status',
              style: theme.textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<TaskStatus>(
              segments: TaskStatus.values.map((status) {
                return ButtonSegment<TaskStatus>(
                  value: status,
                  label: Text(status.toString().split('.').last),
                );
              }).toList(),
              selected: {_status},
              onSelectionChanged: (Set<TaskStatus> selection) {
                setState(() {
                  _status = selection.first;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Tags',
                  style: theme.textTheme.labelMedium,
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _addTag,
                  child: const Text('Add Tag'),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              children: [
                ..._tags.map((tag) => Chip(
                  label: Text(tag),
                  onDeleted: () {
                    setState(() {
                      _tags.remove(tag);
                    });
                  },
                )).toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _addTag() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Tag'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Tag Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    _tags.add(controller.text);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<TaskProvider>();
      
      // Dummy user for now
      final user = User(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        role: 'employee',
      );

      final task = Task(
        id: widget.task?.id ?? 'temp_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text,
        description: _descriptionController.text,
        createdAt: widget.task?.createdAt ?? DateTime.now(),
        dueDate: _dueDate,
        priority: _priority,
        status: _status,
        assignedTo: user,
        createdBy: user,
        tags: _tags,
      );

      try {
        if (widget.task != null) {
          await provider.updateTask(task);
        } else {
          await provider.createTask(task);
        }
        if (mounted) {
          Navigator.pop(context);
        }
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
}
