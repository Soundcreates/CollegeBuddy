import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import "package:CollegeBuddy/api/mailApi.dart";
import "package:CollegeBuddy/models/mailModel.dart";
import "package:CollegeBuddy/api/authApi.dart";
import "package:CollegeBuddy/models/userModel.dart";
import "package:CollegeBuddy/services/widget_service.dart";

class BigDataRepository {
  static final BigDataRepository _instance = BigDataRepository._internal();
  factory BigDataRepository() => _instance;
  BigDataRepository._internal();

  final _mailFetcher = MailApi();
  List<MailModel>? _memoryCache;
  UserModel? _userCache;

  static const _cacheDataKey = 'mail_cache_data';
  static const _cacheTimestampKey = 'mail_cache_timestamp';
  static const _cacheMaxAgeHours = 3;

  bool _isCacheTimestampValid(int tsMillis) {
    final age = DateTime.now().millisecondsSinceEpoch - tsMillis;
    return age < _cacheMaxAgeHours * 60 * 60 * 1000;
  }

  Future<List<MailModel>?> _readDiskCache() async {
    final prefs = await SharedPreferences.getInstance();
    final tsMillis = prefs.getInt(_cacheTimestampKey);
    if (tsMillis == null || !_isCacheTimestampValid(tsMillis)) return null;
    final jsonStr = prefs.getString(_cacheDataKey);
    if (jsonStr == null) return null;
    final list = json.decode(jsonStr) as List<dynamic>;
    return list
        .map((e) => MailModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _writeDiskCache(List<MailModel> mails) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch),
      prefs.setString(
        _cacheDataKey,
        json.encode(mails.map((m) => m.toJson()).toList()),
      ),
    ]);
    print("[CACHE] Wrote ${mails.length} mails to disk");
  }

  Future<void> _invalidateDiskCache() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_cacheDataKey),
      prefs.remove(_cacheTimestampKey),
    ]);
  }

  /// Returns mails from cache if < 3 hours old; otherwise fetches from the API.
  Future<List<MailModel>> fetchMailData() async {
    print("[MAIL FETCH] fetchMailData called");

    // 1. In-memory cache (valid for the current app session)
    if (_memoryCache != null) {
      final prefs = await SharedPreferences.getInstance();
      final tsMillis = prefs.getInt(_cacheTimestampKey);
      if (tsMillis != null && _isCacheTimestampValid(tsMillis)) {
        print(
          "[MAIL FETCH] Returning in-memory cache (${_memoryCache!.length} mails)",
        );
        return _memoryCache!;
      }
    }

    // 2. Disk cache (survives cold boots)
    final diskMails = await _readDiskCache();
    if (diskMails != null) {
      print(
        "[MAIL FETCH] Returning disk cache (${diskMails.length} mails, < ${_cacheMaxAgeHours}h old)",
      );
      _memoryCache = diskMails;
      return diskMails;
    }

    // 3. Fetch fresh from backend
    print("[MAIL FETCH] Cache expired or empty — fetching from backend");
    return _fetchAndCache();
  }

  /// Force a fresh fetch from the API and reset the 3-hour timer.
  Future<List<MailModel>> refreshInbox() async {
    print("[MAIL FETCH] Manual refresh triggered — bypassing cache");
    _memoryCache = null;
    await _invalidateDiskCache();
    return _fetchAndCache();
  }

  Future<List<MailModel>> _fetchAndCache() async {
    final response = await _mailFetcher.fetchUserMails();
    if (response != null && response.isNotEmpty) {
      print("[MAIL FETCH] Fetched ${response.length} emails from backend");
      _memoryCache = response;
      await _writeDiskCache(response);
      await WidgetService.updateEmails(response);
    } else {
      print(
        "[MAIL FETCH] Backend returned empty/null — keeping existing cache if any",
      );
      _memoryCache ??= [];
    }
    return _memoryCache!;
  }

  Future<UserModel?> fetchUserData() async {
    print("[PROFILE] fetchUserData called");
    if (_userCache != null) {
      print("[PROFILE] Returning cached user data");
      return _userCache;
    }
    print("[PROFILE] Fetching user profile from backend");
    final userData = await AuthApi().currentUser;
    _userCache = userData;
    print("[PROFILE] User profile fetch complete: ${_userCache != null}");
    return _userCache;
  }

  Future<void> logoutAndClearCache() async {
    await AuthApi().logout();
    _userCache = null;
    _memoryCache = null;
    await _invalidateDiskCache();
  }

  void clearUserCache() {
    _userCache = null;
  }

  void clearMailCache() {
    print("[CACHE] Clearing mail cache");
    _memoryCache = null;
    _invalidateDiskCache();
  }
}
