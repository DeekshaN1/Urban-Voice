import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class EmailService {
  static const String _publicKey = '2qz8lXY7ZzSIBQVj2';
  static const String _privateKey = 'tY3K1e4AyG2k5oEmlh33e';
  static const String _serviceId = 'service_3l4azhc';
  static const String _userTemplate = 'template_yj0x8gt';
  static const String _adminTemplate = 'template_c7s0236';
  static const String _adminEmail = 'dikshita2450@gmail.com';

  static Future<bool> _sendEmail(
      String templateId, Map<String, dynamic> params) async {
    try {
      final response = await http
          .post(
            Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'service_id': _serviceId,
              'template_id': templateId,
              'user_id': _publicKey,
              'accessToken': _privateKey,
              'template_params': params,
            }),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint(
          'EmailJS [$templateId]: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('EmailJS Error: $e');
      return false;
    }
  }

  static Future<bool> sendUserConfirmation({
    required String userName,
    required String userEmail,
    required String reportId,
    required String category,
    required String description,
    required String priority,
    required String date,
  }) async {
    debugPrint('>>> Sending user email to: $userEmail');
    return await _sendEmail(_userTemplate, {
      'to_name': userName.isNotEmpty ? userName : userEmail,
      'to_email': userEmail,
      'report_id': reportId,
      'category': category,
      'description': description,
      'priority': priority,
      'date': date,
    });
  }

  static Future<bool> sendAdminAlert({
    required String userName,
    required String userEmail,
    required String reportId,
    required String category,
    required String description,
    required String priority,
    required String date,
  }) async {
    debugPrint('>>> Sending admin to: $_adminEmail');
    return await _sendEmail(_adminTemplate, {
      'to_email': _adminEmail,
      'user_name': userName.isNotEmpty ? userName : userEmail,
      'user_email': userEmail,
      'report_id': reportId,
      'category': category,
      'description': description,
      'priority': priority,
      'date': date,
    });
  }

  static Future<bool> sendStatusUpdate({
    required String userName,
    required String userEmail,
    required String reportId,
    required String category,
    required String newStatus,
    required String date,
  }) async {
    return await _sendEmail(_userTemplate, {
      'to_name': userName.isNotEmpty ? userName : userEmail,
      'to_email': userEmail,
      'report_id': reportId,
      'category': category,
      'description': 'Status updated to: $newStatus',
      'priority': '',
      'date': date,
    });
  }
}
