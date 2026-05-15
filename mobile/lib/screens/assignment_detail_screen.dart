import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile/api/classroomApi.dart';
import 'package:mobile/models/classroomModel.dart';

class AssignmentDetailScreen extends StatefulWidget {
  final AssignmentModel assignment;

  const AssignmentDetailScreen({super.key, required this.assignment});

  @override
  State<AssignmentDetailScreen> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen> {
  final ClassroomApi _api = ClassroomApi();

  // ─── Colors ───
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
  static const Color primaryContainer = Color(0xFFD97552);
  static const Color onPrimary = Color(0xFF5C1900);

  Uri? _toHttpUri(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri == null) return null;
    if (uri.scheme.isEmpty) {
      return Uri.tryParse("https://$value");
    }
    if (uri.scheme == "http" || uri.scheme == "https") {
      return uri;
    }
    return null;
  }

  Future<void> _openInGoogleClassroom(AssignmentModel assignment) async {
    final candidates = <Uri>[
      if (_toHttpUri(assignment.alternateLink) != null)
        _toHttpUri(assignment.alternateLink)!,
      for (final m in assignment.materials)
        if (_toHttpUri(m.url) != null) _toHttpUri(m.url)!,
    ];

    final fallbackUri = Uri.parse("https://classroom.google.com");
    final urisToTry = <Uri>[...candidates, fallbackUri];

    for (final uri in urisToTry) {
      final openedExternal = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (openedExternal) return;

      final openedBrowser = await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
      );
      if (openedBrowser) return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open Google Classroom.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.assignment;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                children: [
                  // Course badge
                  if (a.courseName.isNotEmpty) ...[
                    FadeInDown(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: secondaryContainer.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.school_outlined,
                                size: 14, color: onSecondaryContainer),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                a.courseName,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: onSecondaryContainer,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Title
                  FadeInDown(
                    delay: const Duration(milliseconds: 50),
                    child: Text(
                      a.title,
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: onSurface,
                        letterSpacing: -0.8,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Metadata chips
                  FadeInDown(
                    delay: const Duration(milliseconds: 100),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        if (a.hasDueDate)
                          _buildChip(
                              Icons.schedule_rounded, 'Due: ${a.dueDate}',
                              accent: true),
                        if (a.maxPoints > 0)
                          _buildChip(Icons.star_outline_rounded,
                              '${a.maxPoints.toInt()} points'),
                        if (a.workType.isNotEmpty)
                          _buildChip(
                              Icons.category_outlined, a.workType),
                        if (a.state.isNotEmpty)
                          _buildChip(
                              Icons.flag_outlined, a.state),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Description
                  if (a.description.isNotEmpty) ...[
                    FadeInDown(
                      delay: const Duration(milliseconds: 150),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: onSurfaceVariant.withOpacity(0.6),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: outlineVariant.withOpacity(0.15),
                              ),
                            ),
                            child: Text(
                              a.description,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: onSurface.withOpacity(0.85),
                                fontWeight: FontWeight.w400,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // Materials / Attachments
                  if (a.materials.isNotEmpty) ...[
                    FadeInDown(
                      delay: const Duration(milliseconds: 200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Materials',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: onSurfaceVariant.withOpacity(0.6),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...a.materials.map(
                              (m) => _buildMaterialCard(m)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // AI Help Button
                  FadeInUp(
                    delay: const Duration(milliseconds: 250),
                    child: _buildAIHelpButton(),
                  ),

                  // Open in Classroom button
                  if (a.alternateLink.isNotEmpty ||
                      a.materials.any((m) => m.url.trim().isNotEmpty)) ...[
                    const SizedBox(height: 12),
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: OutlinedButton.icon(
                        onPressed: () => _openInGoogleClassroom(a),
                        icon: const Icon(Icons.open_in_new_rounded, size: 18),
                        label: Text(
                          'Open in Google Classroom',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: onSurfaceVariant,
                          side: BorderSide(
                              color: outlineVariant.withOpacity(0.4)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── App Bar ───
  Widget _buildAppBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: outlineVariant.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: primary, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Assignment',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: onSurface,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Metadata Chip ───
  Widget _buildChip(IconData icon, String label, {bool accent = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent
            ? primary.withOpacity(0.1)
            : surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 14,
              color: accent ? primary : onSurfaceVariant.withOpacity(0.6)),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: accent ? primary : onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Material Card ───
  Widget _buildMaterialCard(MaterialModel material) {
    IconData icon;
    Color iconColor;
    switch (material.type) {
      case 'driveFile':
        icon = Icons.description_outlined;
        iconColor = primary;
        break;
      case 'link':
        icon = Icons.link_rounded;
        iconColor = const Color(0xFF8CB4D0);
        break;
      case 'youtubeVideo':
        icon = Icons.play_circle_outline_rounded;
        iconColor = const Color(0xFFE57373);
        break;
      case 'form':
        icon = Icons.quiz_outlined;
        iconColor = const Color(0xFF81C784);
        break;
      default:
        icon = Icons.file_present_outlined;
        iconColor = onSurfaceVariant;
    }

    return _MaterialCardWidget(
      material: material,
      icon: icon,
      iconColor: iconColor,
      api: _api,
    );
  }

  // ─── AI Help Button ───
  Widget _buildAIHelpButton() {
    return GestureDetector(
      onTap: () => _showAIHelpModal(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryContainer.withOpacity(0.3),
              primary.withOpacity(0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: primary.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  size: 22, color: primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Get AI Help',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: primary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Generate content suggestions for this assignment',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: onSurfaceVariant.withOpacity(0.7),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: primary.withOpacity(0.7), size: 22),
          ],
        ),
      ),
    );
  }

  // ─── AI Help Modal ───
  void _showAIHelpModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AIHelpModal(
        assignment: widget.assignment,
        api: _api,
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  AI HELP MODAL (Bottom Sheet)
// ═══════════════════════════════════════════════

class _AIHelpModal extends StatefulWidget {
  final AssignmentModel assignment;
  final ClassroomApi api;

  const _AIHelpModal({required this.assignment, required this.api});

  @override
  State<_AIHelpModal> createState() => _AIHelpModalState();
}

class _AIHelpModalState extends State<_AIHelpModal> {
  bool _loading = true;
  AIHelpResponse? _response;

  static const Color background = Color(0xFF161311);
  static const Color surfaceContainerLow = Color(0xFF1F1B19);
  static const Color primary = Color(0xFFFFB59C);
  static const Color onSurfaceVariant = Color(0xFFDBC1B9);
  static const Color onSurface = Color(0xFFEAE1DD);
  static const Color surfaceContainerHighest = Color(0xFF393431);
  static const Color outlineVariant = Color(0xFF55433D);
  static const Color surfaceContainerLowest = Color(0xFF110D0C);
  static const Color primaryContainer = Color(0xFFD97552);

  @override
  void initState() {
    super.initState();
    _fetchAIHelp();
  }

  Future<void> _fetchAIHelp() async {
    final a = widget.assignment;
    final result = await widget.api.getAIHelp(
      title: a.title,
      description: a.description,
      fileUrl: a.firstDriveFileUrl ?? '',
    );

    if (mounted) {
      setState(() {
        _response = result;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: BoxDecoration(
        color: background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(color: outlineVariant.withOpacity(0.3), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: surfaceContainerHighest,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Modal header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      size: 18, color: primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Content Suggestions',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        widget.assignment.title,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: onSurfaceVariant.withOpacity(0.6),
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded,
                      color: onSurfaceVariant.withOpacity(0.5), size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Divider(color: outlineVariant.withOpacity(0.2), height: 1),

          // Content
          Expanded(
            child: _loading
                ? _buildLoadingContent()
                : _response == null || !_response!.success
                    ? _buildErrorContent()
                    : _buildSuccessContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Center(
      child: FadeIn(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated dots
            SizedBox(
              width: 60,
              height: 60,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: primary.withOpacity(0.5),
                    ),
                  ),
                  Icon(Icons.auto_awesome_rounded,
                      size: 20, color: primary),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Analyzing your assignment...',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Generating content suggestions',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: onSurfaceVariant.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorContent() {
    return Center(
      child: FadeIn(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline_rounded,
                    size: 28, color: Colors.redAccent),
              ),
              const SizedBox(height: 20),
              Text(
                'Unable to generate content',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _response?.error ?? 'An unexpected error occurred',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: onSurfaceVariant.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: () {
                  setState(() => _loading = true);
                  _fetchAIHelp();
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  'Try again',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                ),
                style: TextButton.styleFrom(foregroundColor: primary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessContent() {
    // Check if we have Q&A pairs (from assignment-help endpoint)
    if (_response!.hasQuestionsAnswers) {
      return _buildQAContent();
    }
    // Otherwise show sections (from analyze endpoint)
    if (_response!.hasSections) {
      return _buildSectionsContent();
    }
    // Fallback
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'No content available',
          style: GoogleFonts.inter(color: onSurfaceVariant),
        ),
      ),
    );
  }

  Widget _buildSectionsContent() {
    final sections = _response!.sections;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        return FadeInUp(
          delay: Duration(milliseconds: index * 80),
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section header
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        section.header,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: onSurface,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Bullet points
                ...section.points.map((point) => Padding(
                      padding: const EdgeInsets.only(
                          left: 14, bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 7),
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              point,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: onSurface.withOpacity(0.85),
                                fontWeight: FontWeight.w400,
                                height: 1.55,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQAContent() {
    final qaMap = _response!.questionsAnswers;
    final qaList = qaMap.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: qaList.length,
      itemBuilder: (context, index) {
        final entry = qaList[index];
        return FadeInUp(
          delay: Duration(milliseconds: index * 80),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: outlineVariant.withOpacity(0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Q${index + 1}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: Container(
                      width: 2,
                      height: 8,
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Answer
                  Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Answer',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: onSurfaceVariant.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          entry.value,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: onSurface.withOpacity(0.9),
                            fontWeight: FontWeight.w400,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════
//  MATERIAL CARD WITH DOWNLOAD (Stateful)
// ═══════════════════════════════════════════════

class _MaterialCardWidget extends StatefulWidget {
  final MaterialModel material;
  final IconData icon;
  final Color iconColor;
  final ClassroomApi api;

  const _MaterialCardWidget({
    required this.material,
    required this.icon,
    required this.iconColor,
    required this.api,
  });

  @override
  State<_MaterialCardWidget> createState() => _MaterialCardWidgetState();
}

class _MaterialCardWidgetState extends State<_MaterialCardWidget> {
  bool _downloading = false;
  double _progress = 0.0;
  String? _downloadedPath;

  static const Color surfaceContainerLowest = Color(0xFF110D0C);
  static const Color outlineVariant = Color(0xFF55433D);
  static const Color onSurface = Color(0xFFEAE1DD);
  static const Color onSurfaceVariant = Color(0xFFDBC1B9);
  static const Color primary = Color(0xFFFFB59C);

  Future<void> _handleDownload() async {
    if (_downloading) return;

    setState(() {
      _downloading = true;
      _progress = 0.0;
    });

    final filename = widget.material.title.isNotEmpty
        ? widget.material.title
        : 'download';

    final path = await widget.api.downloadAttachment(
      originalUrl: widget.material.downloadUrl.isNotEmpty ? widget.material.downloadUrl : widget.material.url,
      filename: filename,
      onProgress: (p) {
        if (mounted) setState(() => _progress = p);
      },
    );

    if (mounted) {
      setState(() {
        _downloading = false;
        _downloadedPath = path;
      });

      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded: $filename'),
            backgroundColor: const Color(0xFF2E4D2E),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'OPEN',
              textColor: primary,
              onPressed: () async {
                // Try to open the file
                final uri = Uri.file(path);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Download failed. Try opening in browser.'),
            backgroundColor: Color(0xFF4D2E2E),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Fallback: open in browser
        if (widget.material.url.isNotEmpty) {
          final uri = Uri.parse(widget.material.url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleDownload,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: outlineVariant.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.icon, size: 20, color: widget.iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.material.title.isNotEmpty
                            ? widget.material.title
                            : 'Untitled',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _downloading
                            ? 'Downloading...'
                            : _downloadedPath != null
                                ? 'Downloaded ✓'
                                : widget.material.type == 'driveFile'
                                    ? 'Tap to download'
                                    : widget.material.type,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: _downloadedPath != null
                              ? const Color(0xFF81C784)
                              : onSurfaceVariant.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                _downloading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: _progress > 0 ? _progress : null,
                          color: primary,
                        ),
                      )
                    : Icon(
                        _downloadedPath != null
                            ? Icons.check_circle_outline_rounded
                            : Icons.download_rounded,
                        size: 20,
                        color: _downloadedPath != null
                            ? const Color(0xFF81C784)
                            : onSurfaceVariant.withOpacity(0.4),
                      ),
              ],
            ),
            if (_downloading && _progress > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 3,
                    backgroundColor: outlineVariant.withOpacity(0.2),
                    color: primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
