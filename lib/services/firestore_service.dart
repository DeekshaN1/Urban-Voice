import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';
import '../models/feedback_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addReport(ReportModel report) async {
    await _db.collection('reports').doc(report.id).set(report.toMap());
  }

  Stream<List<ReportModel>> getUserReports(String userId) {
    return _db
        .collection('reports')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ReportModel.fromMap(d.data())).toList());
  }

  Stream<List<ReportModel>> getAllReports() {
    return _db
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ReportModel.fromMap(d.data())).toList());
  }

  Future<void> updateReportStatus(String id, String status) async {
    await _db.collection('reports').doc(id).update({'status': status});
  }

  Future<void> addFeedback(FeedbackModel feedback) async {
    await _db.collection('feedbacks').doc(feedback.id).set(feedback.toMap());
  }

  Stream<List<FeedbackModel>> getAllFeedbacks() {
    return _db
        .collection('feedbacks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => FeedbackModel.fromMap(d.data())).toList());
  }
}
