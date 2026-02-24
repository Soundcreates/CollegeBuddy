import "package:mobile/api/mailApi.dart";
import "package:mobile/models/mailModel.dart";
import "package:mobile/api/authApi.dart";
import "package:mobile/models/userModel.dart";

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
          // Simulate data fetching
          final List<MailModel>?  response = await _mailFetcher.fetchUserMails();
          _mailCache = response;  
          _lastFetchTime = DateTime.now();
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
