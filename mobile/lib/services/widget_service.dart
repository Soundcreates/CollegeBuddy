import 'package:home_widget/home_widget.dart';
import "package:CollegeBuddy/api/mailApi.dart";
import 'package:CollegeBuddy/models/mailModel.dart';
import 'package:CollegeBuddy/models/widgetMailModel.dart';
import 'dart:convert';

class WidgetService {
  final MailApi mailService = MailApi();

  /// Fetches mails from API and saves them to the home widget
  /// NO CACHING - Always fetches fresh data
  Future<List<MailModel>> fetchMailsFromApi() async {
    print("[WIDGET SERVICE] Fetching FRESH mails from API (NO CACHE)");
    final mails = await mailService.fetchUserMails();
    if (mails != null) {
      print("[WIDGET SERVICE] Fetched ${mails.length} mails, updating widget");
      await updateEmails(mails);
    } else {
      print("[WIDGET SERVICE] Failed to fetch mails");
    }
    return mails ?? [];
  }

  /// Converts MailModel list to WidgetMailModel and saves to home widget
  /// Always overwrites with fresh data
  static Future<void> updateEmails(List<MailModel> emailList) async {
    try {
      print("[WIDGET UPDATE] Updating widget with ${emailList.length} emails (clearing old data)");
      final widgetMails = emailList
          .map((mail) => WidgetMailModel(
                id: mail.id,
                subject: mail.subject,
                from: mail.from,
                date: mail.date,
                isCompleted: false,
              ))
          .toList();

      // Clear old data first
      await HomeWidget.saveWidgetData<String>(
        'emails_json',
        jsonEncode(widgetMails.map((m) => m.toJson()).toList()),
      );

      // Also clear the old 'emails' key if it exists
      await HomeWidget.saveWidgetData<String>('emails', '');

      print("[WIDGET UPDATE] Widget data saved successfully");

      // Trigger widget update
      await HomeWidget.updateWidget(
        name: 'MyWidgetProvider',
        iOSName: 'MyWidgetProvider',
      );
      print("[WIDGET UPDATE] Widget refresh triggered");
    } catch (e) {
      print('Error updating widget: $e');
    }
  }

  /// Mark a specific email as completed/uncompleted
  static Future<void> toggleMailCompletion(String mailId) async {
    try {
      final data = await HomeWidget.getWidgetData<String>('emails_json');
      if (data == null || data.isEmpty) return;
      final decoded = jsonDecode(data) as List<dynamic>;
      final mails = decoded
          .map((e) => WidgetMailModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      final updatedMails = mails.map((m) {
        if (m.id == mailId) {
          return m.copyWith(isCompleted: !m.isCompleted);
        }
        return m;
      }).toList();

      await HomeWidget.saveWidgetData<String>(
        'emails_json',
        jsonEncode(updatedMails.map((m) => m.toJson()).toList()),
      );

      await HomeWidget.updateWidget(
        name: 'MyWidgetProvider',
        iOSName: 'MyWidgetProvider',
      );
    } catch (e) {
      print('Error toggling mail completion: $e');
    }
  }
}
