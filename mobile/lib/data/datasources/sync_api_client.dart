import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/domain/entities/assignment_entity.dart';
import 'package:mobile/domain/entities/mail_entity.dart';
import 'package:mobile/domain/entities/course_entity.dart';
import 'package:mobile/models/classroomModel.dart';
import 'package:mobile/models/mailModel.dart';

/// Response object returned by the /sync endpoint.
class SyncResponse {
  final List<AssignmentEntity> deadlines;
  final List<MailEntity> announcements;
  final List<CourseEntity> courses;
  final DateTime serverTime;

  const SyncResponse({
    required this.deadlines,
    required this.announcements,
    required this.courses,
    required this.serverTime,
  });
}

/// Calls the backend /sync endpoint and parses the response into domain
/// entities. This class owns the HTTP concern; it knows nothing about SQLite.
class SyncApiClient {
  final String baseUrl;
  final FlutterSecureStorage _storage;
  final http.Client _client;

  SyncApiClient({
    required this.baseUrl,
    FlutterSecureStorage? storage,
    http.Client? client,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _client = client ?? http.Client();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.read(key: 'access_token');
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Fetches delta data from the backend since [since].
  /// Passing null returns all records (used on first launch).
  Future<SyncResponse> fetchDelta({DateTime? since}) async {
    final uri = Uri.parse('$baseUrl/api/sync').replace(
      queryParameters: since != null
          ? {'since': since.toUtc().toIso8601String()}
          : null,
    );

    final headers = await _authHeaders();
    final response = await _client
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw SyncException(
        'Sync HTTP ${response.statusCode}: ${response.body}',
        statusCode: response.statusCode,
      );
    }

    return _parseResponse(response.body);
  }

  SyncResponse _parseResponse(String body) {
    final json = jsonDecode(body) as Map<String, dynamic>;

    final serverTime = DateTime.parse(json['server_time'] as String);
    final now = DateTime.now();

    // ── Deadlines (assignments) ─────────────────────────────────────────────
    final deadlinesRaw = json['deadlines'] as List? ?? [];
    final deadlines = deadlinesRaw.map((raw) {
      final m = Map<String, dynamic>.from(raw as Map);
      final materialsRaw = m['materials'] as List? ?? [];
      return AssignmentEntity(
        id: (m['id'] ?? '').toString(),
        title: (m['title'] ?? '').toString(),
        description: (m['description'] ?? '').toString(),
        state: (m['state'] ?? '').toString(),
        dueDate: (m['due_date'] ?? '').toString(),
        creationTime: (m['creation_time'] ?? '').toString(),
        updateTime: (m['update_time'] ?? '').toString(),
        maxPoints: (m['max_points'] ?? 0).toDouble(),
        workType: (m['work_type'] ?? '').toString(),
        alternateLink: (m['alternate_link'] ?? '').toString(),
        courseId: (m['course_id'] ?? '').toString(),
        courseName: (m['course_name'] ?? '').toString(),
        materials: materialsRaw
            .map((e) => MaterialModel.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ))
            .toList(),
        cachedAt: now,
      );
    }).toList();

    // ── Announcements (mails) ───────────────────────────────────────────────
    final announcementsRaw = json['announcements'] as List? ?? [];
    final announcements = announcementsRaw.map((raw) {
      final m = Map<String, dynamic>.from(raw as Map);
      final attachmentsRaw = (m['attachments'] ?? m['attatchments']) as List? ?? [];
      final serverCreatedAt = m['server_created_at'] != null
          ? DateTime.tryParse(m['server_created_at'].toString()) ?? now
          : now;

      return MailEntity(
        id: (m['id'] ?? '').toString(),
        threadId: (m['thread_id'] ?? '').toString(),
        subject: (m['subject'] ?? '').toString(),
        from: (m['from'] ?? '').toString(),
        to: (m['to'] ?? '').toString(),
        date: (m['date'] ?? '').toString(),
        snippet: (m['snippet'] ?? '').toString(),
        body: (m['body'] ?? '').toString(),
        attachments: attachmentsRaw
            .map((e) => AttachmentModel.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ))
            .toList(),
        serverCreatedAt: serverCreatedAt,
        cachedAt: now,
      );
    }).toList();

    // ── Courses ─────────────────────────────────────────────────────────────
    final coursesRaw = json['courses'] as List? ?? [];
    final courses = coursesRaw.map((raw) {
      final m = Map<String, dynamic>.from(raw as Map);
      return CourseEntity(
        id: (m['id'] ?? '').toString(),
        name: (m['name'] ?? '').toString(),
        section: (m['section'] ?? '').toString(),
        description: (m['description'] ?? '').toString(),
        room: (m['room'] ?? '').toString(),
        enrollCode: (m['enroll_code'] ?? '').toString(),
        state: (m['state'] ?? '').toString(),
        updatedAt: serverTime,
      );
    }).toList();

    return SyncResponse(
      deadlines: deadlines,
      announcements: announcements,
      courses: courses,
      serverTime: serverTime,
    );
  }
}

class SyncException implements Exception {
  final String message;
  final int? statusCode;

  SyncException(this.message, {this.statusCode});

  @override
  String toString() => 'SyncException($statusCode): $message';
}
