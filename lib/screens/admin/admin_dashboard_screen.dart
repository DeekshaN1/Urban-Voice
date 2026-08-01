import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../services/email_service.dart';
import '../../models/report_model.dart';
import '../../models/feedback_model.dart';
import '../../utils/app_colors.dart';
import '../auth/login_screen.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  final _firestore = FirestoreService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.accent3.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.accent3.withOpacity(0.3)),
                      ),
                      child: const Center(
                          child: Text('🛡️', style: TextStyle(fontSize: 20))),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Admin Panel',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.textThird)),
                          Text('Urban Voice',
                              style: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen())),
                      icon: const Icon(Icons.logout, color: AppColors.danger),
                      style: IconButton.styleFrom(
                          backgroundColor: AppColors.danger.withOpacity(0.1)),
                    ),
                  ],
                ),
              ),

              // Stats
              StreamBuilder<List<ReportModel>>(
                stream: _firestore.getAllReports(),
                builder: (context, snap) {
                  final reports = snap.data ?? [];
                  final resolved =
                      reports.where((r) => r.status == 'Resolved ✅').length;
                  final pending = reports.length - resolved;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _statCard(
                            '${reports.length}', 'Total', AppColors.accent),
                        const SizedBox(width: 8),
                        _statCard('$pending', 'Pending', AppColors.warning),
                        const SizedBox(width: 8),
                        _statCard('$resolved', 'Resolved', AppColors.success),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecond,
                  labelStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: 'Reports'),
                    Tab(text: 'Feedbacks'),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Reports Tab
                    StreamBuilder<List<ReportModel>>(
                      stream: _firestore.getAllReports(),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.accent));
                        }
                        final reports = snap.data ?? [];
                        if (reports.isEmpty) {
                          return const Center(
                              child: Text('No reports yet.',
                                  style:
                                      TextStyle(color: AppColors.textThird)));
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: reports.length,
                          itemBuilder: (_, i) => _reportCard(reports[i]),
                        );
                      },
                    ),

                    // Feedbacks Tab
                    StreamBuilder<List<FeedbackModel>>(
                      stream: _firestore.getAllFeedbacks(),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.accent));
                        }
                        final feedbacks = snap.data ?? [];
                        if (feedbacks.isEmpty) {
                          return const Center(
                              child: Text('No feedbacks yet.',
                                  style:
                                      TextStyle(color: AppColors.textThird)));
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: feedbacks.length,
                          itemBuilder: (_, i) => _feedbackCard(feedbacks[i]),
                        );
                      },
                    ),
                  ],
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
        padding: const EdgeInsets.symmetric(vertical: 12),
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
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: color)),
            Text(label,
                style:
                    const TextStyle(fontSize: 11, color: AppColors.textThird)),
          ],
        ),
      ),
    );
  }

  Widget _reportCard(ReportModel r) {
    Color statusColor;
    if (r.status == 'Resolved ✅') {
      statusColor = AppColors.success;
    } else if (r.status == 'Under Process') {
      statusColor = AppColors.accent;
    } else {
      statusColor = AppColors.warning;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('${r.category} · #${r.id}',
                    style: const TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(r.status,
                    style: TextStyle(fontSize: 10, color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(r.description,
              style:
                  const TextStyle(fontSize: 12, color: AppColors.textSecond)),
          const SizedBox(height: 4),
          Text('👤 ${r.userName} · ${r.userEmail}',
              style: const TextStyle(fontSize: 11, color: AppColors.textThird)),
          Text(
              '📅 ${r.createdAt.toString().substring(0, 16)} · ${r.priority} priority',
              style: const TextStyle(fontSize: 11, color: AppColors.textThird)),
          const SizedBox(height: 10),

          // Status update buttons
          Row(
            children: [
              _statusBtn('🔄 Processing', 'Under Process', AppColors.accent, r),
              const SizedBox(width: 6),
              _statusBtn('⏳ Pending', 'Yet to be Solved', AppColors.warning, r),
              const SizedBox(width: 6),
              _statusBtn('✅ Resolve', 'Resolved ✅', AppColors.success, r),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBtn(String label, String status, Color color, ReportModel r) {
    final isActive = r.status == status;
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          await _firestore.updateReportStatus(r.id, status);
          // Send status update email
          await EmailService.sendStatusUpdate(
            userName: r.userName,
            userEmail: r.userEmail,
            reportId: r.id,
            category: r.category,
            newStatus: status,
            date: DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()),
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Status updated to $status'),
                backgroundColor: AppColors.success));
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.15) : AppColors.surface2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isActive ? color : AppColors.border),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 9,
                  color: isActive ? color : AppColors.textThird,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal)),
        ),
      ),
    );
  }

  Widget _feedbackCard(FeedbackModel f) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(f.service,
                    style: const TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
              ),
              Text('★' * f.rating + '☆' * (5 - f.rating),
                  style: const TextStyle(fontSize: 14, color: Colors.amber)),
            ],
          ),
          const SizedBox(height: 6),
          Text(f.text,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecond, height: 1.5)),
          if (f.userName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('— ${f.userName}',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textThird)),
            ),
        ],
      ),
    );
  }
}
