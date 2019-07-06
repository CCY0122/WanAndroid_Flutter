import 'package:shared_preferences/shared_preferences.dart';

///一些通用SharedPreferences key声明处
class SPKey {
  static const String LOGIN = "key_is_login";
  static const String TODO_TEMPLATES = 'key_todo_templates';
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
}
