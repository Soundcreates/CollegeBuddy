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

  void finishLoading() {

    setState(() {
      isLoading =!isLoading;
    });
  }
  @override
  Widget build(BuildContext context) {
    final authApi = Provider.of<Authapi>(context);

    @override
    void initState() {
      super.initState();
      authApi.initDeepLinks(context);
    }
    // Watch for auth changes to navigate
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Ambient background gradient
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.shade900.withOpacity(0.2),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      'College\nBuddy',
                      style: GoogleFonts.outfit(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInDown(
                    delay: const Duration(milliseconds: 400),
                    child: Text(
                      'Never miss a deadline.',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        color: Colors.white54,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                            finishLoading();
                            await authApi.startGoogleOauth();
                            finishLoading();

                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.black,
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Simple Google 'G' text or icon placeholder
                                  // In real app use specific Google Logo asset
                                  const Icon(Icons.g_mobiledata, size: 32),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Continue with Google',
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
