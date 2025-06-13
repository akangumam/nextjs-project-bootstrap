import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/custom_app_bar.dart';
import 'expense_form.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final Expense expense;

  const ExpenseDetailScreen({
    super.key,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Expense Details',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editExpense(context),
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
                  expense.title,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: expense.getStatusColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  expense.getStatusText(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: expense.getStatusColor(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Amount and Category
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(expense.amount),
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
                    'Category',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        expense.getCategoryIcon(),
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        expense.getCategoryText(),
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
            expense.description,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Merchant and Receipt
          if (expense.merchantName != null || expense.receiptNumber != null) ...[
            Text(
              'Receipt Details',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (expense.merchantName != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.store),
                title: const Text('Merchant'),
                subtitle: Text(expense.merchantName!),
              ),
            if (expense.receiptNumber != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.receipt),
                title: const Text('Receipt Number'),
                subtitle: Text(expense.receiptNumber!),
              ),
            const SizedBox(height: 16),
          ],

          // Date and Submission Info
          Text(
            'Submission Details',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today),
            title: const Text('Expense Date'),
            subtitle: Text(DateFormat('MMMM d, yyyy').format(expense.date)),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.person),
            title: const Text('Submitted By'),
            subtitle: Text(expense.submittedBy.name),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.access_time),
            title: const Text('Submitted On'),
            subtitle: Text(
              DateFormat('MMMM d, yyyy HH:mm').format(expense.submittedAt),
            ),
          ),
          if (expense.approvedBy != null) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.check_circle),
              title: const Text('Approved By'),
              subtitle: Text(expense.approvedBy!.name),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time),
              title: const Text('Approved On'),
              subtitle: Text(
                DateFormat('MMMM d, yyyy HH:mm').format(expense.approvedAt!),
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Notes
          if (expense.notes != null) ...[
            Text(
              'Notes',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              expense.notes!,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
          ],

          // Attachments
          if (expense.attachments != null && expense.attachments!.isNotEmpty) ...[
            Text(
              'Attachments',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...expense.attachments!.map((attachment) => ListTile(
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
          ],
        ],
      ),
      bottomNavigationBar: expense.status == ExpenseStatus.draft
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => _submitExpense(context),
                  child: const Text('Submit Expense'),
                ),
              ),
            )
          : null,
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

  void _editExpense(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseForm(expense: expense),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text('Are you sure you want to delete "${expense.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ExpenseProvider>().deleteExpense(expense.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to expense list
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _submitExpense(BuildContext context) {
    final updatedExpense = expense.copyWith(
      status: ExpenseStatus.submitted,
      submittedAt: DateTime.now(),
    );
    
    context.read<ExpenseProvider>().updateExpense(updatedExpense).then((_) {
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
