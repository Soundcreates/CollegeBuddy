import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderScope;
import 'package:CollegeBuddy/api/authApi.dart';
import 'package:CollegeBuddy/api/classroomApi.dart';
import 'package:provider/provider.dart';
import 'screens/loading_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/classroom_screen.dart';
import "package:CollegeBuddy/api/mailApi.dart";
import 'screens/settings_screen.dart';
import 'screens/showcase_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (error, stackTrace) {
    debugPrint('Failed to load .env: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  // Register deep links before first frame so cold-start OAuth callbacks are caught.
  AuthApi().initDeepLinks();

  const showcase = bool.fromEnvironment('SHOWCASE', defaultValue: false);
  if (showcase) {
    runApp(const ShowcaseScreen(page: int.fromEnvironment('SHOWCASE_PAGE')));
    return;
  }
  runApp(
    ProviderScope(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthApi()),
          ChangeNotifierProvider(create: (_) => MailApi()),
          ChangeNotifierProvider(create: (_) => ClassroomApi()),
        ],
        child: const CollegeBuddyApp(),
      ),
    ),
  );
}

class CollegeBuddyApp extends StatelessWidget {
  const CollegeBuddyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: 'CollegeBuddy',
      debugShowCheckedModeBanner: false,
      theme: collegeBuddyTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoadingScreen(),
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainScreen(),
        '/dashboard': (context) => const MainScreen(),
        '/classroom': (context) => const ClassroomScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
