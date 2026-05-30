import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import "package:mobile/models/mailModel.dart";
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class EmailViewScreen extends StatelessWidget {
  final MailModel email;

  const EmailViewScreen({super.key, required this.email});

  // Colors based on the design
  static const Color background = Color(0xFF161311);
  static const Color surfaceContainerLow = Color(0xFF1F1B19);
  static const Color primary = Color(0xFFFFB59C);
  static const Color onSurfaceVariant = Color(0xFFDBC1B9);
  static const Color onSurface = Color(0xFFEAE1DD);
  static const Color secondaryContainer = Color(0xFF3E4D3E);
  static const Color onSecondaryContainer = Color(0xFFACBDAB);
  static const Color surfaceContainerHighest = Color(0xFF393431);
  static const Color outlineVariant = Color(0xFF55433D);
  static const Color primaryContainer = Color(0xFFD97552);
  static const Color onPrimary = Color(0xFF5C1900);
  static const Color surfaceContainerHigh = Color(0xFF2E2927);
  static const Color primaryFixedDim = Color(0xFFFFB59C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: surfaceContainerLow,
                border: Border(
                  bottom: BorderSide(
                    color: outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: primary),
                    onPressed: () => Navigator.pop(context),
                    splashRadius: 24,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'CollegeBuddy',
                      style: GoogleFonts.literata(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.archive_outlined, color: onSurfaceVariant),
                    onPressed: () {},
                    splashRadius: 24,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: onSurfaceVariant),
                    onPressed: () {},
                    splashRadius: 24,
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: onSurfaceVariant),
                    onPressed: () {},
                    splashRadius: 24,
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subject Line
                    Text(
                      email.subject.isNotEmpty ? email.subject : 'No Subject',
                      style: GoogleFonts.literata(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: onSurface,
                        letterSpacing: -0.5,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: secondaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Editorial',
                            style: GoogleFonts.literata(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: onSecondaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Community',
                            style: GoogleFonts.literata(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Sender Info Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: outlineVariant.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: primaryFixedDim.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundColor: primary.withValues(alpha: 0.1),
                              foregroundImage: NetworkImage(
                                "https://ui-avatars.com/api/?name=${Uri.encodeComponent(email.from)}&background=393431&color=FFB59C&font-size=0.45"
                              ),
                              child: Text(
                                (email.from.isNotEmpty ? email.from[0] : 'S').toUpperCase(),
                                style: GoogleFonts.literata(
                                  color: primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        email.from.isNotEmpty ? email.from : 'Unknown Sender',
                                        style: GoogleFonts.literata(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: onSurface,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      email.date,
                                      style: GoogleFonts.literata(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: onSurfaceVariant.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      'To: me',
                                      style: GoogleFonts.literata(
                                        fontSize: 14,
                                        color: onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        email.date,
                                        style: GoogleFonts.literata(
                                          fontSize: 14,
                                          color: onSurfaceVariant.withValues(alpha: 0.7),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.expand_more,
                                      color: onSurfaceVariant,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Email Body
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: outlineVariant.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HtmlWidget(
                            email.body,
                            textStyle: GoogleFonts.literata(
                              fontSize: 18,
                              height: 1.55,
                              color: onSurface,
                            ),
                          ),
                          
                          // Attachments Section Inside Body (as per design)
                          if (email.attachments.isNotEmpty) ...[
                            const SizedBox(height: 32),
                            Divider(color: outlineVariant.withValues(alpha: 0.3)),
                            const SizedBox(height: 24),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: email.attachments.map((att) {
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: surfaceContainerHighest.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: outlineVariant.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.description_outlined,
                                        color: primary,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              att.filename.isNotEmpty ? att.filename : 'Unnamed file',
                                              style: GoogleFonts.literata(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: onSurface,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              'Attachment',
                                              style: GoogleFonts.literata(
                                                fontSize: 10,
                                                color: onSurfaceVariant.withValues(alpha: 0.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Action Buttons
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 120,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: onPrimary,
                                elevation: 8,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.reply, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Reply',
                                    style: GoogleFonts.literata(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 120,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: surfaceContainerHigh,
                                foregroundColor: onSurfaceVariant,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  side: BorderSide(
                                    color: outlineVariant.withValues(alpha: 0.2),
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.reply_all, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Reply All',
                                    style: GoogleFonts.literata(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 120,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: surfaceContainerHigh,
                                foregroundColor: onSurfaceVariant,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  side: BorderSide(
                                    color: outlineVariant.withValues(alpha: 0.2),
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.forward, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Forward',
                                    style: GoogleFonts.literata(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
