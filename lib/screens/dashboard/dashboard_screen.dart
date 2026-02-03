import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final response = await apiService.getDashboardStats();
      setState(() => _stats = response);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to load dashboard: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _logout() {
    AuthService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  String _getPendingFees() {
    final fees = _stats?['pending_fees'];
    if (fees == null) return '0.00';
    if (fees is String) return fees;
    if (fees is double) return fees.toStringAsFixed(2);
    return fees.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: Colors.deepPurple[50],
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        'Welcome, ${AuthService.role?.toUpperCase() ?? 'User'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: const Text('School Management System'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Quick Stats',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _StatCard(
                        icon: Icons.people,
                        title: 'Students',
                        value: '${_stats?['students'] ?? 0}',
                        color: Colors.blue,
                      ),
                      _StatCard(
                        icon: Icons.person,
                        title: 'Teachers',
                        value: '${_stats?['teachers'] ?? 0}',
                        color: Colors.green,
                      ),
                      _StatCard(
                        icon: Icons.class_,
                        title: 'Classes',
                        value: '${_stats?['classes'] ?? 0}',
                        color: Colors.orange,
                      ),
                      _StatCard(
                        icon: Icons.attach_money,
                        title: 'Pending Fees',
                        value: '\$${_getPendingFees()}',
                        color: Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Today\'s Attendance',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green, size: 40),
                              const SizedBox(height: 8),
                              Text(
                                '${_stats?['attendance_today']?['present'] ?? 0}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const Text('Present'),
                            ],
                          ),
                          Column(
                            children: [
                              const Icon(Icons.cancel, color: Colors.red, size: 40),
                              const SizedBox(height: 8),
                              Text(
                                '${_stats?['attendance_today']?['absent'] ?? 0}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const Text('Absent'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _QuickActionButton(
                        icon: Icons.people,
                        label: 'Students',
                        onTap: () => Navigator.pushNamed(context, '/students'),
                      ),
                      _QuickActionButton(
                        icon: Icons.person,
                        label: 'Teachers',
                        onTap: () => Navigator.pushNamed(context, '/teachers'),
                      ),
                      _QuickActionButton(
                        icon: Icons.class_,
                        label: 'Classes',
                        onTap: () => Navigator.pushNamed(context, '/classes'),
                      ),
                      _QuickActionButton(
                        icon: Icons.grade,
                        label: 'Grades',
                        onTap: () => Navigator.pushNamed(context, '/grades'),
                      ),
                      _QuickActionButton(
                        icon: Icons.check_circle,
                        label: 'Attendance',
                        onTap: () => Navigator.pushNamed(context, '/attendance'),
                      ),
                      _QuickActionButton(
                        icon: Icons.receipt,
                        label: 'Fees',
                        onTap: () => Navigator.pushNamed(context, '/fees'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
