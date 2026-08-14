import 'package:flutter/material.dart';
import 'package:CollegeBuddy/theme/app_theme.dart';

class GlobalBottomNavBar extends StatelessWidget {
  const GlobalBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.mail_rounded, 'Inbox'),
      (Icons.school_rounded, 'Classroom'),
      (Icons.settings_rounded, 'Settings'),
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: 70,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: Semantics(
                  button: true,
                  label: items[i].$2,
                  selected: currentIndex == i,
                  child: IconButton(
                    tooltip: items[i].$2,
                    onPressed: () => onTap(i),
                    icon: Icon(
                      items[i].$1,
                      size: 28,
                      color: currentIndex == i
                          ? AppColors.sun
                          : const Color(0xFFC6D6B6),
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
