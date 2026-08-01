import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../models/feedback_model.dart';
import '../../utils/app_colors.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});
  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _textCtrl = TextEditingController();
  final _firestore = FirestoreService();
  final _auth = AuthService();
  int _rating = 0;
  String _service = 'Road Maintenance';
  bool _submitting = false;

  final List<String> _services = [
    'Road Maintenance',
    'Waste Collection',
    'Water Supply',
    'Public Transport',
    'Street Lighting',
    'Parks & Recreation',
  ];
  final List<String> _starLabels = [
    '',
    'Poor',
    'Fair',
    'Good',
    'Very Good',
    'Excellent'
  ];

  void _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please give a rating'),
          backgroundColor: AppColors.danger));
      return;
    }
    if (_textCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please write your feedback'),
          backgroundColor: AppColors.danger));
      return;
    }
    setState(() => _submitting = true);
    final user = FirebaseAuth.instance.currentUser!;
    final userData = await _auth.getUserData(user.uid);
    final feedback = FeedbackModel(
      id: const Uuid().v4(),
      service: _service,
      rating: _rating,
      text: _textCtrl.text.trim(),
      userName: userData?.name ?? '',
      userEmail: userData?.email ?? user.email ?? '',
      createdAt: DateTime.now(),
    );
    await _firestore.addFeedback(feedback);
    setState(() => _submitting = false);
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🙏', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            const Text('Thank You!',
                style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text('Your feedback has been submitted.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecond)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
              child: const Text('Done', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    const Text('Give Feedback',
                        style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SERVICE',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textThird,
                              letterSpacing: 0.8)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border)),
                        child: DropdownButton<String>(
                          value: _service,
                          isExpanded: true,
                          dropdownColor: AppColors.surface,
                          underline: const SizedBox(),
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontSize: 14),
                          items: _services
                              .map((s) =>
                                  DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (v) => setState(() => _service = v!),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('RATING',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textThird,
                              letterSpacing: 0.8)),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(
                            5,
                            (i) => GestureDetector(
                                  onTap: () => setState(() => _rating = i + 1),
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Text(i < _rating ? '★' : '☆',
                                        style: TextStyle(
                                            fontSize: 32,
                                            color: i < _rating
                                                ? Colors.amber
                                                : AppColors.textThird)),
                                  ),
                                )),
                      ),
                      if (_rating > 0)
                        Text(_starLabels[_rating],
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecond)),
                      const SizedBox(height: 20),
                      const Text('YOUR EXPERIENCE',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textThird,
                              letterSpacing: 0.8)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _textCtrl,
                        maxLines: 5,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                            hintText: 'Share your experience...'),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _submitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14))),
                          child: _submitting
                              ? const CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2)
                              : const Text('Submit Feedback',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                        ),
                      ),
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
}
