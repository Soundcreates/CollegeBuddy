import 'package:flutter/material.dart';
import 'package:mobile/api/authApi.dart';
import 'package:mobile/api/classroomApi.dart';
import 'package:provider/provider.dart';
import 'screens/loading_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/classroom_screen.dart';
import "package:mobile/api/mailApi.dart";
import 'screens/settings_screen.dart';
import 'screens/showcase_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  const showcase = bool.fromEnvironment('SHOWCASE', defaultValue: false);
  if (showcase) {
    runApp(const ShowcaseScreen(page: int.fromEnvironment('SHOWCASE_PAGE')));
    return;
  }
  dotenv.load(isOptional: true);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthApi()),
        ChangeNotifierProvider(create: (_) => MailApi()),
        ChangeNotifierProvider(create: (_) => ClassroomApi()),
      ],
      child: CollegeBuddyApp(),
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
        '/main': (context) => const MainScreen(),
        '/dashboard': (context) => const MainScreen(), // Legacy support
        '/classroom': (context) => const ClassroomScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
