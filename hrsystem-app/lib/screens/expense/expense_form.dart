import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';
import '../../models/user.dart';
import '../../providers/expense_provider.dart';

class ExpenseForm extends StatefulWidget {
  final Expense? expense;

  const ExpenseForm({
    super.key,
    this.expense,
  });

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _merchantNameController;
  late TextEditingController _receiptNumberController;
  late DateTime _date;
  late ExpenseCategory _category;
  late bool _isReimbursable;
  String? _notes;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense?.title);
    _descriptionController = TextEditingController(text: widget.expense?.description);
    _amountController = TextEditingController(
      text: widget.expense?.amount.toString() ?? '',
    );
    _merchantNameController = TextEditingController(
      text: widget.expense?.merchantName,
    );
    _receiptNumberController = TextEditingController(
      text: widget.expense?.receiptNumber,
    );
    _date = widget.expense?.date ?? DateTime.now();
    _category = widget.expense?.category ?? ExpenseCategory.others;
    _isReimbursable = widget.expense?.isReimbursable ?? true;
    _notes = widget.expense?.notes;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _merchantNameController.dispose();
    _receiptNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.expense != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Expense' : 'New Expense'),
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
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                prefixText: '\$ ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
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
                        'Date',
                        style: theme.textTheme.labelMedium,
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _selectDate,
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
                                DateFormat('MMM d, yyyy').format(_date),
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
              'Category',
              style: theme.textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<ExpenseCategory>(
              segments: ExpenseCategory.values.map((category) {
                return ButtonSegment<ExpenseCategory>(
                  value: category,
                  label: Text(category.toString().split('.').last),
                  icon: Icon(category.getCategoryIcon()),
                );
              }).toList(),
              selected: {_category},
              onSelectionChanged: (Set<ExpenseCategory> selection) {
                setState(() {
                  _category = selection.first;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _merchantNameController,
              decoration: const InputDecoration(
                labelText: 'Merchant Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _receiptNumberController,
              decoration: const InputDecoration(
                labelText: 'Receipt Number',
                border: OutlineInputBorder(),
              ),
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
            SwitchListTile(
              title: const Text('Reimbursable'),
              value: _isReimbursable,
              onChanged: (value) {
                setState(() {
                  _isReimbursable = value;
                });
              },
            ),
            const SizedBox(height: 16),
            if (widget.expense?.attachments?.isNotEmpty == true) ...[
              Text(
                'Attachments',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...widget.expense!.attachments!.map((attachment) {
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
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
      final provider = context.read<ExpenseProvider>();
      
      // Dummy user for now
      final user = User(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        role: 'employee',
      );

      final expense = Expense(
        id: widget.expense?.id ?? 'temp_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text,
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        date: _date,
        category: _category,
        status: widget.expense?.status ?? ExpenseStatus.draft,
        submittedBy: user,
        submittedAt: widget.expense?.submittedAt ?? DateTime.now(),
        merchantName: _merchantNameController.text,
        receiptNumber: _receiptNumberController.text,
        notes: _notes,
        isReimbursable: _isReimbursable,
        attachments: widget.expense?.attachments,
      );

      try {
        if (widget.expense != null) {
          await provider.updateExpense(expense);
        } else {
          await provider.createExpense(expense);
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
