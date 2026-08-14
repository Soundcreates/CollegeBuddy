import 'package:flutter/material.dart';
import 'package:CollegeBuddy/api/classroomApi.dart';
import 'package:CollegeBuddy/cache/BigDataRepository.dart';
import 'package:CollegeBuddy/models/classroomModel.dart';
import 'package:CollegeBuddy/models/userModel.dart';
import 'package:CollegeBuddy/screens/assignment_detail_screen.dart';
import 'package:CollegeBuddy/theme/app_theme.dart';

class ClassroomScreen extends StatefulWidget {
  const ClassroomScreen({super.key});

  @override
  State<ClassroomScreen> createState() => _ClassroomScreenState();
}

class _ClassroomScreenState extends State<ClassroomScreen>
    with SingleTickerProviderStateMixin {
  final ClassroomApi _api = ClassroomApi();
  final BigDataRepository _repo = BigDataRepository();
  late final TabController _tabController;

  UserModel? _user;
  List<CourseModel> _courses = [];
  List<AssignmentModel> _allAssignments = [];
  Map<String, List<AssignmentModel>> _courseAssignments = {};
  bool _loadingCourses = true;
  bool _loadingGlobal = true;
  String? _selectedCourseId;
  bool _loadingCourseAssignments = false;

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
    final results = await Future.wait([
      _api.fetchCourses(),
      _api.fetchAllAssignments(),
    ]);
    if (!mounted) return;
    setState(() {
      _courses = results[0] as List<CourseModel>;
      _allAssignments = results[1] as List<AssignmentModel>;
      _loadingCourses = false;
      _loadingGlobal = false;
    });
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
    if (!mounted) return;
    setState(() {
      _courseAssignments[courseId] = assignments;
      _loadingCourseAssignments = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Classroom',
                        style: AppText.serif(size: 32, weight: FontWeight.w700),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'Your courses, in one view.',
                        style: AppText.sans(size: 16, color: AppColors.moss),
                      ),
                    ],
                  ),
                  _avatar(),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE3E6D4),
                borderRadius: BorderRadius.circular(13),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColors.ink,
                unselectedLabelColor: AppColors.moss,
                labelStyle: AppText.sans(size: 15, weight: FontWeight.w700),
                unselectedLabelStyle: AppText.sans(size: 15),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Courses'),
                  Tab(text: 'All assignments'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildCoursesTab(), _buildGlobalTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesTab() {
    if (_loadingCourses) return _loading('Loading your courses...');
    if (_courses.isEmpty) {
      return _empty(
        Icons.school_outlined,
        'No courses found',
        'Your active Google Classroom courses will appear here.',
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        _sectionLabel('THIS WEEK'),
        const SizedBox(height: 12),
        ..._courses.asMap().entries.map(
          (entry) => _courseCard(entry.value, entry.key),
        ),
        if (_selectedCourseId != null) ...[
          const SizedBox(height: 12),
          _buildCourseAssignmentsSection(),
        ],
      ],
    );
  }

  Widget _buildGlobalTab() {
    if (_loadingGlobal) return _loading('Loading all assignments...');
    if (_allAssignments.isEmpty) {
      return _empty(
        Icons.assignment_outlined,
        'No assignments found',
        'Assignments from all courses will appear here.',
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        _sectionLabel('THIS WEEK'),
        const SizedBox(height: 12),
        ..._allAssignments.map(
          (assignment) => _assignmentCard(assignment, showCourse: true),
        ),
      ],
    );
  }

  Widget _courseCard(CourseModel course, int index) {
    final selected = _selectedCourseId == course.id;
    final colors = [AppColors.ink, AppColors.clay, AppColors.moss];
    final assignmentCount = _allAssignments
        .where((a) => a.courseId == course.id)
        .length;
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _loadCourseAssignments(course.id),
        child: Ink(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(20),
            border: selected
                ? Border.all(color: AppColors.sun, width: 2)
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(_courseIcon(index), color: Colors.white, size: 29),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.serif(size: 20),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.section.isNotEmpty
                          ? course.section
                          : '$assignmentCount assignment${assignmentCount == 1 ? '' : 's'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.sans(size: 14, color: AppColors.moss),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 17,
                color: AppColors.moss,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseAssignmentsSection() {
    if (_loadingCourseAssignments) return _loading('Loading assignments...');
    final assignments = _courseAssignments[_selectedCourseId] ?? [];
    if (assignments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No assignments for this course',
            style: AppText.sans(color: AppColors.moss),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('ASSIGNMENTS'),
        const SizedBox(height: 12),
        ...assignments.map(_assignmentCard),
      ],
    );
  }

  Widget _assignmentCard(
    AssignmentModel assignment, {
    bool showCourse = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AssignmentDetailScreen(assignment: assignment),
          ),
        ),
        child: Ink(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showCourse && assignment.courseName.isNotEmpty) ...[
                Text(
                  assignment.courseName.toUpperCase(),
                  style: AppText.sans(
                    size: 11,
                    weight: FontWeight.w700,
                    color: AppColors.moss,
                  ).copyWith(letterSpacing: 1),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                assignment.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.serif(size: 20),
              ),
              if (assignment.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  assignment.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.sans(size: 13, color: AppColors.moss),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  if (assignment.hasDueDate) ...[
                    const Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: AppColors.moss,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        assignment.dueDate,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.sans(size: 12, color: AppColors.moss),
                      ),
                    ),
                  ],
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.moss,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(
    label,
    style: AppText.sans(
      size: 12,
      weight: FontWeight.w700,
      color: AppColors.moss,
    ).copyWith(letterSpacing: 1.3),
  );

  IconData _courseIcon(int index) => [
    Icons.account_tree_rounded,
    Icons.palette_rounded,
    Icons.eco_rounded,
  ][index % 3];

  Widget _avatar() {
    final user = _user;
    if (user?.profilePic.isNotEmpty == true) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(user!.profilePic),
      );
    }
    return const CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.sun,
      child: Text('A', style: TextStyle(color: AppColors.ink, fontSize: 22)),
    );
  }

  Widget _loading(String message) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: AppColors.ink),
        const SizedBox(height: 18),
        Text(message, style: AppText.sans(color: AppColors.moss)),
      ],
    ),
  );

  Widget _empty(IconData icon, String title, String subtitle) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: AppColors.moss),
          const SizedBox(height: 16),
          Text(title, style: AppText.serif(size: 20)),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppText.sans(size: 13, color: AppColors.moss),
          ),
        ],
      ),
    ),
  );
}
