import 'package:flutter/material.dart';
import 'package:mobile/api/authApi.dart';
import 'package:provider/provider.dart';
import 'screens/loading_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => Authapi(),
      child: const CollegeBuddyApp(),
    ),
  );
}

class CollegeBuddyApp extends StatelessWidget {
  const CollegeBuddyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CollegeBuddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.dark(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
          surface: Color(0xFF111111),
        ),
      ),
      initialRoute: '/', // Start with the loading screen
      routes: {
        '/': (context) => const LoadingScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
