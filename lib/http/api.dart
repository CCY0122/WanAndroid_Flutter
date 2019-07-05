import 'dio_util.dart';
import 'index.dart';

class Api {
  static const String BASE_URL = "https://www.wanandroid.com";
  static const int ERROR_CODE_UN_LOGIN = -1001;
}


///账户相关接口
class AccountApi {
  static const String LOGIN_PATH = "/user/login";
  static const String REGIST_PATH = "/user/register";
  static const String LOGOUT_PATH = "/user/logout/json";

  static Future<Response> login(String username, String password) {
    return dio.post(LOGIN_PATH, queryParameters: {
      "username": username,
      "password": password,
    });
  }

  static Future<Response> regist(String username, String password, String repassword) {
    return dio.post(REGIST_PATH, queryParameters: {
      "username": username,
      "password": password,
      "repassword": repassword,
    });
  }

  static Future<Response> logout(){
    return dio.get(LOGOUT_PATH);
  }
}

class TodoApi {}
