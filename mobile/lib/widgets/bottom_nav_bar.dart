import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlobalBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const GlobalBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color surfaceContainerLowest = Color(0xFF110D0C);
    const Color secondaryContainer = Color(0xFF3E4D3E);
    const Color onSecondaryContainer = Color(0xFFACBDAB);
    const Color onSurfaceVariant = Color(0xFFDBC1B9);

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: surfaceContainerLowest,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.mail, 'Inbox', currentIndex == 0, 0),
          _buildNavItem(Icons.school, 'Classroom', currentIndex == 1, 1),
          _buildNavItem(Icons.settings, 'Settings', currentIndex == 2, 2),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, int index) {
    const Color secondaryContainer = Color(0xFF3E4D3E);
    const Color onSecondaryContainer = Color(0xFFACBDAB);
    const Color onSurfaceVariant = Color(0xFFDBC1B9);

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? secondaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? onSecondaryContainer : onSurfaceVariant.withOpacity(0.7),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.literata(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? onSecondaryContainer : onSurfaceVariant.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
