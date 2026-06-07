import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../data/mock/mock_data.dart';
import '../../../../data/models/leave_model.dart';
import '../../../../core/utils/responsive_utils.dart';

/// Leave Screen - Apply for leave and view history
class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filterStatus = 'ALL';
  // Local state for leaves to simulate adding new ones
  late List<LeaveModel> _leaves;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _leaves = List.from(MockData.leaveRecords); // Initialize with mock data
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addLeave(LeaveModel leave) {
    setState(() {
      _leaves.insert(0, leave); // Add to top
      _tabController.animateTo(1); // Switch to history tab
    });
  }

  List<LeaveModel> get _filteredLeaves {
    if (_filterStatus == 'ALL') {
      return _leaves;
    }
    return _leaves.where((leave) => leave.status == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Leaves'),
      ),
      body: Column(
        children: [
          // Leave Balance Cards - Horizontal Scroll
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _LeaveBalanceCard(
                  leaveType: 'Sick Leave',
                  used: MockData.leaveBalances['SICK']!['used']!,
                  total: MockData.leaveBalances['SICK']!['total']!,
                  color: AppTheme.statusCrimson,
                ),
                const SizedBox(width: 12),
                _LeaveBalanceCard(
                  leaveType: 'Casual Leave',
                  used: MockData.leaveBalances['CASUAL']!['used']!,
                  total: MockData.leaveBalances['CASUAL']!['total']!,
                  color: AppTheme.statusAmber,
                ),
                const SizedBox(width: 12),
                _LeaveBalanceCard(
                  leaveType: 'Annual Leave',
                  used: MockData.leaveBalances['ANNUAL']!['used']!,
                  total: MockData.leaveBalances['ANNUAL']!['total']!,
                  color: AppTheme.statusGreen,
                ),
              ].animate(interval: 100.ms).fadeIn().slideX(begin: 0.2, end: 0),
            ),
          ),

          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPlum.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryPlum,
              unselectedLabelColor: AppTheme.textMuted,
              indicatorColor: AppTheme.primaryPlum,
              tabs: const [
                Tab(text: 'Apply Leave'),
                Tab(text: 'Leave History'),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Apply Leave Tab
                _ApplyLeaveTab(onSubmit: _addLeave),

                // Leave History Tab
                _LeaveHistoryTab(
                  leaves: _filteredLeaves,
                  filterStatus: _filterStatus,
                  onFilterChanged: (status) {
                    setState(() {
                      _filterStatus = status;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaveBalanceCard extends StatelessWidget {
  final String leaveType;
  final int used;
  final int total;
  final Color color;

  const _LeaveBalanceCard({
    required this.leaveType,
    required this.used,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final available = total - used;
    final percentage = used / total;

    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppTheme.cardShadow],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            leaveType,
            style: const TextStyle(
              color: AppTheme.textBody,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$available',
                style: TextStyle(
                  color: color,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '/$total',
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(4),
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}

class _ApplyLeaveTab extends StatefulWidget {
  final Function(LeaveModel) onSubmit;

  const _ApplyLeaveTab({required this.onSubmit});

  @override
  State<_ApplyLeaveTab> createState() => _ApplyLeaveTabState();
}

class _ApplyLeaveTabState extends State<_ApplyLeaveTab> {
  final _formKey = GlobalKey<FormState>();
  String _leaveType = 'SICK';
  DateTime? _fromDate;
  DateTime? _toDate;
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
          if (_toDate != null && _toDate!.isBefore(_fromDate!)) {
            _toDate = null;
          }
        } else {
          _toDate = picked;
        }
      });
    }
  }

  void _submitLeave() {
    if (_formKey.currentState!.validate() && _fromDate != null && _toDate != null) {
      final newLeave = LeaveModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'EMP001', // Mock user ID
        leaveType: _leaveType,
        fromDate: _fromDate!,
        toDate: _toDate!,
        reason: _reasonController.text,
        status: 'PENDING',
        appliedOn: DateTime.now(),
      );

      widget.onSubmit(newLeave);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Leave application submitted successfully!'),
          backgroundColor: AppTheme.statusGreen,
        ),
      );

      _formKey.currentState!.reset();
      setState(() {
        _fromDate = null;
        _toDate = null;
        _reasonController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveUtils.constrainedContent(
      context: context,
      maxWidth: 800,
      child: SingleChildScrollView(
        padding: ResponsiveUtils.padding(context, mobile: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Leave Type
            const Text(
              'Leave Type',
              style: TextStyle(
                color: AppTheme.textBody,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _leaveType,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: const [
                DropdownMenuItem(value: 'SICK', child: Text('Sick Leave')),
                DropdownMenuItem(value: 'CASUAL', child: Text('Casual Leave')),
                DropdownMenuItem(value: 'ANNUAL', child: Text('Annual Leave')),
                DropdownMenuItem(value: 'EMERGENCY', child: Text('Emergency Leave')),
              ],
              onChanged: (value) {
                setState(() {
                  _leaveType = value!;
                });
              },
            ),
            const SizedBox(height: 20),

            // From Date
            const Text(
              'From Date',
              style: TextStyle(
                color: AppTheme.textBody,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(context, true),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryPlum.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _fromDate != null
                          ? DateFormat('MMM d, y').format(_fromDate!)
                          : 'Select date',
                      style: TextStyle(
                        color: _fromDate!= null ? AppTheme.textDarkHeading : AppTheme.textMuted,
                      ),
                    ),
                    const Icon(Icons.calendar_today, color: AppTheme.primaryPlum),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // To Date
            const Text(
              'To Date',
              style: TextStyle(
                color: AppTheme.textBody,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(context, false),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryPlum.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _toDate != null
                          ? DateFormat('MMM d, y').format(_toDate!)
                          : 'Select date',
                      style: TextStyle(
                        color: _toDate != null ? AppTheme.textDarkHeading : AppTheme.textMuted,
                      ),
                    ),
                    const Icon(Icons.calendar_today, color: AppTheme.primaryPlum),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Reason
            const Text(
              'Reason',
              style: TextStyle(
                color: AppTheme.textBody,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _reasonController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Enter reason for leave...',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a reason';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitLeave,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Apply for Leave'),
              ),
            ),
           ].animate(interval: 50.ms).fadeIn().slideY(begin: 0.1, end: 0),
          ),
        ),
      ),
    );
  }
}

class _LeaveHistoryTab extends StatelessWidget {
  final List<LeaveModel> leaves;
  final String filterStatus;
  final Function(String) onFilterChanged;

  const _LeaveHistoryTab({
    required this.leaves,
    required this.filterStatus,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter Chips
        Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: filterStatus == 'ALL',
                  onTap: () => onFilterChanged('ALL'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Pending',
                  isSelected: filterStatus == 'PENDING',
                  onTap: () => onFilterChanged('PENDING'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Approved',
                  isSelected: filterStatus == 'APPROVED',
                  onTap: () => onFilterChanged('APPROVED'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Rejected',
                  isSelected: filterStatus == 'REJECTED',
                  onTap: () => onFilterChanged('REJECTED'),
                ),
              ],
            ),
          ),
        ),

        // Leave List
        Expanded(
          child: leaves.isEmpty
              ? const Center(
                  child: Text(
                    'No leave records found',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                )
              : ListView.builder(
                  padding: ResponsiveUtils.horizontalPadding(context, mobile: 20),
                  itemCount: leaves.length,
                  itemBuilder: (context, index) {
                    final leave = leaves[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.cardWhite,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [AppTheme.cardShadow],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          '${DateFormat('MMM d').format(leave.fromDate)} - ${DateFormat('MMM d, y').format(leave.toDate)}',
                          style: const TextStyle(
                            color: AppTheme.textDarkHeading,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                StatusBadge(
                                  text: leave.leaveType,
                                  type: StatusType.info,
                                ),
                                const SizedBox(width: 8),
                                StatusBadge(
                                  text: leave.status,
                                  type: leave.status == 'APPROVED'
                                      ? StatusType.success
                                      : leave.status == 'PENDING'
                                          ? StatusType.warning
                                          : StatusType.error,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              leave.reason,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.textBody,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${leave.numberOfDays} ${leave.numberOfDays == 1 ? 'day' : 'days'}',
                              style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: (50 * index).ms).slideX();
                  },
                ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPlum : AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryPlum : AppTheme.textMuted.withValues(alpha: 0.3),
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppTheme.primaryPlum.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.textLightHeading : AppTheme.textBody,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
