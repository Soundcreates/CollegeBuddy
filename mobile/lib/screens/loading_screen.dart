import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mobile/api/authApi.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
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
    // Check auth status (AuthService should verify silent login if implemented)
    // For now simple navigation:
    // final auth = Provider.of<AuthService>(context, listen: false);
    // if (auth.isAuthenticated) ... else ...
    print("user: $user");
    Navigator.pushReplacementNamed(
      context,
      user != null ? '/dashboard' : '/login',
      arguments: user,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeIn(
          duration: const Duration(milliseconds: 1500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Icon placeholder
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              // App Name
              Text(
                'CollegeBuddy',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 2.0,
                  fontFamily: 'Roboto', // Will use Google Fonts in main
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
