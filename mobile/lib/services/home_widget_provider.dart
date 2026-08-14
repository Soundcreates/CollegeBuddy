import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:CollegeBuddy/models/widgetMailModel.dart';

/// This file is used as the entrypoint for the home widget
/// Make sure to add this to your AndroidManifest.xml:
/// <meta-data android:name="com.example.mobile.FLUTTER_ENTRYPOINT_META_DATA_KEY" android:value="homeWidgetProvider" />

void homeWidgetProvider() {
  runApp(const HomeWidgetApp());
}

class HomeWidgetApp extends StatelessWidget {
  const HomeWidgetApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'College Buddy Mails',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: HomeWidgetProvider(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeWidgetProvider extends StatefulWidget {
  const HomeWidgetProvider({Key? key}) : super(key: key);

  @override
  State<HomeWidgetProvider> createState() => _HomeWidgetProviderState();
}

class _HomeWidgetProviderState extends State<HomeWidgetProvider> {
  List<WidgetMailModel> mails = [];

  @override
  void initState() {
    super.initState();
    _loadMails();
  }

  Future<void> _loadMails() async {
    try {
      print("[WIDGET PROVIDER] Loading mails from widget storage (FRESH READ)");
      final data = await HomeWidget.getWidgetData<String>('emails_json') ?? '';

      if (data.isEmpty) {
        print("[WIDGET PROVIDER] No emails in storage, showing empty state");
        setState(() {
          mails = [];
        });
        return;
      }

      try {
        final decoded = jsonDecode(data) as List<dynamic>;
        setState(() {
          mails = decoded
              .map(
                (e) => WidgetMailModel.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList();
        });
        print(
          "[WIDGET PROVIDER] Loaded ${mails.length} mails from widget storage",
        );
      } catch (e) {
        print("[WIDGET PROVIDER] Error decoding widget data: $e");
        setState(() {
          mails = [];
        });
      }
    } catch (e) {
      print('Error loading mails: $e');
      setState(() {
        mails = [];
      });
    }
  }

  Future<void> _toggleMailCompletion(WidgetMailModel mail) async {
    final updatedMail = mail.copyWith(isCompleted: !mail.isCompleted);
    final updatedMails = mails.map((m) {
      return m.id == mail.id ? updatedMail : m;
    }).toList();

    setState(() {
      mails = updatedMails;
    });

    // Save to widget storage
    await HomeWidget.saveWidgetData<List<Map<String, dynamic>>>(
      'emails',
      updatedMails.map((m) => m.toJson()).toList(),
    );

    // Trigger widget update
    await HomeWidget.updateWidget(
      name: 'HomeWidgetExample',
      iOSName: 'HomeWidgetExample',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('College Buddy - Mails'), elevation: 0),
      body: mails.isEmpty
          ? const Center(child: Text('No mails to display'))
          : ListView.builder(
              itemCount: mails.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final mail = mails[index];
                return _MailTodoItem(
                  mail: mail,
                  onToggle: () => _toggleMailCompletion(mail),
                );
              },
            ),
    );
  }
}

class _MailTodoItem extends StatelessWidget {
  final WidgetMailModel mail;
  final VoidCallback onToggle;

  const _MailTodoItem({Key? key, required this.mail, required this.onToggle})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: mail.isCompleted,
            onChanged: (_) => onToggle(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        title: Text(
          mail.subject,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            decoration: mail.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              mail.from,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              mail.date,
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
        trailing: mail.isCompleted
            ? Icon(Icons.check_circle, color: Colors.green[400])
            : Icon(Icons.circle_outlined, color: Colors.grey[400]),
        onTap: onToggle,
      ),
    );
  }
}
