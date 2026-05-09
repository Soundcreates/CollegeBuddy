import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/models/classroomModel.dart';

class ClassroomApi extends ChangeNotifier {
  final String baseUrl = "https://kisha-volcanologic-motherly.ngrok-free.dev";
  final FlutterSecureStorage storage = FlutterSecureStorage();

  bool _isLoadingCourses = false;
  bool get isLoadingCourses => _isLoadingCourses;

  bool _isLoadingAssignments = false;
  bool get isLoadingAssignments => _isLoadingAssignments;

  bool _isLoadingAIHelp = false;
  bool get isLoadingAIHelp => _isLoadingAIHelp;

  Future<Map<String, String>> _authHeaders() async {
    final accessToken = await storage.read(key: "access_token");
    return {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    };
  }

  /// Fetch all active courses
  Future<List<CourseModel>> fetchCourses() async {
    print("[CLASSROOM API] fetchCourses called");
    _isLoadingCourses = true;
    notifyListeners();

    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse("$baseUrl/api/classroom/courses"),
        headers: headers,
      );

      print("[CLASSROOM API] Courses response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final coursesRaw = decoded['courses'] as List? ?? [];
        return coursesRaw
            .map((c) => CourseModel.fromJson(c as Map<String, dynamic>))
            .toList();
      } else {
        print("[CLASSROOM API] Failed: ${response.body}");
        return [];
      }
    } catch (e) {
      print("[CLASSROOM API] Error fetching courses: $e");
      return [];
    } finally {
      _isLoadingCourses = false;
      notifyListeners();
    }
  }

  /// Fetch assignments for a specific course
  Future<List<AssignmentModel>> fetchCourseAssignments(String courseId) async {
    print("[CLASSROOM API] fetchCourseAssignments for $courseId");
    _isLoadingAssignments = true;
    notifyListeners();

    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse(
            "$baseUrl/api/classroom/course/assignments?course_id=$courseId"),
        headers: headers,
      );

      print("[CLASSROOM API] Assignments response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final assignmentsRaw = decoded['assignments'] as List? ?? [];
        return assignmentsRaw
            .map((a) => AssignmentModel.fromJson(a as Map<String, dynamic>))
            .toList();
      } else {
        print("[CLASSROOM API] Failed: ${response.body}");
        return [];
      }
    } catch (e) {
      print("[CLASSROOM API] Error fetching assignments: $e");
      return [];
    } finally {
      _isLoadingAssignments = false;
      notifyListeners();
    }
  }

  /// Fetch ALL assignments across all courses
  Future<List<AssignmentModel>> fetchAllAssignments() async {
    print("[CLASSROOM API] fetchAllAssignments called");
    _isLoadingAssignments = true;
    notifyListeners();

    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse("$baseUrl/api/classroom/assignments"),
        headers: headers,
      );

      print("[CLASSROOM API] All assignments response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final assignmentsRaw = decoded['assignments'] as List? ?? [];
        return assignmentsRaw
            .map((a) =>
                AssignmentModel.fromGlobalJson(a as Map<String, dynamic>))
            .toList();
      } else {
        print("[CLASSROOM API] Failed: ${response.body}");
        return [];
      }
    } catch (e) {
      print("[CLASSROOM API] Error fetching all assignments: $e");
      return [];
    } finally {
      _isLoadingAssignments = false;
      notifyListeners();
    }
  }

  /// Get AI help for an assignment
  Future<AIHelpResponse?> getAIHelp({
    required String title,
    String description = '',
    String fileUrl = '',
  }) async {
    print("[CLASSROOM API] getAIHelp called for: $title");
    _isLoadingAIHelp = true;
    notifyListeners();

    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse("$baseUrl/api/classroom/ai-help"),
        headers: headers,
        body: json.encode({
          "title": title,
          "description": description,
          "file_url": fileUrl,
        }),
      );

      print("[CLASSROOM API] AI help response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return AIHelpResponse.fromJson(decoded);
      } else {
        print("[CLASSROOM API] AI help failed: ${response.body}");
        return AIHelpResponse(
          success: false,
          error: "Server error: ${response.statusCode}",
        );
      }
    } catch (e) {
      print("[CLASSROOM API] Error getting AI help: $e");
      return AIHelpResponse(
        success: false,
        error: e.toString(),
      );
    } finally {
      _isLoadingAIHelp = false;
      notifyListeners();
    }
  }

  /// Get the attachment download proxy URL
  String getAttachmentProxyUrl(String originalUrl) {
    return "$baseUrl/api/classroom/attachment?url=${Uri.encodeComponent(originalUrl)}";
  }
}
