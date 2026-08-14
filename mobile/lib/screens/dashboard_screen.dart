import 'package:flutter/material.dart';
import 'package:CollegeBuddy/cache/BigDataRepository.dart';
import 'package:CollegeBuddy/models/mailModel.dart';
import 'package:CollegeBuddy/models/userModel.dart';
import 'package:CollegeBuddy/screens/email_view_screen.dart';
import 'package:CollegeBuddy/theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final BigDataRepository _mailRepo = BigDataRepository();
  late Future<List<dynamic>> _loadedData;
  List<MailModel> _refreshedMails = [];

  @override
  void initState() {
    super.initState();
    _loadedData = _loadDashboardData();
  }

  Future<List<dynamic>> _loadDashboardData() async {
    final user = await _mailRepo.fetchUserData();
    final mails = await _mailRepo.fetchMailData() as List<MailModel>? ?? [];
    return [user, mails];
  }

  Future<void> _refreshInbox() async {
    try {
      final mails = await _mailRepo.refreshInbox();
      if (!mounted) return;
      setState(() => _refreshedMails = mails);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inbox refreshed — ${mails.length} messages')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Refresh failed: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _loadedData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loading();
        }
        if (snapshot.hasError) {
          return _error(snapshot.error.toString());
        }

        final user = snapshot.data?[0] as UserModel?;
        final cachedMails = snapshot.data?[1] as List<MailModel>? ?? [];
        final mails = _refreshedMails.isNotEmpty
            ? _refreshedMails
            : cachedMails;

        if (user == null) return _error('Your profile could not be loaded.');

        return Scaffold(
          backgroundColor: AppColors.cream,
          body: SafeArea(
            child: RefreshIndicator(
              color: AppColors.ink,
              backgroundColor: AppColors.paper,
              onRefresh: _refreshInbox,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CollegeBuddy',
                        style: AppText.serif(size: 28, weight: FontWeight.w700),
                      ),
                      _avatar(user),
                    ],
                  ),
                  const SizedBox(height: 34),
                  Text(
                    'Good morning,\n${_firstName(user.name)}.',
                    style: AppText.serif(size: 40, height: .98),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${mails.length == 1 ? 'One thing needs' : '${mails.length} things need'} your attention today.',
                    style: AppText.sans(size: 16, color: AppColors.moss),
                  ),
                  const SizedBox(height: 25),
                  const TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Search your college mail',
                      prefixIcon: Icon(Icons.search, size: 32),
                      contentPadding: EdgeInsets.symmetric(vertical: 20),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'YOUR FOCUS LIST',
                    style: AppText.sans(
                      size: 12,
                      weight: FontWeight.w700,
                      color: AppColors.moss,
                    ).copyWith(letterSpacing: 1.3),
                  ),
                  const SizedBox(height: 12),
                  if (mails.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'Nothing needs your attention yet.',
                          style: AppText.sans(color: AppColors.moss),
                        ),
                      ),
                    )
                  else
                    ...mails.asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 11),
                        child: _mailCard(entry.value, entry.key),
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

  Widget _mailCard(MailModel mail, int index) {
    final unread = index == 0;
    final icons = [
      Icons.code_rounded,
      Icons.auto_stories_rounded,
      Icons.local_florist_rounded,
    ];
    return InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EmailViewScreen(email: mail)),
      ),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: unread ? AppColors.paper : AppColors.mutedPaper,
          borderRadius: BorderRadius.circular(17),
          border: unread
              ? Border.all(color: const Color(0xFFE7D4A1), width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: unread
                  ? AppColors.paleMoss
                  : const Color(0xFFE4DED0),
              child: Icon(
                icons[index % icons.length],
                color: AppColors.moss,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mail.from.isEmpty ? 'Unknown sender' : mail.from,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.sans(size: 13, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    mail.subject.isEmpty
                        ? (mail.snippet.isEmpty ? 'No subject' : mail.snippet)
                        : mail.subject,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.sans(
                      size: 15,
                      weight: unread ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              mail.date,
              style: AppText.sans(size: 11, color: AppColors.moss),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(UserModel user) {
    if (user.profilePic.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(user.profilePic),
      );
    }
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.sun,
      child: Text(
        user.name.isEmpty ? 'C' : user.name[0].toUpperCase(),
        style: AppText.sans(size: 22, color: AppColors.ink),
      ),
    );
  }

  String _firstName(String name) =>
      name.trim().split(RegExp(r'\s+')).firstOrNull ?? 'there';

  Widget _loading() => const Scaffold(
    backgroundColor: AppColors.cream,
    body: Center(child: CircularProgressIndicator(color: AppColors.ink)),
  );

  Widget _error(String message) => Scaffold(
    backgroundColor: AppColors.cream,
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppText.sans(color: AppColors.moss),
        ),
      ),
    ),
  );
}
