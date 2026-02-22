import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile/api/authApi.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'email_view_screen.dart';
import "package:mobile/models/userModel.dart";
import "package:mobile/api/mailApi.dart";
import "package:mobile/models/mailModel.dart";

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthApi>();
    final mailService = context.watch<MailApi>();

    Future<List<dynamic>> _loadDashboardData() async {
        final user = await authService.currentUser;
        final mails = await mailService.fetchUserMails();

        return [user,mails];
      }
      // Mock Mail Data
    // Removed mock emails. Will use fetched mails from backend.

    return FutureBuilder(
      future: _loadDashboardData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min, // Add this to keep the column centered
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 15),
                  Text("Loading Mails", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: Text("Failed to load data"));
        }
        final user = snapshot.data![0] as UserModel? ?? null;
        final mails = snapshot.data![1] as List<MailModel>? ?? [];
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
        print("Total no of mails loaded: ${mails.length}");
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Column(
              children: [
                // Header Section
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${user?.name.split(' ')[0] ?? 'Student'}',
                            style: GoogleFonts.outfit(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('EEEE, MMM d').format(DateTime.now()),
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: user?.profilePic != null && user!.profilePic.isNotEmpty
                          ? NetworkImage(user!.profilePic)
                          : null,
                        backgroundColor: Colors.grey.shade800,
                        child: user?.profilePic == null || user!.profilePic.isEmpty
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                      ),
                    ],
                  ),
                ),

                // Mail List
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF111111),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "This Week's Mails",
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: () async {
                                  Navigator.pushReplacementNamed(context, '/login');
                                },
                                child: Text("Logout"),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: mails.isEmpty
                                ? Center(
                                    child: Text(
                                      "No mails found.",
                                      style: GoogleFonts.outfit(
                                        color: Colors.white54,
                                        fontSize: 16,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: mails.length,
                                    itemBuilder: (context, index) {
                                      final mail = mails[index];
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
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.05),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(0.05),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue.withOpacity(0.1),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.mail_outline,
                                                    color: Colors.blue,
                                                    size: 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        mail.subject,
                                                        style: GoogleFonts.outfit(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 16,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        mail.from + ' • ' + mail.date,
                                                        style: GoogleFonts.outfit(
                                                          color: Colors.grey,
                                                          fontSize: 12,
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
                                  ),
                          ),
                          // Footer
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Text(
                                "Gets refreshed every midnight",
                                style: GoogleFonts.outfit(
                                  color: Colors.white30,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
