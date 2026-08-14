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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthApi>().initDeepLinks(context);
    });
  }

  Future<void> _signIn() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await context.read<AuthApi>().startGoogleOauth();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                'A gentle place for the emails, assignments, and next steps that matter.',
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
                  onPressed: _isLoading ? null : _signIn,
                  icon: _isLoading
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
                    'Continue with Google',
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
