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
      if(
        _mailCache != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < const Duration(hours: 5)
        ){
        print("Returning cached data");
          return _mailCache;
        } else {
          final List<MailModel>?  response = await _mailFetcher.fetchUserMails();

          // Do not poison cache when fetch fails (e.g. missing/expired token).
          if (response != null) {
            _mailCache = response;
            _lastFetchTime = DateTime.now();
            await WidgetService.updateEmails(response);
          }

          return _mailCache;
        }
    }

  Future<UserModel?> fetchUserData() async {
    if(_userCache != null){
      print("Returning cached user data");
      return _userCache;
    } else {
      // Simulate user data fetching
      final userData = await AuthApi().currentUser;
      _userCache = userData;
      return _userCache;   
    }
  }

  Future<void> logoutAndClearCache() async {
    await AuthApi().Logout();
    _userCache = null;
    _mailCache = null;
  }
 }
