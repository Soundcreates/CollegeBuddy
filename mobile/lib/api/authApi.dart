import 'dart:async';
import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:CollegeBuddy/api/backend_session.dart';
import 'package:CollegeBuddy/models/userModel.dart';

class AuthApi extends ChangeNotifier {
  AuthApi._internal();

  static final AuthApi _instance = AuthApi._internal();
  factory AuthApi() => _instance;

  final AppLinks _appLinks = AppLinks();
  final BackendSession session = BackendSession();
  StreamSubscription<Uri>? _deepLinkSubscription;
  bool _deepLinksInitialized = false;

  bool isLoading = false;
  String get baseUrl => session.baseUrl;

  void initDeepLinks(BuildContext context) {
    if (_deepLinksInitialized) return;
    _deepLinksInitialized = true;
    _deepLinkSubscription = _appLinks.allUriLinkStream.listen(
      (uri) => _handleCallback(uri, context),
      onError: (Object error) => debugPrint('Deep-link error: $error'),
    );
  }

  Future<void> _handleCallback(Uri uri, BuildContext context) async {
    if (uri.scheme != 'collegebuddy' || uri.host != 'auth') return;
    if (uri.queryParameters['success'] != 'true') return;

    final accessToken = uri.queryParameters['access_token'];
    if (accessToken == null || accessToken.isEmpty) return;

    await session.saveTokens(
      accessToken: accessToken,
      refreshToken: uri.queryParameters['refresh_token'],
      email: uri.queryParameters['user_email'],
    );
    notifyListeners();

    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/main');
    }
  }

  Future<void> startGoogleOauth() async {
    isLoading = true;
    notifyListeners();
    try {
      final uri = Uri.parse(
        '$baseUrl/api/auth/OAuth',
      ).replace(queryParameters: {'state': 'kjssecodecell'});
      final response = await http.get(uri).timeout(const Duration(seconds: 20));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('OAuth request failed (${response.statusCode})');
      }
      final authUrl =
          (jsonDecode(response.body) as Map<String, dynamic>)['oauth_url']
              ?.toString();
      if (authUrl == null || authUrl.isEmpty)
        throw Exception('Backend returned no OAuth URL');
      final launched = await launchUrl(
        Uri.parse(authUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!launched) throw Exception('Could not open Google sign-in');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<UserModel?> get currentUser async {
    final token = await session.accessToken;
    if (token == null || token.isEmpty) return null;

    try {
      final uri = Uri.parse(
        '$baseUrl/api/auth/get-profile',
      ).replace(queryParameters: {'token': token});
      var response = await http.get(uri).timeout(const Duration(seconds: 20));
      if (response.statusCode == 401 && await session.refreshAccessToken()) {
        response = await http.get(uri).timeout(const Duration(seconds: 20));
      }
      await session.captureResponseToken(response);
      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final user = decoded['user'];
      if (user is! Map) return null;
      return UserModel.fromJson(Map<String, dynamic>.from(user));
    } catch (error) {
      debugPrint('Profile fetch failed: $error');
      return null;
    }
  }

  Future<void> logout() async {
    await session.clear();
    notifyListeners();
  }

  Future<void> disposeDeepLinks() async {
    await _deepLinkSubscription?.cancel();
    _deepLinkSubscription = null;
    _deepLinksInitialized = false;
  }
}
