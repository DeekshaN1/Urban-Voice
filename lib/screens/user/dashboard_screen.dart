import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/report_model.dart';
import '../../utils/app_colors.dart';
import '../auth/login_screen.dart';
import 'report_screen.dart';
import 'track_screen.dart';
import 'feedback_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _auth = AuthService();
  final _firestore = FirestoreService();
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final data = await _auth.getUserData(user.uid);
      setState(() {
        _userName = data?.name ?? user.email ?? 'User';
      });
    }
  }

  void _logout() async {
    await _auth.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Welcome back 👋',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.textThird)),
                          Text(
                              _userName.isNotEmpty
                                  ? _userName.split(' ')[0]
                                  : 'User',
                              style: const TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: AppColors.surface,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            title: const Text('Logout',
                                style: TextStyle(
                                    fontFamily: 'SpaceGrotesk',
                                    color: AppColors.textPrimary,
                                    fontSize: 18)),
                            content: const Text(
                                'Are you sure you want to logout?',
                                style: TextStyle(
                                    color: AppColors.textSecond, fontSize: 14)),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel',
                                      style: TextStyle(
                                          color: AppColors.textThird))),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _logout();
                                  },
                                  child: const Text('Logout',
                                      style: TextStyle(
                                          color: AppColors.danger,
                                          fontWeight: FontWeight.w600))),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.danger.withOpacity(0.2)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.logout,
                                color: AppColors.danger, size: 16),
                            SizedBox(width: 6),
                            Text('Logout',
                                style: TextStyle(
                                    color: AppColors.danger,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats
                      StreamBuilder<List<ReportModel>>(
                        stream: _firestore.getUserReports(uid),
                        builder: (context, snap) {
                          final reports = snap.data ?? [];
                          final resolved = reports
                              .where((r) => r.status == 'Resolved ✅')
                              .length;
                          final pending = reports.length - resolved;
                          return Row(
                            children: [
                              _statCard('${reports.length}', 'Reports',
                                  AppColors.accent),
                              const SizedBox(width: 10),
                              _statCard(
                                  '$resolved', 'Resolved', AppColors.success),
                              const SizedBox(width: 10),
                              _statCard(
                                  '$pending', 'Pending', AppColors.warning),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Quick Actions
                      const Text('Quick Actions',
                          style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 12),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.3,
                        children: [
                          _actionCard(
                              '📍',
                              'Report Issue',
                              'Flag a problem',
                              AppColors.accent,
                              () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const ReportScreen()))),
                          _actionCard(
                              '🗺️',
                              'Track Reports',
                              'View your issues',
                              AppColors.accent3,
                              () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const TrackScreen()))),
                          _actionCard(
                              '⭐',
                              'Give Feedback',
                              'Rate services',
                              AppColors.success,
                              () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const FeedbackScreen()))),
                          _actionCard(
                              '🔔',
                              'Notifications',
                              'Status updates',
                              AppColors.warning,
                              () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const TrackScreen()))),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Recent Reports
                      const Text('Recent Activity',
                          style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 12),
                      StreamBuilder<List<ReportModel>>(
                        stream: _firestore.getUserReports(uid),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator(
                                    color: AppColors.accent));
                          }
                          final reports = snap.data ?? [];
                          if (reports.isEmpty) {
                            return Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(14),
                                    border:
                                        Border.all(color: AppColors.border)),
                                child: const Center(
                                    child: Text(
                                        'No reports yet.\nTap "Report Issue" to get started.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: AppColors.textThird,
                                            fontSize: 13))));
                          }
                          return Column(
                            children: reports
                                .take(3)
                                .map((r) => _recentItem(r))
                                .toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textThird,
                    letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(
      String emoji, String title, String sub, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const Spacer(),
            Text(title,
                style: const TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            Text(sub,
                style:
                    const TextStyle(fontSize: 11, color: AppColors.textThird)),
          ],
        ),
      ),
    );
  }

  Widget _recentItem(ReportModel r) {
    Color statusColor;
    if (r.status == 'Resolved ✅') {
      statusColor = AppColors.success;
    } else if (r.status == 'Under Process') {
      statusColor = AppColors.accent;
    } else {
      statusColor = AppColors.warning;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.category,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary)),
                Text(r.createdAt.toString().substring(0, 16),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textThird)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Text(r.status,
                style: TextStyle(
                    fontSize: 10,
                    color: statusColor,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
