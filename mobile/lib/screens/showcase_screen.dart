import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A local, network-free product preview used only with SHOWCASE=true.
class ShowcaseScreen extends StatelessWidget {
  const ShowcaseScreen({super.key, required this.page});

  final int page;

  @override
  Widget build(BuildContext context) {
    const screens = [_Welcome(), _Inbox(), _Classroom()];
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: screens[page.clamp(0, screens.length - 1)],
    );
  }
}

const _ink = Color(0xFF17382C);
const _moss = Color(0xFF6D8550);
const _cream = Color(0xFFF8F3E8);
const _clay = Color(0xFFD86E47);
const _sun = Color(0xFFF3BF53);

class _Welcome extends StatelessWidget {
  const _Welcome();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _cream,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 20, 26, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.spa_rounded, color: _clay),
                const SizedBox(width: 8),
                Text(
                  'CollegeBuddy',
                  style: GoogleFonts.fraunces(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E9C7),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Stack(
                children: [
                  Positioned(
                    top: 22,
                    right: 25,
                    child: _Leaf(size: 105, color: _moss, turn: .55),
                  ),
                  Positioned(
                    bottom: 7,
                    left: 35,
                    child: _Leaf(size: 148, color: _clay, turn: -.7),
                  ),
                  Center(
                    child: Icon(Icons.menu_book_rounded, size: 72, color: _ink),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 42),
            Text(
              'College, in\na calmer flow.',
              style: GoogleFonts.fraunces(
                fontSize: 43,
                height: .98,
                fontWeight: FontWeight.w600,
                color: _ink,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'A gentle place for the emails, assignments, and next steps that matter.',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                height: 1.45,
                color: const Color(0xFF536A5D),
              ),
            ),
            const SizedBox(height: 34),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                label: Text(
                  'Continue with Google',
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _ink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Your study life, with more breathing room.',
                style: GoogleFonts.dmSans(fontSize: 12, color: _moss),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Inbox extends StatelessWidget {
  const _Inbox();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _cream,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CollegeBuddy',
                  style: GoogleFonts.fraunces(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                const CircleAvatar(
                  backgroundColor: _sun,
                  child: Text('A', style: TextStyle(color: _ink)),
                ),
              ],
            ),
            const SizedBox(height: 35),
            Text(
              'Good morning,\nAarav.',
              style: GoogleFonts.fraunces(
                fontSize: 37,
                height: 1,
                fontWeight: FontWeight.w600,
                color: _ink,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Three things need your attention today.',
              style: GoogleFonts.dmSans(color: _moss),
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: _moss),
                  const SizedBox(width: 10),
                  Text(
                    'Search your college mail',
                    style: GoogleFonts.dmSans(color: _moss),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'YOUR FOCUS LIST',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                letterSpacing: 1.3,
                fontWeight: FontWeight.w700,
                color: _moss,
              ),
            ),
            const SizedBox(height: 12),
            const _MailCard(
              sender: 'Computer Science Dept.',
              subject: 'Assignment 3 is due Friday',
              time: '10:24',
              unread: true,
              icon: Icons.code_rounded,
            ),
            const SizedBox(height: 11),
            const _MailCard(
              sender: 'Dr. Mehta',
              subject: 'Notes from today’s lecture',
              time: '09:10',
              unread: false,
              icon: Icons.auto_stories_rounded,
            ),
            const SizedBox(height: 11),
            const _MailCard(
              sender: 'Student Council',
              subject: 'This week on campus',
              time: 'Yesterday',
              unread: false,
              icon: Icons.local_florist_rounded,
            ),
            const Spacer(),
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: _ink,
                borderRadius: BorderRadius.circular(19),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Icon(Icons.mail_rounded, color: _sun),
                  Icon(Icons.school_rounded, color: Color(0xFFC6D6B6)),
                  Icon(Icons.settings_rounded, color: Color(0xFFC6D6B6)),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Classroom extends StatelessWidget {
  const _Classroom();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _cream,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Classroom',
                  style: GoogleFonts.fraunces(
                    fontSize: 27,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                const CircleAvatar(
                  backgroundColor: _sun,
                  child: Text('A', style: TextStyle(color: _ink)),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              'Your courses, in one view.',
              style: GoogleFonts.dmSans(color: _moss),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE3E6D4),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'Courses',
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w700,
                            color: _ink,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'All assignments',
                        style: GoogleFonts.dmSans(fontSize: 13, color: _moss),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'THIS WEEK',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                letterSpacing: 1.3,
                fontWeight: FontWeight.w700,
                color: _moss,
              ),
            ),
            const SizedBox(height: 12),
            const _CourseCard(
              title: 'Data Structures',
              detail: '2 assignments · Due Friday',
              color: _ink,
              icon: Icons.account_tree_rounded,
            ),
            const SizedBox(height: 13),
            const _CourseCard(
              title: 'Design Thinking',
              detail: '1 assignment · Due Monday',
              color: _clay,
              icon: Icons.palette_rounded,
            ),
            const SizedBox(height: 13),
            const _CourseCard(
              title: 'Environmental Studies',
              detail: 'Reading · Due next week',
              color: _moss,
              icon: Icons.eco_rounded,
            ),
            const Spacer(),
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: _ink,
                borderRadius: BorderRadius.circular(19),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Icon(Icons.mail_rounded, color: Color(0xFFC6D6B6)),
                  Icon(Icons.school_rounded, color: _sun),
                  Icon(Icons.settings_rounded, color: Color(0xFFC6D6B6)),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _MailCard extends StatelessWidget {
  const _MailCard({
    required this.sender,
    required this.subject,
    required this.time,
    required this.unread,
    required this.icon,
  });
  final String sender, subject, time;
  final bool unread;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: unread ? Colors.white : const Color(0xFFF0EBDF),
      borderRadius: BorderRadius.circular(17),
      border: unread ? Border.all(color: const Color(0xFFE7D4A1)) : null,
    ),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: unread
              ? const Color(0xFFE6EDD6)
              : const Color(0xFFE4DED0),
          child: Icon(icon, color: _moss, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sender,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subject,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                  color: _ink,
                ),
              ),
            ],
          ),
        ),
        Text(time, style: GoogleFonts.dmSans(fontSize: 10, color: _moss)),
      ],
    ),
  );
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.title,
    required this.detail,
    required this.color,
    required this.icon,
  });
  final String title, detail;
  final Color color;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
    ),
    child: Row(
      children: [
        Container(
          width: 47,
          height: 47,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.fraunces(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                detail,
                style: GoogleFonts.dmSans(fontSize: 12, color: _moss),
              ),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_ios_rounded, size: 15, color: _moss),
      ],
    ),
  );
}

class _Leaf extends StatelessWidget {
  const _Leaf({required this.size, required this.color, required this.turn});
  final double size, turn;
  final Color color;
  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: turn,
    child: Container(
      width: size * .6,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(size),
          bottomRight: Radius.circular(size),
        ),
      ),
    ),
  );
}
