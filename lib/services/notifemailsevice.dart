import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EmailServiceVer {
  // Replace these with your actual EmailJS service details
  final String serviceId = 'service_se9hvo2';
  final String templateId = 'template_4oxuev8';
  final String userId = 'gEmlKWa1cxhCjbobB';

  Future<void> sendMailVerified({
    required String recipientEmail,
    required String message,
    required String subject, // Custom subject line
  }) async {
    final Uri url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    try {
      var response = await http.post(
        url,
        headers: {
          'origin': 'http://localhost', // Required for EmailJS
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': userId,
          'template_params': {
            'message': message, // Custom message
            'to_name': recipientEmail, // Recipient email or name
            'subject': subject, // Custom subject line
          },
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Email sent successfully: ${response.body}');
      } else {
        debugPrint(
            'Failed to send email. Status code: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (error) {
      debugPrint('Error sending email: $error');
    }
  }
}
