import 'package:home_widget/home_widget.dart';
import "package:mobile/api/mailApi.dart";
import 'package:mobile/models/mailModel.dart';
import 'package:mobile/models/widgetMailModel.dart';
import 'dart:convert';

class WidgetService {
  final MailApi mailService = MailApi();

  /// Fetches mails from API and saves them to the home widget
  Future<List<MailModel>> fetchMailsFromApi() async {
    final mails = await mailService.fetchUserMails();
    if (mails != null) {
      await updateEmails(mails);
    }
    return mails ?? [];
  }

  /// Converts MailModel list to WidgetMailModel and saves to home widget
  static Future<void> updateEmails(List<MailModel> emailList) async {
    try {
      final widgetMails = emailList
          .map((mail) => WidgetMailModel(
                id: mail.id,
                subject: mail.subject,
                from: mail.from,
                date: mail.date,
                isCompleted: false,
              ))
          .toList();

      await HomeWidget.saveWidgetData<String>(
        'emails_json',
        jsonEncode(widgetMails.map((m) => m.toJson()).toList()),
      );

      // Trigger widget update
      await HomeWidget.updateWidget(
        name: 'MyWidgetProvider',
        iOSName: 'MyWidgetProvider',
      );
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