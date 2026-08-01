import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../../models/report_model.dart';
import '../../utils/app_colors.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});
  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  final _firestore = FirestoreService();
  String _filter = 'All';
  final _filters = ['All', 'Under Process', 'Yet to be Solved', 'Resolved ✅'];

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios,
                          color: AppColors.textPrimary),
                      style: IconButton.styleFrom(
                          backgroundColor: AppColors.surface),
                    ),
                    const SizedBox(width: 12),
                    const Text('My Reports',
                        style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                  ],
                ),
              ),

              // Filter tabs
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filters.length,
                  itemBuilder: (_, i) {
                    final sel = _filter == _filters[i];
                    return GestureDetector(
                      onTap: () => setState(() => _filter = _filters[i]),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                            color: sel ? AppColors.accent : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color:
                                    sel ? AppColors.accent : AppColors.border)),
                        child: Text(_filters[i],
                            style: TextStyle(
                                fontSize: 12,
                                color:
                                    sel ? Colors.white : AppColors.textSecond,
                                fontWeight:
                                    sel ? FontWeight.w600 : FontWeight.normal)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: StreamBuilder<List<ReportModel>>(
                  stream: _firestore.getUserReports(uid),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.accent));
                    }
                    var reports = snap.data ?? [];
                    if (_filter != 'All') {
                      reports =
                          reports.where((r) => r.status == _filter).toList();
                    }
                    if (reports.isEmpty) {
                      return const Center(
                          child: Text('No reports found.',
                              style: TextStyle(
                                  color: AppColors.textThird, fontSize: 14)));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: reports.length,
                      itemBuilder: (_, i) => _reportCard(reports[i]),
                    );
                  },
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.all(16),
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
                child: Text(r.category,
                    style: const TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          const SizedBox(height: 8),
          Text(r.description,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecond, height: 1.5)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time,
                  size: 12, color: AppColors.textThird),
              const SizedBox(width: 4),
              Text(r.createdAt.toString().substring(0, 16),
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textThird)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent3.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(r.priority,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.accent3)),
              ),
            ],
          ),
          if (r.latitude != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  const Icon(Icons.location_on,
                      size: 12, color: AppColors.textThird),
                  const SizedBox(width: 4),
                  Text(
                      '${r.latitude!.toStringAsFixed(4)}, ${r.longitude!.toStringAsFixed(4)}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textThird)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
