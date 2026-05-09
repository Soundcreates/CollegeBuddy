import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mobile/api/classroomApi.dart';
import 'package:mobile/models/classroomModel.dart';
import 'package:mobile/screens/assignment_detail_screen.dart';
import 'package:mobile/screens/settings_screen.dart';
import 'package:mobile/cache/BigDataRepository.dart';
import 'package:mobile/models/userModel.dart';

class ClassroomScreen extends StatefulWidget {
  const ClassroomScreen({super.key});

  @override
  State<ClassroomScreen> createState() => _ClassroomScreenState();
}

class _ClassroomScreenState extends State<ClassroomScreen>
    with SingleTickerProviderStateMixin {
  final ClassroomApi _api = ClassroomApi();
  final BigDataRepository _repo = BigDataRepository();

  late TabController _tabController;
  UserModel? _user;

  // Data
  List<CourseModel> _courses = [];
  List<AssignmentModel> _allAssignments = [];
  Map<String, List<AssignmentModel>> _courseAssignments = {};

  // Loading states
  bool _loadingCourses = true;
  bool _loadingGlobal = true;
  String? _selectedCourseId;
  bool _loadingCourseAssignments = false;

  // ─── Colors (earthy dark theme) ───
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    _user = await _repo.fetchUserData();

    // Fetch courses and global assignments in parallel
    final coursesFuture = _api.fetchCourses();
    final globalFuture = _api.fetchAllAssignments();

    final courses = await coursesFuture;
    final global = await globalFuture;

    if (mounted) {
      setState(() {
        _courses = courses;
        _allAssignments = global;
        _loadingCourses = false;
        _loadingGlobal = false;
      });
    }
  }

  Future<void> _loadCourseAssignments(String courseId) async {
    if (_courseAssignments.containsKey(courseId)) {
      setState(() => _selectedCourseId = courseId);
      return;
    }

    setState(() {
      _selectedCourseId = courseId;
      _loadingCourseAssignments = true;
    });

    final assignments = await _api.fetchCourseAssignments(courseId);

    if (mounted) {
      setState(() {
        _courseAssignments[courseId] = assignments;
        _loadingCourseAssignments = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCoursesTab(),
                  _buildGlobalTab(),
                ],
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  // ─── App Bar ───
  Widget _buildAppBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: outlineVariant.withOpacity(0.3)),
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
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: primary, size: 20),
                onPressed: () => Navigator.pop(context),
                splashRadius: 24,
              ),
              const SizedBox(width: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Classroom',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Your courses & assignments',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: onSurfaceVariant.withOpacity(0.7),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: outlineVariant, width: 1.5),
              image: _user != null && _user!.profilePic.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(_user!.profilePic),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _user == null || _user!.profilePic.isEmpty
                ? Icon(Icons.person, color: onSurfaceVariant, size: 18)
                : null,
          ),
        ],
      ),
    );
  }

  // ─── Tab Bar ───
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: primary,
        unselectedLabelColor: onSurfaceVariant.withOpacity(0.6),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Courses'),
          Tab(text: 'All Assignments'),
        ],
      ),
    );
  }

  // ─── Courses Tab ───
  Widget _buildCoursesTab() {
    if (_loadingCourses) {
      return _buildLoadingState('Loading your courses...');
    }

    if (_courses.isEmpty) {
      return _buildEmptyState(
        icon: Icons.school_outlined,
        title: 'No courses found',
        subtitle: 'Your active Google Classroom courses will appear here.',
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        ..._courses.asMap().entries.map((entry) {
          final i = entry.key;
          final course = entry.value;
          return FadeInUp(
            delay: Duration(milliseconds: i * 60),
            child: _buildCourseCard(course),
          );
        }),

        // Show assignments for selected course
        if (_selectedCourseId != null) ...[
          const SizedBox(height: 24),
          _buildCourseAssignmentsSection(),
        ],
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildCourseCard(CourseModel course) {
    final isSelected = _selectedCourseId == course.id;
    return GestureDetector(
      onTap: () => _loadCourseAssignments(course.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withOpacity(0.08)
              : surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? primary.withOpacity(0.4)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? primary.withOpacity(0.15)
                    : surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  course.name.isNotEmpty ? course.name[0].toUpperCase() : 'C',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? primary : onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.name,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: onSurface,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (course.section.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      course.section,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: onSurfaceVariant.withOpacity(0.7),
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.keyboard_arrow_down_rounded
                  : Icons.chevron_right_rounded,
              color: isSelected ? primary : onSurfaceVariant.withOpacity(0.5),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseAssignmentsSection() {
    if (_loadingCourseAssignments) {
      return _buildLoadingState('Loading assignments...');
    }

    final assignments = _courseAssignments[_selectedCourseId] ?? [];
    if (assignments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No assignments for this course',
            style: GoogleFonts.inter(
              color: onSurfaceVariant.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Assignments',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: onSurface,
              letterSpacing: -0.3,
            ),
          ),
        ),
        ...assignments.asMap().entries.map((entry) {
          return FadeInUp(
            delay: Duration(milliseconds: entry.key * 50),
            child: _buildAssignmentCard(entry.value),
          );
        }),
      ],
    );
  }

  // ─── Global Assignments Tab ───
  Widget _buildGlobalTab() {
    if (_loadingGlobal) {
      return _buildLoadingState('Loading all assignments...');
    }

    if (_allAssignments.isEmpty) {
      return _buildEmptyState(
        icon: Icons.assignment_outlined,
        title: 'No assignments found',
        subtitle: 'Assignments from all courses will appear here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _allAssignments.length + 1,
      itemBuilder: (context, index) {
        if (index == _allAssignments.length) {
          return const SizedBox(height: 100);
        }
        final assignment = _allAssignments[index];
        return FadeInUp(
          delay: Duration(milliseconds: index * 40),
          child: _buildAssignmentCard(assignment, showCourse: true),
        );
      },
    );
  }

  // ─── Assignment Card ───
  Widget _buildAssignmentCard(AssignmentModel assignment,
      {bool showCourse = false}) {
    final hasDue = assignment.hasDueDate;
    final hasMaterials = assignment.materials.isNotEmpty;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AssignmentDetailScreen(assignment: assignment),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: outlineVariant.withOpacity(0.15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course badge (only in global view)
            if (showCourse && assignment.courseName.isNotEmpty) ...[
              Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: secondaryContainer.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        assignment.courseName,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: onSecondaryContainer,
                          letterSpacing: 0.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],

            // Title
            Text(
              assignment.title,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: onSurface,
                letterSpacing: -0.3,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Description preview
            if (assignment.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                assignment.description,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: onSurfaceVariant.withOpacity(0.7),
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 12),

            // Bottom row: due date + materials count + points
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (hasDue) ...[
                        Icon(Icons.schedule_rounded,
                            size: 14, color: primary.withOpacity(0.8)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            assignment.dueDate,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: primary.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 14),
                      ],
                      if (hasMaterials) ...[
                        Icon(Icons.attach_file_rounded,
                            size: 14, color: onSurfaceVariant.withOpacity(0.5)),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            '${assignment.materials.length} file${assignment.materials.length > 1 ? 's' : ''}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: onSurfaceVariant.withOpacity(0.5),
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 14),
                      ],
                      if (assignment.maxPoints > 0) ...[
                        Icon(Icons.star_outline_rounded,
                            size: 14, color: onSurfaceVariant.withOpacity(0.5)),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            '${assignment.maxPoints.toInt()} pts',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: onSurfaceVariant.withOpacity(0.5),
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: onSurfaceVariant.withOpacity(0.3)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Loading State ───
  Widget _buildLoadingState(String message) {
    return Center(
      child: FadeIn(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: GoogleFonts.inter(
                color: onSurfaceVariant.withOpacity(0.6),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Empty State ───
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: FadeIn(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: surfaceContainerHighest.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: onSurfaceVariant.withOpacity(0.5)),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: onSurfaceVariant.withOpacity(0.6),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Bottom Navigation ───
  Widget _buildBottomNav() {
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
          Expanded(
              child: _buildNavItem(Icons.mail, 'Inbox', false,
                  Colors.transparent, onSurfaceVariant, onTap: () {
            Navigator.pop(context);
          })),
          Expanded(
              child: _buildNavItem(Icons.school, 'Classroom', true,
                  secondaryContainer, onSecondaryContainer)),
          Expanded(
              child: _buildNavItem(Icons.inventory_2, 'Archive', false,
                  Colors.transparent, onSurfaceVariant)),
          Expanded(
              child: _buildNavItem(Icons.settings, 'Settings', false,
                  Colors.transparent, onSurfaceVariant, onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()));
          })),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive,
      Color activeBgColor, Color activeFgColor,
      {VoidCallback? onTap}) {
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
            Icon(icon,
                color: isActive
                    ? activeFgColor
                    : activeFgColor.withOpacity(0.7)),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? activeFgColor
                      : activeFgColor.withOpacity(0.7),
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
