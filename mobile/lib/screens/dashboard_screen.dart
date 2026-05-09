import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mobile/api/mailApi.dart';
import 'email_view_screen.dart';
import 'package:mobile/screens/settings_screen.dart';
import 'package:mobile/screens/classroom_screen.dart';
import "package:mobile/models/userModel.dart";
import "package:mobile/models/mailModel.dart";
import "package:mobile/cache/BigDataRepository.dart";

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<dynamic>> _loadedData;
  bool _hasInitialized = false;
  final BigDataRepository mailRepo = BigDataRepository();
  final MailApi mail_fetcher = MailApi();
  bool _isRefreshing = false;
  List<MailModel> _streamedMails = [];
  bool _streamLoading = false;

  @override
  void initState() {
    super.initState();
    print("[DASHBOARD] initState called, preparing initial data load");
    _initializeOnce();
  }

  Future<void> _testFetchMails() async {
    setState(() => _isRefreshing = true);
    try {
      print("[TEST] Manual mail fetch triggered");
      mailRepo.clearMailCache();
      setState(() {
        _streamLoading = true;
        _streamedMails = [];
      });

      await for (final mails in mail_fetcher.streamFilteredMails(minBatchToEmit: 5)) {
        if (!mounted) break;
        setState(() {
          _streamedMails = mails;
        });
      }

      if (mounted) {
        setState(() => _streamLoading = false);
      }

      print("[TEST] Stream fetch completed: ${_streamedMails.length} mails");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fetched ${_streamedMails.length} mails'), duration: const Duration(seconds: 2)),
        );
      }
    } catch (e) {
      print("[TEST] Manual fetch error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), duration: const Duration(seconds: 2)),
        );
      }
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  void _initializeOnce() {
    if (!_hasInitialized) {
      _loadedData = _loadDashboardData();
      _hasInitialized = true;
    }
  }

  Future<List<dynamic>> _loadDashboardData() async {
    print("[DASHBOARD] Loading dashboard data (FRESH, NO CACHE)");
    final user = await mailRepo.fetchUserData();
    // IMPORTANT: Force fresh fetch every time (no cache)
    final mails = await mailRepo.fetchMailData() as List<MailModel>? ?? [];
    print("[DASHBOARD] Dashboard data loaded: user=${user != null}, mails=${mails.length}");
    return [user, mails];
  }

  @override
  Widget build(BuildContext context) {
      // Mock Mail Data
    // Removed mock emails. Will use fetched mails from backend.

    return FutureBuilder(
      future: _loadedData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          const Color background = Color(0xFF161311);
          const Color primary = Color(0xFFFFB59C);
          const Color onSurfaceVariant = Color(0xFFDBC1B9);

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
                      "Gathering your messages...",
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
        if (!snapshot.hasData) {
          return const Center(child: Text("Failed to load data"));
        }
        final user = snapshot.data![0] as UserModel? ?? null;
        final cachedMails = snapshot.data![1] as List<MailModel>? ?? [];
        final mails = _streamedMails.isNotEmpty ? _streamedMails : cachedMails;
        if(user == null){
          WidgetsBinding.instance.addPostFrameCallback((_) {
              Future.delayed(const Duration(seconds: 2), () {
                  if(context.mounted){
                      Navigator.pushReplacementNamed(context, "/login");
                    }
                });
            });
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        const Color background = Color(0xFF161311);
        const Color surfaceContainerLow = Color(0xFF1F1B19);
        const Color primary = Color(0xFFFFB59C);
        const Color onSurfaceVariant = Color(0xFFDBC1B9);
        const Color onSurface = Color(0xFFEAE1DD);
        const Color secondaryContainer = Color(0xFF3E4D3E);
        const Color onSecondaryContainer = Color(0xFFACBDAB);
        const Color surfaceContainerHighest = Color(0xFF393431);
        const Color outlineVariant = Color(0xFF55433D);
        const Color surfaceContainerLowest = Color(0xFF110D0C);
        const Color secondary = Color(0xFFBACBB8);
        const Color primaryContainer = Color(0xFFD97552);

        print("Total no of mails loaded: ${mails.length}");
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'CollegeBuddy',
                                style: GoogleFonts.literata(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Your mindful inbox',
                                style: GoogleFonts.literata(
                                  fontSize: 16,
                                  color: onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryContainer,
                            width: 2,
                          ),
                          image: user.profilePic.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(user.profilePic),
                                  fit: BoxFit.cover,
                                )
                              : const DecorationImage(
                                  image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDOVfTg_bw1uSf6TfVRuc6p61_Pa06cvxnbf3fMavwz2BUxEZnNQv40isOiMC-DXBxLDTu-I4t5vt8zGByOKYnsbD7BPiSeIDdHR4PKVqUbbpE3lDp6RXR_98h-zLtccmfZX_aDyiVeBzRfF45mE6TnHqbm07j-3IJEq7OJTWqMWbuA9__GlcehKVMvPFGoiZsohwt5fKNKxEdFDoE79yoaBWNnt4VZ1st_B7XyNqe00YKQtpDIM9ZpN8MFUI-Hs15o8PKXVRdwyLA'),
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
                      // Welcome Greeting
                      Text(
                        'Good morning, ${user.name.split(' ').first}',
                        style: GoogleFonts.literata(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You have ${mails.length} new messages waiting in your sanctuary.',
                        style: GoogleFonts.literata(
                          fontSize: 16,
                          color: onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          style: GoogleFonts.literata(color: onSurface),
                          decoration: InputDecoration(
                            hintText: 'Search your conversations...',
                            hintStyle: GoogleFonts.literata(color: onSurfaceVariant.withOpacity(0.7)),
                            prefixIcon: const Icon(Icons.search, color: onSurfaceVariant),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Test Fetch Button
                      SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: _isRefreshing ? null : _testFetchMails,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: surfaceContainerLow,
                            foregroundColor: primary,
                            side: BorderSide(color: outlineVariant.withOpacity(0.3)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: _isRefreshing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(primary)),
                                )
                              : Text('Test Fetch Mails', style: GoogleFonts.literata(fontSize: 14)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_streamLoading) ...[
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Loading...",
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Inbox List
                      if (mails.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(
                              "No mails found.",
                              style: GoogleFonts.literata(
                                color: onSurfaceVariant,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                      else
                        ...mails.asMap().entries.map((entry) {
                          int index = entry.key;
                          var mail = entry.value;
                          bool isUnread = index % 2 == 0; // Just mock unread status
                          return FadeInUp(
                            delay: Duration(milliseconds: index * 100),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EmailViewScreen(email: mail),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: isUnread ? surfaceContainerLowest : surfaceContainerLow.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.transparent,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    if (isUnread)
                                      Positioned(
                                        left: 0,
                                        top: 0,
                                        bottom: 0,
                                        child: Container(
                                          width: 4,
                                          decoration: BoxDecoration(
                                            color: primary,
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              bottomLeft: Radius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: surfaceContainerHighest,
                                            ),
                                            child: CircleAvatar(
                                              backgroundColor: primary.withValues(alpha: 0.1),
                                              foregroundImage: NetworkImage(
                                                "https://ui-avatars.com/api/?name=${Uri.encodeComponent(mail.from)}&background=393431&color=FFB59C&font-size=0.45"
                                              ),
                                              child: Text(
                                                (mail.from.isNotEmpty ? mail.from[0] : 'S').toUpperCase(),
                                                style: GoogleFonts.literata(
                                                  color: primary,
                                                  fontSize: 20,
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
                                                      flex: 3,
                                                      child: Text(
                                                        mail.from.isNotEmpty ? mail.from : 'Unknown',
                                                        style: GoogleFonts.literata(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w600,
                                                          color: isUnread ? onSurface : onSurfaceVariant,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        mail.date,
                                                        style: GoogleFonts.literata(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w500,
                                                          color: isUnread ? primary : onSurfaceVariant.withValues(alpha: 0.6),
                                                        ),
                                                        textAlign: TextAlign.right,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  mail.subject,
                                                  style: GoogleFonts.literata(
                                                    fontSize: 16,
                                                    fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                                                    color: onSurface,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                if (mail.attachments.isNotEmpty) ...[
                                                  Container(
                                                    margin: const EdgeInsets.only(bottom: 8),
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: surfaceContainerHighest.withOpacity(0.5),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(Icons.attachment, size: 14, color: onSurfaceVariant),
                                                        const SizedBox(width: 4),
                                                        Flexible(
                                                          child: Text(
                                                            mail.attachments.first.filename.isNotEmpty ? mail.attachments.first.filename : 'Attachment',
                                                            style: GoogleFonts.literata(fontSize: 12, color: onSurfaceVariant),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                                Text(
                                                  mail.snippet,
                                                  style: GoogleFonts.literata(
                                                    fontSize: 14,
                                                    color: onSurfaceVariant,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              if (isUnread)
                                                Container(
                                                  width: 10,
                                                  height: 10,
                                                  margin: const EdgeInsets.only(bottom: 8),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: primary,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: primary.withOpacity(0.4),
                                                        blurRadius: 8,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              Icon(
                                                Icons.star_border,
                                                color: onSurfaceVariant.withOpacity(0.4),
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                ),
                
                // Bottom Navigation Bar
                Container(
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
                      Expanded(child: _buildNavItem(Icons.mail, 'Inbox', true, secondaryContainer, onSecondaryContainer)),
                      Expanded(child: _buildNavItem(Icons.school, 'Classroom', false, Colors.transparent, onSurfaceVariant, onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ClassroomScreen(),
                          ),
                        );
                      })),
                      Expanded(child: _buildNavItem(Icons.inventory_2, 'Archive', false, Colors.transparent, onSurfaceVariant)),
                      Expanded(child: _buildNavItem(Icons.settings, 'Settings', false, Colors.transparent, onSurfaceVariant, onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      })),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            backgroundColor: primary,
            foregroundColor: const Color(0xFF5C1900), // onPrimary
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.edit),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, Color activeBgColor, Color activeFgColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeBgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? activeFgColor : activeFgColor.withOpacity(0.7),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.literata(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? activeFgColor : activeFgColor.withValues(alpha: 0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
