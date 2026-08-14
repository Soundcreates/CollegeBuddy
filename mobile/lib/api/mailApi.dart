import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:CollegeBuddy/api/backend_session.dart';
import 'package:CollegeBuddy/models/mailModel.dart';

class MailApi extends ChangeNotifier {
  MailApi({BackendSession? session}) : session = session ?? BackendSession();

  final BackendSession session;
  String get baseUrl => session.baseUrl;

  bool _isFiltering = false;
  bool get isFiltering => _isFiltering;

  Future<List<MailModel>?> fetchUserMails() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/scrape/gmail'),
        headers: await session.headers(),
      );
      await session.captureResponseToken(response);
      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final messages = decoded['messages'] ?? decoded['all_filtered'];
      if (messages is! List) return <MailModel>[];
      return messages
          .whereType<Map>()
          .map((mail) => MailModel.fromJson(Map<String, dynamic>.from(mail)))
          .toList();
    } catch (error) {
      debugPrint('Mail fetch failed: $error');
      return null;
    }
  }

  Future<MailModel?> fetchMessage(String id) async {
    if (id.isEmpty) return null;
    try {
      final uri = Uri.parse(
        '$baseUrl/api/scrape/gmail/message',
      ).replace(queryParameters: {'id': id});
      final response = await http.get(uri, headers: await session.headers());
      await session.captureResponseToken(response);
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final result =
          decoded['message'] ?? decoded['messages'] ?? decoded['all_filtered'];
      if (result is Map) {
        return MailModel.fromJson(Map<String, dynamic>.from(result));
      }
      if (result is List && result.isNotEmpty && result.first is Map) {
        return MailModel.fromJson(
          Map<String, dynamic>.from(result.first as Map),
        );
      }
      return null;
    } catch (error) {
      debugPrint('Message fetch failed: $error');
      return null;
    }
  }

  Future<String?> startMailFilterStreamJob() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/scrape/gmail/stream/start'),
        headers: await session.headers(),
      );
      await session.captureResponseToken(response);
      if (response.statusCode != 200) return null;
      return (jsonDecode(response.body) as Map<String, dynamic>)['job_id']
          ?.toString();
    } catch (error) {
      debugPrint('Mail stream start failed: $error');
      return null;
    }
  }

  Future<Map<String, dynamic>?> pollMailFilterStreamJob(String jobId) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/api/scrape/gmail/stream/poll',
      ).replace(queryParameters: {'job_id': jobId});
      final response = await http.get(uri, headers: await session.headers());
      await session.captureResponseToken(response);
      if (response.statusCode != 200) return null;
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (error) {
      debugPrint('Mail stream poll failed: $error');
      return null;
    }
  }

  Stream<List<MailModel>> streamFilteredMails({int minBatchToEmit = 5}) async* {
    _isFiltering = true;
    notifyListeners();
    try {
      final jobId = await startMailFilterStreamJob();
      if (jobId == null || jobId.isEmpty) {
        yield <MailModel>[];
        return;
      }

      var lastCount = 0;
      while (true) {
        final payload = await pollMailFilterStreamJob(jobId);
        if (payload == null) {
          await Future<void>.delayed(const Duration(seconds: 1));
          continue;
        }
        final messages = (payload['messages'] as List? ?? const [])
            .whereType<Map>()
            .map((mail) => MailModel.fromJson(Map<String, dynamic>.from(mail)))
            .toList();
        final done = payload['done'] == true;
        final error = payload['error']?.toString() ?? '';
        if (error.isNotEmpty) {
          yield <MailModel>[];
          return;
        }
        if (messages.length != lastCount &&
            (messages.length >= minBatchToEmit || done)) {
          lastCount = messages.length;
          yield messages;
        }
        if (done) return;
        await Future<void>.delayed(const Duration(seconds: 1));
      }
    } finally {
      _isFiltering = false;
      notifyListeners();
    }
  }
}
