import "package:mobile/api/mailApi.dart";
import "package:mobile/models/mailModel.dart";
import "package:mobile/api/authApi.dart";
import "package:mobile/models/userModel.dart";
import "package:mobile/services/widget_service.dart";

class BigDataRepository{
  static final BigDataRepository _instance = BigDataRepository._internal();
  factory BigDataRepository() => _instance;
  BigDataRepository._internal();
  final _mailFetcher = MailApi();
  List<MailModel>? _mailCache;
  DateTime? _lastFetchTime;
  UserModel? _userCache;

  Future<dynamic> fetchMailData() async {
      print("[MAIL FETCH] fetchMailData called");
      // CACHE COMPLETELY DISABLED - Always fetch fresh data
      print("[MAIL FETCH] Fetching FRESH mail data from backend (NO caching)...");
      _mailCache = null;  // Clear cache before fetch
      final List<MailModel>?  response = await _mailFetcher.fetchUserMails();

      if (response != null) {
        print("[MAIL FETCH] Successfully fetched ${response.length} emails from backend");
        _mailCache = response;
        _lastFetchTime = DateTime.now();
        // Always update widget with fresh data
        await WidgetService.updateEmails(response);
        print("[MAIL FETCH] Widget updated with ${response.length} emails");
      } else {
        print("[MAIL FETCH] Failed to fetch emails from backend");
        _mailCache = null;
      }

      return _mailCache ?? [];
    }

  Future<UserModel?> fetchUserData() async {
    print("[PROFILE] fetchUserData called");
    if(_userCache != null){
      print("[PROFILE] Returning cached user data");
      return _userCache;
    } else {
      print("[PROFILE] Fetching user profile from backend");
      final userData = await AuthApi().currentUser;
      _userCache = userData;
      print("[PROFILE] User profile fetch complete: ${_userCache != null}");
      return _userCache;   
    }
  }

  Future<void> logoutAndClearCache() async {
    await AuthApi().Logout();
    _userCache = null;
    _mailCache = null;
  }

  void clearMailCache() {
    print("[CACHE] Clearing mail cache");
    _mailCache = null;
    _lastFetchTime = null;
  }
 }
