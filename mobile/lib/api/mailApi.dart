import 'package:mobile/models/mailModel.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter/material.dart';

class MailApi extends ChangeNotifier {
  final String baseUrl = "https://collegebuddy-service.onrender.com";
  final FlutterSecureStorage storage = FlutterSecureStorage();

 Future<List<MailModel>?> fetchUserMails() async {
    print("Fetching user mails");
    final url = "$baseUrl/scrape/gmail";
    try {
      final accessToken = await storage.read(key: "access_token");
      if (accessToken == null || accessToken.isEmpty) {
        print("Access token not found or empty");
        return null;
      }
      print("Access token successfully extracted");
      final finalUrl = Uri.parse(url);
      final response = await http.post(
        finalUrl,
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json"
        },
      );
      print("Response statuscode: ${response.statusCode}");
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final mailResults = (decoded["messages"] as List)
          .map((mail) => MailModel.fromJson(mail as Map<String, dynamic>))
          .toList();
        print("Successfully fetched mails");
        return mailResults.cast<MailModel>();
      } else {
        print("Failed to fetch mails: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching mails: $e");
      return null;
    }
  }
}
