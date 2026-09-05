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
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final auth = AuthApi();

    // Deep link may already have navigated to /main during the delay.
    if (auth.isAuthenticated || auth.oauthInProgress) {
      if (auth.isAuthenticated) {
        ref.read(syncServiceProvider).syncIfStale();
        appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/main',
          (route) => false,
        );
      }
      return;
    }

    final user = await auth.currentUser;
    if (!mounted) return;

    // Auth may have completed via deep link while profile fetch was in flight.
    if (auth.isAuthenticated) {
      ref.read(syncServiceProvider).syncIfStale();
      appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/main',
        (route) => false,
      );
      return;
    }

    if (user != null) {
      ref.read(syncServiceProvider).syncIfStale();
      appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/main',
        (route) => false,
      );
      return;
    }

    appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
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
