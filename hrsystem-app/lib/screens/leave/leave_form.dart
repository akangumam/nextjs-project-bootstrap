import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/leave.dart';
import '../../models/user.dart';
import '../../providers/leave_provider.dart';

class LeaveForm extends StatefulWidget {
  final Leave? leave;

  const LeaveForm({
    super.key,
    this.leave,
  });

  @override
  State<LeaveForm> createState() => _LeaveFormState();
}

class _LeaveFormState extends State<LeaveForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _startDate;
  late DateTime _endDate;
  late LeaveType _type;
  late bool _isHalfDay;
  String? _notes;
  double _durationInDays = 1.0;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.leave?.title);
    _descriptionController = TextEditingController(text: widget.leave?.description);
    _startDate = widget.leave?.startDate ?? DateTime.now();
    _endDate = widget.leave?.endDate ?? DateTime.now();
    _type = widget.leave?.type ?? LeaveType.annual;
    _isHalfDay = widget.leave?.isHalfDay ?? false;
    _notes = widget.leave?.notes;
    _durationInDays = widget.leave?.durationInDays ?? 1.0;
    _calculateDuration();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _calculateDuration() {
    if (_isHalfDay) {
      _durationInDays = 0.5;
    } else {
      _durationInDays = _endDate.difference(_startDate).inDays + 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.leave != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Leave' : 'New Leave'),
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
            Text(
              'Leave Type',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SegmentedButton<LeaveType>(
              segments: LeaveType.values.map((type) {
                return ButtonSegment<LeaveType>(
                  value: type,
                  label: Text(type.toString().split('.').last),
                  icon: Icon(type.getTypeIcon()),
                );
              }).toList(),
              selected: {_type},
              onSelectionChanged: (Set<LeaveType> selection) {
                setState(() {
                  _type = selection.first;
                });
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
                        'Start Date',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectStartDate(context),
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
                                DateFormat('MMM d, yyyy').format(_startDate),
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
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'End Date',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectEndDate(context),
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
                                DateFormat('MMM d, yyyy').format(_endDate),
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
            SwitchListTile(
              title: const Text('Half Day'),
              subtitle: Text(
                'Duration: ${_durationInDays.toStringAsFixed(1)} days',
                style: theme.textTheme.bodySmall,
              ),
              value: _isHalfDay,
              onChanged: (value) {
                setState(() {
                  _isHalfDay = value;
                  _calculateDuration();
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _notes,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                _notes = value;
              },
            ),
            const SizedBox(height: 16),
            if (widget.leave?.attachments?.isNotEmpty == true) ...[
              Text(
                'Attachments',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...widget.leave!.attachments!.map((attachment) {
                return ListTile(
                  leading: const Icon(Icons.attach_file),
                  title: Text(attachment.name),
                  subtitle: Text(
                    _formatFileSize(attachment.size),
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
            ],
            ElevatedButton.icon(
              onPressed: _addAttachment,
              icon: const Icon(Icons.attach_file),
              label: const Text('Add Attachment'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
        _calculateDuration();
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _calculateDuration();
      });
    }
  }

  void _addAttachment() {
    // TODO: Implement file attachment
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<LeaveProvider>();
      
      // Dummy user for now
      final user = User(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        role: 'employee',
      );

      final leave = Leave(
        id: widget.leave?.id ?? 'temp_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text,
        description: _descriptionController.text,
        startDate: _startDate,
        endDate: _endDate,
        type: _type,
        status: widget.leave?.status ?? LeaveStatus.draft,
        submittedBy: user,
        submittedAt: widget.leave?.submittedAt ?? DateTime.now(),
        durationInDays: _durationInDays,
        isHalfDay: _isHalfDay,
        notes: _notes,
        attachments: widget.leave?.attachments,
        comments: widget.leave?.comments,
      );

      try {
        if (widget.leave != null) {
          await provider.updateLeave(leave);
        } else {
          await provider.createLeave(leave);
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
