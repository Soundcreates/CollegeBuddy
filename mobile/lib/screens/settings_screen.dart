import 'package:flutter/material.dart';
import 'package:CollegeBuddy/cache/BigDataRepository.dart';
import 'package:CollegeBuddy/models/userModel.dart';
import 'package:CollegeBuddy/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final Future<UserModel?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = BigDataRepository().fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.cream,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.ink),
            ),
          );
        }
        final user = snapshot.data;
        return Scaffold(
          backgroundColor: AppColors.cream,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Settings',
                      style: AppText.serif(size: 32, weight: FontWeight.w700),
                    ),
                    _avatar(user),
                  ],
                ),
                const SizedBox(height: 26),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _avatar(user, radius: 46),
                      const SizedBox(height: 14),
                      Text(
                        user?.name ?? 'CollegeBuddy student',
                        style: AppText.serif(size: 22),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? 'Your account',
                        style: AppText.sans(size: 14, color: AppColors.moss),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.paleMoss,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          'Focus plan active',
                          style: AppText.sans(
                            size: 13,
                            weight: FontWeight.w700,
                            color: AppColors.moss,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                _settingItem(
                  Icons.person_rounded,
                  AppColors.paleMoss,
                  'Account',
                  'Profile, security, and storage',
                ),
                _settingItem(
                  Icons.notifications_rounded,
                  AppColors.paleClay,
                  'Notifications',
                  'Quiet hours and custom alerts',
                ),
                _settingItem(
                  Icons.palette_rounded,
                  const Color(0xFFE3E6D4),
                  'Appearance',
                  'Earthy themes and typography',
                ),
                _settingItem(
                  Icons.help_rounded,
                  AppColors.paleMoss,
                  'Help',
                  'Guides and support center',
                ),
                const SizedBox(height: 28),
                OutlinedButton.icon(
                  onPressed: () async {
                    await BigDataRepository().logoutAndClearCache();
                    if (context.mounted)
                      Navigator.pushReplacementNamed(context, '/login');
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(
                    'Sign out',
                    style: AppText.sans(weight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.ink,
                    side: const BorderSide(color: AppColors.line),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'CollegeBuddy',
                    style: AppText.sans(size: 12, color: AppColors.moss),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _avatar(UserModel? user, {double radius = 24}) {
    if (user?.profilePic.isNotEmpty == true) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(user!.profilePic),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.sun,
      child: Text(
        user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'C',
        style: AppText.sans(size: radius * .8, color: AppColors.ink),
      ),
    );
  }

  Widget _settingItem(
    IconData icon,
    Color iconBackground,
    String title,
    String subtitle,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Material(
      color: AppColors.paper,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.moss),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppText.sans(size: 14, weight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppText.sans(size: 13, color: AppColors.moss),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.moss),
            ],
          ),
        ),
      ),
    ),
  );
}
