import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mobile/api/mailApi.dart';
import 'package:mobile/api/authApi.dart';
import 'package:mobile/models/userModel.dart';
import "package:mobile/cache/BigDataRepository.dart";
import 'package:animate_do/animate_do.dart';
import 'package:mobile/screens/classroom_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Future<List<Object>> _loadedData;

  // Colors
  static const Color background = Color(0xFF161311);
  static const Color surfaceContainerLow = Color(0xFF1F1B19);
  static const Color primary = Color(0xFFFFB59C);
  static const Color onSurfaceVariant = Color(0xFFDBC1B9);
  static const Color onSurface = Color(0xFFEAE1DD);
  static const Color secondaryContainer = Color(0xFF3E4D3E);
  static const Color onSecondaryContainer = Color(0xFFACBDAB);
  static const Color surfaceContainerHighest = Color(0xFF393431);
  static const Color outlineVariant = Color(0xFF55433D);
  static const Color surfaceContainerLowest = Color(0xFF110D0C);
  static const Color outline = Color(0xFFA38C84);
  static const Color surfaceContainer = Color(0xFF231F1D);
  static const Color onPrimary = Color(0xFF5C1900);
  static const Color primaryContainer = Color(0xFFD97552);
  static const Color onPrimaryContainer = Color(0xFF511500);
  static const Color tertiaryContainer = Color(0xFF80949D);
  static const Color onTertiaryContainer = Color(0xFF192C34);

  @override
  void initState() {
    super.initState();
    _loadedData = _loadSettingsData();
  }

  Future<List<Object>> _loadSettingsData() async {
    final user = await BigDataRepository().fetchUserData();
    return [user ?? Object()];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadedData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: background,
            body: Center(
              child: FadeIn(
                duration: const Duration(milliseconds: 1000),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.spa, size: 40, color: primary),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: 200,
                      child: LinearProgressIndicator(
                        backgroundColor: primary.withValues(alpha: 0.1),
                        color: primary,
                        borderRadius: BorderRadius.circular(10),
                        minHeight: 2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Adjusting your sanctuary...",
                      style: GoogleFonts.literata(
                        color: onSurfaceVariant,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final user = (snapshot.hasData && snapshot.data!.isNotEmpty) 
            ? snapshot.data![0] as UserModel? 
            : null;

        return Scaffold(
          backgroundColor: background,
          body: SafeArea(
            child: Column(
              children: [
                // Top App Bar
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: surfaceContainerLow,
                    border: Border(
                      bottom: BorderSide(
                        color: outlineVariant.withOpacity(0.3),
                      ),
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu, color: primary),
                            onPressed: () {},
                            splashRadius: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'CollegeBuddy',
                            style: GoogleFonts.literata(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: surfaceContainerHighest,
                            width: 2,
                          ),
                          image: user != null && user.profilePic.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(user.profilePic),
                                  fit: BoxFit.cover,
                                )
                              : const DecorationImage(
                                  image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAX9_FWhQ7fsvxW4VpX-dQ40y-74XJFSPQ8Mb7vXj2kiWzrbKyew1SvFjrRnNJF_FHqiGzBwi-lCfXNU97NCSLXnTv727XfBVZ9HEUBrAc-TQnCsJAOlVBybb49U0oFEXQYK42Ch5kc7mqjHIexVzyXNxU4BKrT5IixzESk1yE8i_I0DaI7zOT6KJNv-qrC_r2qTT_St_2DLX9J9HrV4_gD1IXytnfL_S32aoYQWpS8aEWSMVb17fQ7OeMnZrvsh-C_QnHDiN8CB1k'),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    children: [
                      // Profile Section
                      FadeInDown(
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 96,
                                    height: 96,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: surfaceContainerLow,
                                        width: 4,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 12,
                                        ),
                                      ],
                                      image: user != null && user.profilePic.isNotEmpty
                                          ? DecorationImage(
                                              image: NetworkImage(user.profilePic),
                                              fit: BoxFit.cover,
                                            )
                                          : const DecorationImage(
                                              image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAkd4-vdejBdG2j0-HWzAdRTVSdM0vY-X6gQQ_hTRF3vrGP998nyQJgw797SyWgQOoQi_muJBhCy-CpcMUf6Qwt7I9_Rey29TU1584bPELD65DVSaIzqoib3BuyxIvQBnAkmaUeJAGMBQIay4ghOXbmBKE7Cn4ongujxGNoPreV1-d2zCTPXVvtv4JHDHEBRRKG9xf_Mil8OhrbzxX33fBUcrLKzm7smjs-6nfnx4WGRaFMtPKYxC05wv8bBJfpffa3dY0kPda8beU'),
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: primary,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        size: 18,
                                        color: onPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                user?.name ?? 'Julian Reed',
                                style: GoogleFonts.literata(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email ?? 'julian@oasis.com',
                                style: GoogleFonts.literata(
                                  fontSize: 14,
                                  color: onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: secondaryContainer,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Text(
                                  'Focus Plan Active',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                    color: onSecondaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Settings Categories
                      FadeInUp(
                        delay: const Duration(milliseconds: 100),
                        child: Column(
                          children: [
                            _buildSettingItem(
                              icon: Icons.person,
                              iconBg: secondaryContainer,
                              iconColor: onSecondaryContainer,
                              title: 'Account',
                              subtitle: 'Profile, security, and storage',
                            ),
                            const SizedBox(height: 8),
                            _buildSettingItem(
                              icon: Icons.notifications,
                              iconBg: primaryContainer,
                              iconColor: onPrimaryContainer,
                              title: 'Notifications',
                              subtitle: 'Quiet hours and custom alerts',
                            ),
                            const SizedBox(height: 8),
                            _buildSettingItem(
                              icon: Icons.palette,
                              iconBg: tertiaryContainer,
                              iconColor: onTertiaryContainer,
                              title: 'Appearance',
                              subtitle: 'Earthy themes and typography',
                            ),
                            const SizedBox(height: 8),
                            _buildSettingItem(
                              icon: Icons.help,
                              iconBg: secondaryContainer,
                              iconColor: onSecondaryContainer,
                              title: 'Help',
                              subtitle: 'Guides and support center',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Sign Out Button
                      FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        child: Column(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () async {
                                await BigDataRepository().logoutAndClearCache();
                                if (context.mounted) {
                                  Navigator.pushReplacementNamed(context, '/login');
                                }
                              },
                              icon: const Icon(Icons.logout),
                              label: const Text('Sign Out'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primary,
                                side: BorderSide(color: outlineVariant, width: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              'CollegeBuddy v2.4.0',
                              style: GoogleFonts.literata(
                                fontSize: 14,
                                color: onSurfaceVariant.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                    color: onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.literata(
                    fontSize: 14,
                    color: onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: outline),
        ],
      ),
    );
  }
}
