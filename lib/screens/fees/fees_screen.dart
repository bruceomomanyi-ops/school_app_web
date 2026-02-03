import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/api_service.dart';
import '../../models/fee.dart';

class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  bool _isLoading = true;
  List<dynamic> _fees = [];
  String _selectedStatus = '';
  String _selectedYear = '2024-2025';
  final List<String> _statuses = ['', 'pending', 'partial', 'paid'];

  bool get _isAdmin => ApiService.role == 'admin' || ApiService.role == 'teacher';
  bool get _canManageFees => _isAdmin;

  @override
  void initState() {
    super.initState();
    _loadFees();
  }

  Future<void> _loadFees() async {
    setState(() => _isLoading = true);
    try {
      int? studentId;
      // Parents and students can only see their own fees
      if (!_isAdmin) {
        studentId = ApiService.userId;
      }
      
      final response = await apiService.getFees(
        studentId: studentId,
        academicYear: _selectedYear,
        status: _selectedStatus.isEmpty ? null : _selectedStatus,
      );
      setState(() => _fees = response);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to load fees: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showFeeDialog() {
    final studentIdController = TextEditingController();
    final feeTypeController = TextEditingController();
    final amountController = TextEditingController();
    final dueDateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Fee'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: studentIdController,
                decoration: const InputDecoration(labelText: 'Student ID'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: feeTypeController,
                decoration: const InputDecoration(labelText: 'Fee Type'),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: dueDateController,
                decoration: const InputDecoration(labelText: 'Due Date (YYYY-MM-DD)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'student_id': int.tryParse(studentIdController.text) ?? 0,
                'fee_type': feeTypeController.text,
                'amount': double.tryParse(amountController.text) ?? 0,
                'due_date': dueDateController.text,
                'academic_year': _selectedYear,
              };

              try {
                await apiService.createFee(data);
                Fluttertoast.showToast(
                  msg: 'Fee created successfully',
                  backgroundColor: Colors.green,
                );
                Navigator.pop(context);
                _loadFees();
              } catch (e) {
                Fluttertoast.showToast(
                  msg: e.toString(),
                  backgroundColor: Colors.red,
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(Fee fee) {
    final amountController = TextEditingController(
      text: fee.balance.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Student: ${fee.studentName}'),
            Text('Fee Type: ${fee.feeType}'),
            Text('Total: \$${fee.amount.toStringAsFixed(2)}'),
            Text('Paid: \$${(fee.paidAmount ?? 0).toStringAsFixed(2)}'),
            Text('Balance: \$${fee.balance.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Payment Amount'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await apiService.payFee(
                  fee.feeId!,
                  double.tryParse(amountController.text) ?? 0,
                );
                Fluttertoast.showToast(
                  msg: 'Payment recorded successfully',
                  backgroundColor: Colors.green,
                );
                Navigator.pop(context);
                _loadFees();
              } catch (e) {
                Fluttertoast.showToast(
                  msg: e.toString(),
                  backgroundColor: Colors.red,
                );
              }
            },
            child: const Text('Pay'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'partial':
        return Colors.orange;
      case 'pending':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fees'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFees,
          ),
        ],
      ),
      floatingActionButton: _canManageFees
          ? FloatingActionButton(
              onPressed: _showFeeDialog,
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Academic Year'),
                    controller: TextEditingController(text: _selectedYear),
                    onChanged: (value) {
                      _selectedYear = value;
                      _loadFees();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: _statuses.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.isEmpty ? 'All' : status.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedStatus = value ?? '');
                      _loadFees();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _fees.isEmpty
                    ? const Center(child: Text('No fees found'))
                    : ListView.builder(
                        itemCount: _fees.length,
                        itemBuilder: (context, index) {
                          final fee = Fee.fromJson(_fees[index]);
                          final statusColor = _getStatusColor(fee.paymentStatus);
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text('${fee.studentName} - ${fee.feeType}'),
                                  subtitle: Text('Due: ${fee.dueDate}'),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      fee.paymentStatus.toUpperCase(),
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Paid: \$${(fee.paidAmount ?? 0).toStringAsFixed(2)}'),
                                          Text('Total: \$${fee.amount.toStringAsFixed(2)}'),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      LinearProgressIndicator(
                                        value: fee.paymentPercentage / 100,
                                        minHeight: 8,
                                        backgroundColor: Colors.grey[200],
                                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                                      ),
                                      const SizedBox(height: 8),
                                      if (fee.paymentStatus != 'paid')
                                        ElevatedButton(
                                          onPressed: () => _showPaymentDialog(fee),
                                          child: const Text('Record Payment'),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
