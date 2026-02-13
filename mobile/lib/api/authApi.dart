import 'dart:ui';
import "dart:convert";
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/models/userModel.dart';
import 'package:app_links/app_links.dart';
import 'package:url_launcher/url_launcher.dart';

class Authapi extends ChangeNotifier {
  final appLinks = AppLinks();
  bool isLoading = false;
  void initDeepLinks(BuildContext context) {
    appLinks.uriLinkStream.listen((uri) async {
      if (uri == null) return;

      print("Deep link received: $uri");
      final success = uri.queryParameters['success'];
      final accessToken = uri.queryParameters['access_token'];
      final refreshToken = uri.queryParameters['refresh_token'];
      final userEmail = uri.queryParameters['user_email'];
      //now letss store them

      final storage = FlutterSecureStorage();

      await storage.write(key: "access_token", value: accessToken);
      await storage.write(key: "refresh_token", value: refreshToken);
      await storage.write(key: "user_email", value: userEmail);
      print("Tokens and user email stored securely");
      Navigator.of(context).pushReplacementNamed("/dashboard");
    });
  }

  final String baseUrl = "http://172.23.164.16:8080/api";
  final String prodUrl = "https://collegebuddy-service.onrender.com/api";
  Future<void> startGoogleOauth() async {
    // Encode device info in the state parameter
    final state = "kjssecodecell|device=mobile";
    final url = Uri.parse("$prodUrl/auth/OAuth?state=$state");
    try {
      isLoading = true;
      final response = await http.get(url);
      final data = json.decode(response.body);
      final authUrl = data['oauth_url'];
      await launchUrl(Uri.parse(authUrl), mode: LaunchMode.externalApplication);
    } catch (e) {
      print("Error launching URL: $e");
      return;
    } finally {
      isLoading = false;
    }
  }

  Future<UserModel?> get currentUser async {
    final storage = FlutterSecureStorage();
    final userToken = await storage.read(key: "access_token");
    if (userToken == null) return null;

    try {
      final url = Uri.parse("$prodUrl/auth/get-profile?token=$userToken");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final user = UserModel.fromJson(decoded["user"]);
        return user;
      } else {
        print("Failed to fetch user profile: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching user profile: $e");
      return null;
    }
  }
}
