import 'package:mobile/models/mailModel.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter/material.dart';

class MailApi extends ChangeNotifier {
  final String baseUrl = "https://collegebuddy-service.onrender.com";
  final FlutterSecureStorage storage = FlutterSecureStorage();
  bool _isFiltering = false;
  bool get isFiltering => _isFiltering;

 Future<List<MailModel>?> fetchUserMails() async {
    print("[MAIL API] fetchUserMails called");
    final url = "$baseUrl/api/scrape/gmail";
    try {
      final accessToken = await storage.read(key: "access_token");
      if (accessToken == null || accessToken.isEmpty) {
        print("[MAIL API] Access token not found or empty");
        return null;
      }
      print("[MAIL API] Access token successfully extracted");
      final finalUrl = Uri.parse(url);
      print("[MAIL API] Sending POST request to $finalUrl");
      final response = await http.post(
        finalUrl,
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json"
        },
      );
      print("[MAIL API] Response status code: ${response.statusCode}");
      print("[MAIL API] Response body preview: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}");
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final mailResults = (decoded["messages"] as List)
          .map((mail) => MailModel.fromJson(mail as Map<String, dynamic>))
          .toList();
        print("[MAIL API] Successfully fetched ${mailResults.length} mails");
        return mailResults.cast<MailModel>();
      } else {
        print("[MAIL API] Failed to fetch mails: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("[MAIL API] Error fetching mails: $e");
      return null;
    }
  }

  Future<String?> startMailFilterStreamJob() async {
    final url = "$baseUrl/api/scrape/gmail/stream/start";
    try {
      final accessToken = await storage.read(key: "access_token");
      if (accessToken == null || accessToken.isEmpty) {
        return null;
      }
      final resp = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
      );
      if (resp.statusCode != 200) return null;
      final decoded = json.decode(resp.body) as Map<String, dynamic>;
      return decoded["job_id"] as String?;
    } catch (e) {
      print("[MAIL API] Error starting stream job: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> pollMailFilterStreamJob(String jobId) async {
    final url = "$baseUrl/api/scrape/gmail/stream/poll?job_id=${Uri.encodeComponent(jobId)}";
    try {
      final accessToken = await storage.read(key: "access_token");
      if (accessToken == null || accessToken.isEmpty) {
        return null;
      }
      final resp = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
      );
      if (resp.statusCode != 200) return null;
      return json.decode(resp.body) as Map<String, dynamic>;
    } catch (e) {
      print("[MAIL API] Error polling stream job: $e");
      return null;
    }
  }

  Stream<List<MailModel>> streamFilteredMails({int minBatchToEmit = 5}) async* {
    _isFiltering = true;
    notifyListeners();

    final jobId = await startMailFilterStreamJob();
    if (jobId == null || jobId.isEmpty) {
      _isFiltering = false;
      notifyListeners();
      yield <MailModel>[];
      return;
    }

    var lastCount = 0;
    while (true) {
      final polled = await pollMailFilterStreamJob(jobId);
      if (polled == null) {
        await Future.delayed(const Duration(seconds: 1));
        continue;
      }

      final done = polled["done"] == true;
      final err = polled["error"] as String?;
      if (err != null && err.isNotEmpty) {
        _isFiltering = false;
        notifyListeners();
        yield <MailModel>[];
        return;
      }

      final messagesRaw = polled["messages"];
      final List<dynamic> list = messagesRaw is List ? messagesRaw : <dynamic>[];
      final mails = list
          .map((m) => MailModel.fromJson(m as Map<String, dynamic>))
          .toList();

      if (mails.length != lastCount) {
        lastCount = mails.length;
        if (mails.length >= minBatchToEmit || done) {
          yield mails;
        }
      }

      if (done) break;
      await Future.delayed(const Duration(seconds: 1));
    }

    _isFiltering = false;
    notifyListeners();
  }
}
