import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:CollegeBuddy/api/authApi.dart';
import 'package:CollegeBuddy/presentation/providers/providers.dart';
import 'package:CollegeBuddy/theme/app_theme.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({super.key});

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    AuthApi().initDeepLinks(context);
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    final user = await AuthApi().currentUser;
    if (!mounted) return;
    if (user != null) {
      ref.read(syncServiceProvider).syncIfStale();
    }
    Navigator.pushReplacementNamed(
      context,
      user != null ? '/main' : '/login',
      arguments: user,
    );
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: AppColors.cream,
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
            image: AssetImage('assets/branding/collegebuddy-mark.png'),
            width: 76,
            height: 76,
          ),
          SizedBox(height: 20),
          Text(
            'CollegeBuddy',
            style: TextStyle(
              fontSize: 30,
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            width: 120,
            child: LinearProgressIndicator(color: AppColors.ink, minHeight: 2),
          ),
        ],
      ),
    ),
  );
}
