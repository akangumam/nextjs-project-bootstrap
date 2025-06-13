import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/leave.dart';
import '../../providers/leave_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/leave_card.dart';
import 'leave_stats_widget.dart';
import 'leave_form.dart';
import 'leave_detail_screen.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = context.read<LeaveProvider>();
      provider.loadLeaves();
      provider.loadLeaveStats();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: _isSearching ? null : 'Leave',
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                    context.read<LeaveProvider>().setSearchQuery(null);
                  });
                },
              )
            : null,
        titleWidget: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search leave...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                ),
                onChanged: (value) {
                  context.read<LeaveProvider>().setSearchQuery(value);
                },
                autofocus: true,
              )
            : null,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.clear : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  context.read<LeaveProvider>().setSearchQuery(null);
                }
              });
            },
          ),
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                _showFilterBottomSheet(context);
              },
            ),
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () {
                _showDateRangePicker(context);
              },
            ),
        ],
      ),
      body: Consumer<LeaveProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.leaves.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.leaves.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading leaves',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      provider.loadLeaves();
                      provider.loadLeaveStats();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadLeaves();
              await provider.loadLeaveStats();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (!_isSearching && provider.stats != null) ...[
                  LeaveStatsWidget(stats: provider.stats!),
                  const SizedBox(height: 24),
                ],

                // Filter Chips
                if (!_isSearching)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...LeaveStatus.values.map((status) {
                          final isSelected = provider.filterStatus == status;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              selected: isSelected,
                              label: Text(
                                _getStatusText(status),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: isSelected
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                              onSelected: (selected) {
                                provider.setStatusFilter(selected ? status : null);
                                provider.loadLeaves();
                              },
                            ),
                          );
                        }).toList(),
                        if (_startDate != null && _endDate != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              selected: true,
                              label: Text(
                                '${DateFormat('MMM d').format(_startDate!)} - ${DateFormat('MMM d').format(_endDate!)}',
                              ),
                              onSelected: (_) {
                                _showDateRangePicker(context);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Leaves List
                ...provider.leaves.map((leave) => LeaveCard(
                  leave: leave,
                  onTap: () => _showLeaveDetails(context, leave),
                  onEdit: () => _showEditLeave(context, leave),
                  onDelete: () => _confirmDeleteLeave(context, leave),
                )).toList(),

                if (provider.leaves.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 48,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No leaves found',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Apply for a new leave to get started',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateLeave(context),
        icon: const Icon(Icons.add),
        label: const Text('New Leave'),
      ),
    );
  }

  String _getStatusText(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.draft:
        return 'Draft';
      case LeaveStatus.pending:
        return 'Pending';
      case LeaveStatus.approved:
        return 'Approved';
      case LeaveStatus.rejected:
        return 'Rejected';
      case LeaveStatus.cancelled:
        return 'Cancelled';
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Consumer<LeaveProvider>(
          builder: (context, provider, child) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Leaves',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Leave Type',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: LeaveType.values.map((type) {
                      return FilterChip(
                        selected: provider.filterType == type,
                        label: Text(type.toString().split('.').last),
                        onSelected: (selected) {
                          provider.setTypeFilter(selected ? type : null);
                          provider.loadLeaves();
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          provider.clearFilters();
                          provider.loadLeaves();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear Filters'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      
      if (!mounted) return;
      
      context.read<LeaveProvider>()
        ..setDateRange(_startDate, _endDate)
        ..loadLeaves()
        ..loadLeaveStats();
    }
  }

  void _showLeaveDetails(BuildContext context, Leave leave) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LeaveDetailScreen(leave: leave),
      ),
    );
  }

  void _showCreateLeave(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LeaveForm(),
      ),
    );
  }

  void _showEditLeave(BuildContext context, Leave leave) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LeaveForm(leave: leave),
      ),
    );
  }

  void _confirmDeleteLeave(BuildContext context, Leave leave) {
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
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
