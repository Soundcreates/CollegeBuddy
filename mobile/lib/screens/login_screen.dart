import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:CollegeBuddy/api/authApi.dart';
import 'package:CollegeBuddy/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final AuthApi _auth;

  @override
  void initState() {
    super.initState();
    _auth = context.read<AuthApi>();
    _auth.addListener(_onAuthChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onAuthChanged());
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (!mounted) return;
    if (_auth.isAuthenticated) {
      appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/main',
        (route) => false,
      );
    }
  }

  Future<void> _signIn() async {
    if (_auth.isLoading || _auth.oauthInProgress) return;
    try {
      await _auth.startGoogleOauth();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-in failed: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthApi>();
    final waitingForBrowser = auth.oauthInProgress;
    final busy = auth.isLoading || waitingForBrowser;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 20, 26, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/branding/collegebuddy-mark.png',
                    width: 30,
                    height: 30,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'CollegeBuddy',
                    style: AppText.serif(size: 21, weight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 58),
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E9C7),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Stack(
                  children: [
                    const Positioned(
                      top: 22,
                      right: 25,
                      child: _Leaf(size: 105, color: AppColors.moss, turn: .55),
                    ),
                    const Positioned(
                      bottom: 7,
                      left: 35,
                      child: _Leaf(size: 148, color: AppColors.clay, turn: -.7),
                    ),
                    Center(
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 72,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 42),
              Text(
                'College, in\na calmer flow.',
                style: AppText.serif(size: 43, height: .98),
              ),
              const SizedBox(height: 16),
              Text(
                waitingForBrowser
                    ? 'Finishing Google sign-in…'
                    : 'A gentle place for the emails, assignments, and next steps that matter.',
                style: AppText.sans(
                  size: 16,
                  color: const Color(0xFF536A5D),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 34),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: busy ? null : _signIn,
                  icon: busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.g_mobiledata_rounded, size: 28),
                  label: Text(
                    waitingForBrowser
                        ? 'Completing sign-in…'
                        : 'Continue with Google',
                    style: AppText.sans(
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.ink,
                    disabledBackgroundColor: AppColors.ink.withOpacity(.7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Your study life, with more breathing room.',
                  style: AppText.sans(size: 12, color: AppColors.moss),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Leaf extends StatelessWidget {
  const _Leaf({required this.size, required this.color, required this.turn});

  final double size;
  final Color color;
  final double turn;

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: turn,
    child: Container(
      width: size * .6,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(size),
          bottomRight: Radius.circular(size),
        ),
      ),
    ),
  );
}
