import 'dart:ui';
import "dart:convert";
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/models/userModel.dart';
import 'package:app_links/app_links.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/material.dart';

class AuthApi extends ChangeNotifier {
  final appLinks = AppLinks();
  bool isLoading = false;
  final FlutterSecureStorage storage = FlutterSecureStorage();
  void initDeepLinks(BuildContext context) {
    appLinks.uriLinkStream.listen((uri) async {
      if (uri == null) return;

      print("Deep link received: $uri");
      final success = uri.queryParameters['success'];
      //these access tokens andrefersh tokens are of jwt
      final accessToken = uri.queryParameters['access_token'];
      final refreshToken = uri.queryParameters['refresh_token'];
      final userEmail = uri.queryParameters['user_email'];
      //now letss store them


      await storage.write(key: "access_token", value: accessToken);

      await storage.write(key: "user_email", value: userEmail);
      print("Tokens and user email stored securely");
      Navigator.of(context).pushReplacementNamed("/dashboard");
    });
  }
  
  //we gon use ngrok for ts one
  final String baseUrl = "https://kisha-volcanologic-motherly.ngrok-free.dev";
  Future<void> startGoogleOauth() async {
    // Encode device info in the state parameter
    print("Starting google auth");
    final state = "kjssecodecell";
    final url = Uri.parse("$baseUrl/api/auth/OAuth?state=$state");
    try {
      isLoading = true;
      final response = await http.get(url);
      print("[DEBUG] OAuth response status: ${response.statusCode}");
      print("[DEBUG] OAuth response body: ${response.body}");
      final data = json.decode(response.body);
      final authUrl = data['oauth_url'];
      print("[DEBUG] OAuth URL from backend: $authUrl");
      if (authUrl == null || authUrl.isEmpty) {
        throw Exception("Invalid OAuth URL received from backend");
      }
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
    if (userToken == null) {
      print("No access token found in storage.");
      return null;
    }
    print("[DEBUG] JWT token being sent to backend: $userToken");
    try {
      final url = Uri.parse("$baseUrl/api/auth/get-profile?token=$userToken");
      print("[DEBUG] Profile fetch URL: $url");
      final response = await http.get(url);
      print("[DEBUG] Backend response status: ${response.statusCode}");
      print("[DEBUG] Backend response body: ${response.body}");
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final user = UserModel.fromJson(decoded["user"]);
        return user;
      } else {
        print("Failed to fetch user profile: ${response.statusCode}");
        print(response);
      }
    } catch (e) {
      print("Error fetching user profile: $e");
      return null;
    }
  }

  Future<void> Logout() async {
    final storage = FlutterSecureStorage();
    await storage.delete(key: "access_token");
    await storage.delete(key: "refresh_token");
    await storage.delete(key: "user_email");
    print("User logged out, tokens cleared");
  }
}
