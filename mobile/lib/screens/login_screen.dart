import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/api/authApi.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;
  
  // Colors based on the design
  static const Color background = Color(0xFF161311);
  static const Color primary = Color(0xFFFFB59C);
  static const Color onSurfaceVariant = Color(0xFFDBC1B9);
  static const Color onSurface = Color(0xFFEAE1DD);
  static const Color primaryContainer = Color(0xFFD97552);
  static const Color onPrimaryContainer = Color(0xFF511500);
  static const Color surfaceContainerHighest = Color(0xFF393431);
  static const Color outlineVariant = Color(0xFF55433D);

  void finishLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthApi>().initDeepLinks(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authApi = context.read<AuthApi>();

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // App Logo Area
                    FadeInDown(
                      delay: const Duration(milliseconds: 100),
                      child: Column(
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.spa,
                                size: 48,
                                color: primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'CollegeBuddy',
                            style: GoogleFonts.literata(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Calm communication for a focused life.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.literata(
                              fontSize: 16,
                              color: onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Illustration Component
                    FadeIn(
                      delay: const Duration(milliseconds: 300),
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 384), // max-w-sm
                        child: AspectRatio(
                          aspectRatio: 4 / 3,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: outlineVariant.withOpacity(0.3)),
                              image: const DecorationImage(
                                image: NetworkImage(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuAvxNpwGbw4S4B_WSVe6BV4oxDgdIOQdyRmxRWU4GYUO6dca6wjIOZm_R6eLee2cAUInRMhXEPHE8aYs7CD2JfPs-R3X1kq5s89PcO86TltcG31jrMhP1OFB6mzMtthAJ3AJMuF6ytYzjNpppvrfozFAwwhunJK8X5EAkBiIhUqJhIqSWb8IZ_PC7yvKj8Vqo2x_OC9geAypFyua-qz0NljpN93-KKtNA57HWzYxg2lupL4hMLMgIxIEH7RBVffdUD9GPte_TZOnP8'
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Primary Action Container
                    FadeInUp(
                      delay: const Duration(milliseconds: 500),
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 384),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : () async {
                                  finishLoading();
                                  await authApi.startGoogleOauth();
                                  finishLoading();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryContainer,
                                  foregroundColor: onPrimaryContainer,
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: isLoading
                                    ? CircularProgressIndicator(
                                        color: onPrimaryContainer,
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.g_mobiledata,
                                              color: Colors.black,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Continue with Google',
                                            style: GoogleFonts.literata(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Text(
                                'By continuing, you agree to our Terms of Service and Privacy Policy.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.literata(
                                  fontSize: 12,
                                  color: onSurfaceVariant.withOpacity(0.8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Decorative Element
            SizedBox(
              height: 64,
              child: Center(
                child: Container(
                  width: 48,
                  height: 6,
                  decoration: BoxDecoration(
                    color: surfaceContainerHighest.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
