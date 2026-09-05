import 'dart:async';
import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:CollegeBuddy/api/backend_session.dart';
import 'package:CollegeBuddy/cache/BigDataRepository.dart';
import 'package:CollegeBuddy/models/userModel.dart';

/// Root navigator used for OAuth deep-link redirects (avoids stale BuildContext).
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AuthApi extends ChangeNotifier {
  AuthApi._internal();

  static final AuthApi _instance = AuthApi._internal();
  factory AuthApi() => _instance;

  final AppLinks _appLinks = AppLinks();
  final BackendSession session = BackendSession();
  StreamSubscription<Uri>? _deepLinkSubscription;
  bool _deepLinksInitialized = false;

  bool isLoading = false;

  /// True while the external Google browser flow is in progress.
  bool oauthInProgress = false;

  /// Set when the OAuth deep link successfully stores tokens.
  bool isAuthenticated = false;

  String get baseUrl => session.baseUrl;

  void initDeepLinks() {
    if (_deepLinksInitialized) return;
    _deepLinksInitialized = true;

    // Merges cold-start initial link + runtime stream.
    _deepLinkSubscription = _appLinks.allUriLinkStream.listen(
      _handleCallback,
      onError: (Object error) => debugPrint('Deep-link error: $error'),
    );
  }

  Future<void> _handleCallback(Uri uri) async {
    if (uri.scheme != 'collegebuddy' || uri.host != 'auth') return;
    if (uri.queryParameters['success'] != 'true') return;

    final accessToken = uri.queryParameters['access_token'];
    if (accessToken == null || accessToken.isEmpty) return;

    await session.saveTokens(
      accessToken: accessToken,
      refreshToken: uri.queryParameters['refresh_token'],
      email: uri.queryParameters['user_email'],
    );

    // Drop any failed/null profile from a previous session so home refetches.
    BigDataRepository().clearUserCache();

    oauthInProgress = false;
    isAuthenticated = true;
    isLoading = false;
    notifyListeners();

    // Clear the stack so we never flash /login after a successful OAuth return.
    appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/main',
      (route) => false,
    );
  }

  Future<void> startGoogleOauth() async {
    isLoading = true;
    oauthInProgress = true;
    notifyListeners();
    try {
      final uri = Uri.parse(
        '$baseUrl/api/auth/OAuth',
      ).replace(queryParameters: {'state': 'kjssecodecell'});
      final response = await http
          .get(
            uri,
            headers: const {'ngrok-skip-browser-warning': 'true'},
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('OAuth request failed (${response.statusCode})');
      }
      final authUrl =
          (jsonDecode(response.body) as Map<String, dynamic>)['oauth_url']
              ?.toString();
      if (authUrl == null || authUrl.isEmpty) {
        throw Exception('Backend returned no OAuth URL');
      }
      final launched = await launchUrl(
        Uri.parse(authUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!launched) throw Exception('Could not open Google sign-in');
    } catch (error) {
      oauthInProgress = false;
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<UserModel?> get currentUser async {
    final token = await session.accessToken;
    if (token == null || token.isEmpty) return null;

    try {
      Future<http.Response> fetch(String accessToken) {
        final uri = Uri.parse('$baseUrl/api/auth/get-profile').replace(
          queryParameters: {'token': accessToken},
        );
        return http
            .get(uri, headers: {
              'ngrok-skip-browser-warning': 'true',
              'Authorization': 'Bearer $accessToken',
            })
            .timeout(const Duration(seconds: 20));
      }

      var response = await fetch(token);
      if (response.statusCode == 401 && await session.refreshAccessToken()) {
        final refreshed = await session.accessToken;
        if (refreshed != null && refreshed.isNotEmpty) {
          response = await fetch(refreshed);
        }
      }
      await session.captureResponseToken(response);
      if (response.statusCode != 200) {
        debugPrint(
          'Profile fetch failed: HTTP ${response.statusCode} ${response.body}',
        );
        return null;
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final user = decoded['user'];
      if (user is! Map) return null;
      isAuthenticated = true;
      return UserModel.fromJson(Map<String, dynamic>.from(user));
    } catch (error) {
      debugPrint('Profile fetch failed: $error');
      return null;
    }
  }

  Future<void> logout() async {
    await session.clear();
    isAuthenticated = false;
    oauthInProgress = false;
    notifyListeners();
  }

  Future<void> disposeDeepLinks() async {
    await _deepLinkSubscription?.cancel();
    _deepLinkSubscription = null;
    _deepLinksInitialized = false;
  }
}
