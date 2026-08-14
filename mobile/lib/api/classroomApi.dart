import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:CollegeBuddy/api/backend_session.dart';
import 'package:CollegeBuddy/models/classroomModel.dart';

class ClassroomApi extends ChangeNotifier {
  ClassroomApi({BackendSession? session})
    : session = session ?? BackendSession();

  final BackendSession session;
  String get baseUrl => session.baseUrl;

  bool _isLoadingCourses = false;
  bool get isLoadingCourses => _isLoadingCourses;
  bool _isLoadingAssignments = false;
  bool get isLoadingAssignments => _isLoadingAssignments;
  bool _isLoadingAIHelp = false;
  bool get isLoadingAIHelp => _isLoadingAIHelp;

  Future<List<CourseModel>> fetchCourses({bool refresh = false}) async {
    _isLoadingCourses = true;
    notifyListeners();
    try {
      final uri = Uri.parse(
        '$baseUrl/api/classroom/courses',
      ).replace(queryParameters: refresh ? {'refresh': 'true'} : null);
      final response = await http.get(uri, headers: await session.headers());
      await session.captureResponseToken(response);
      if (response.statusCode != 200) return [];
      final courses =
          (jsonDecode(response.body) as Map<String, dynamic>)['courses'];
      if (courses is! List) return [];
      return courses
          .whereType<Map>()
          .map(
            (course) => CourseModel.fromJson(Map<String, dynamic>.from(course)),
          )
          .toList();
    } catch (error) {
      debugPrint('Course fetch failed: $error');
      return [];
    } finally {
      _isLoadingCourses = false;
      notifyListeners();
    }
  }

  Future<List<AssignmentModel>> fetchCourseAssignments(String courseId) async {
    _isLoadingAssignments = true;
    notifyListeners();
    try {
      final uri = Uri.parse(
        '$baseUrl/api/classroom/course/assignments',
      ).replace(queryParameters: {'course_id': courseId});
      final response = await http.get(uri, headers: await session.headers());
      await session.captureResponseToken(response);
      if (response.statusCode != 200) return [];
      final assignments =
          (jsonDecode(response.body) as Map<String, dynamic>)['assignments'];
      if (assignments is! List) return [];
      return assignments
          .whereType<Map>()
          .map(
            (assignment) =>
                AssignmentModel.fromJson(Map<String, dynamic>.from(assignment)),
          )
          .toList();
    } catch (error) {
      debugPrint('Course assignments fetch failed: $error');
      return [];
    } finally {
      _isLoadingAssignments = false;
      notifyListeners();
    }
  }

  Future<List<AssignmentModel>> fetchAllAssignments() async {
    _isLoadingAssignments = true;
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/classroom/assignments'),
        headers: await session.headers(),
      );
      await session.captureResponseToken(response);
      if (response.statusCode != 200) return [];
      final assignments =
          (jsonDecode(response.body) as Map<String, dynamic>)['assignments'];
      if (assignments is! List) return [];
      return assignments
          .whereType<Map>()
          .map(
            (assignment) => AssignmentModel.fromGlobalJson(
              Map<String, dynamic>.from(assignment),
            ),
          )
          .toList();
    } catch (error) {
      debugPrint('Assignment fetch failed: $error');
      return [];
    } finally {
      _isLoadingAssignments = false;
      notifyListeners();
    }
  }

  Future<AIHelpResponse> getAIHelp({
    required String title,
    String description = '',
    String fileUrl = '',
  }) async {
    _isLoadingAIHelp = true;
    notifyListeners();
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/classroom/ai-help'),
            headers: await session.headers(),
            body: jsonEncode({
              'title': title,
              'description': description,
              'file_url': fileUrl,
            }),
          )
          .timeout(const Duration(seconds: 120));
      await session.captureResponseToken(response);
      if (response.statusCode != 200) {
        return AIHelpResponse(
          success: false,
          error: 'Server error: ${response.statusCode}',
        );
      }
      return AIHelpResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } catch (error) {
      return AIHelpResponse(success: false, error: error.toString());
    } finally {
      _isLoadingAIHelp = false;
      notifyListeners();
    }
  }

  Future<String?> downloadAttachment({
    required String originalUrl,
    required String filename,
    ValueChanged<double>? onProgress,
  }) async {
    try {
      final request = http.Request(
        'GET',
        Uri.parse(
          '$baseUrl/api/classroom/attachment',
        ).replace(queryParameters: {'url': originalUrl}),
      )..headers.addAll(await session.headers(json: false));
      final response = await request.send().timeout(
        const Duration(seconds: 120),
      );
      await session.captureResponseToken(response);
      if (response.statusCode != 200) return null;

      final directory = await getApplicationDocumentsDirectory();
      final downloadsDirectory = Directory('${directory.path}/CollegeBuddy');
      await downloadsDirectory.create(recursive: true);
      final safeFilename = filename.replaceAll(RegExp(r'[^\w\s\-.]'), '_');
      final path = '${downloadsDirectory.path}/$safeFilename';
      final file = File(path);
      final sink = file.openWrite();
      var received = 0;
      final length = response.contentLength ?? 0;
      try {
        await for (final chunk in response.stream) {
          sink.add(chunk);
          received += chunk.length;
          if (length > 0) onProgress?.call(received / length);
        }
      } finally {
        await sink.close();
      }
      return path;
    } catch (error) {
      debugPrint('Attachment download failed: $error');
      return null;
    }
  }

  String getAttachmentProxyUrl(String originalUrl) => Uri.parse(
    '$baseUrl/api/classroom/attachment',
  ).replace(queryParameters: {'url': originalUrl}).toString();
}
