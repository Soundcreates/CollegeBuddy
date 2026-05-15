import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/api/authApi.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  // Colors based on the design
  static const Color background = Color(0xFF161311);
  static const Color primary = Color(0xFFFFB59C);

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Simulate initial loading/splash delay
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;
    final user = await AuthApi().currentUser;
    // Check auth status
    print("user: $user");
    Navigator.pushReplacementNamed(
      context,
      user != null ? '/main' : '/login',
      arguments: user,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Center(
        child: FadeIn(
          duration: const Duration(milliseconds: 1500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Icon placeholder
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.spa,
                  size: 48,
                  color: primary,
                ),
              ),
              const SizedBox(height: 24),
              // App Name
              Text(
                'CollegeBuddy',
                style: GoogleFonts.literata(
                  color: primary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

