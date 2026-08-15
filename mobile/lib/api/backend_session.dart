import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class BackendSession {
  BackendSession({FlutterSecureStorage? storage})
    : storage = storage ?? const FlutterSecureStorage();

  // ponytail: emulator-only fallback; real devices/CI must supply BACKEND_BASE_URL via --dart-define
  static const defaultBaseUrl = 'http://10.0.2.2:8080';
  static const accessTokenKey = 'access_token';
  static const refreshTokenKey = 'refresh_token';
  static const userEmailKey = 'user_email';

  final FlutterSecureStorage storage;

  String get baseUrl {
    const configuredUrl = String.fromEnvironment('BACKEND_BASE_URL');
    final url = configuredUrl.trim().isNotEmpty
        ? configuredUrl.trim()
        : defaultBaseUrl;
    return url.replaceFirst(RegExp(r'/+$'), '');
  }

  Future<String?> get accessToken => storage.read(key: accessTokenKey);

  Future<Map<String, String>> headers({bool json = true}) async {
    final token = await accessToken;
    return {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      if (json) 'Content-Type': 'application/json',
    };
  }

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
    String? email,
  }) async {
    await storage.write(key: accessTokenKey, value: accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await storage.write(key: refreshTokenKey, value: refreshToken);
    }
    if (email != null && email.isNotEmpty) {
      await storage.write(key: userEmailKey, value: email);
    }
  }

  Future<bool> refreshAccessToken() async {
    final refreshToken = await storage.read(key: refreshTokenKey);
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/refresh'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );
      if (response.statusCode != 200) return false;

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final accessToken = decoded['access_token']?.toString() ?? '';
      if (accessToken.isEmpty) return false;
      await saveTokens(
        accessToken: accessToken,
        refreshToken: decoded['refresh_token']?.toString(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> captureResponseToken(http.BaseResponse response) async {
    final authorization = response.headers.entries
        .where((entry) => entry.key.toLowerCase() == 'authorization')
        .map((entry) => entry.value)
        .firstOrNull;
    if (authorization == null) return;
    final token = authorization
        .replaceFirst(RegExp(r'^Bearer\s+', caseSensitive: false), '')
        .trim();
    if (token.isNotEmpty)
      await storage.write(key: accessTokenKey, value: token);
  }

  Future<void> clear() async {
    await storage.delete(key: accessTokenKey);
    await storage.delete(key: refreshTokenKey);
    await storage.delete(key: userEmailKey);
  }
}
