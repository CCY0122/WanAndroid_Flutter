import 'package:shared_preferences/shared_preferences.dart';

///一些通用SharedPreferences key声明处
class SPKey {
  static const String LOGIN = "key_is_login";
  static const String USER_NAME = "user_name";
}

class SPUtil {
  static Future<bool> isLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get(SPKey.LOGIN) ?? false;
  }

  static Future setLogin(bool isLogin) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(SPKey.LOGIN, isLogin ?? false);
  }

  static Future setUserName(String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(SPKey.USER_NAME, userName);
  }

  static Future getUserName()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get(SPKey.USER_NAME) ?? '';
  }
}
