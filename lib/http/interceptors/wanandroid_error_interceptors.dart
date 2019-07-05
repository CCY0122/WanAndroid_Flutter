import 'dart:convert';

import 'package:wanandroid_flutter/page/account/login_wanandroid_page.dart';

import '../../main.dart';
import '../index.dart';

/// ```
/// {
///    "data": ...,
///    "errorCode": 0,
///    "errorMsg":
/// }
/// ```
///wanAndroid统一接口返回格式错误检测
class WanAndroidErrorInterceptors extends InterceptorsWrapper {
  @override
  onRequest(RequestOptions options) {
    return options;
  }

  @override
  onError(DioError err) {
    return err;
  }

  @override
  onResponse(Response response) {
    var data = response.data;

    if (data is String) {
      try {
        data = json.decode(data);
      } catch (e) {}
    }

    if (data is Map) {
      int errorCode = data['errorCode'] ?? 0;
      String errorMsg = data['errorMsg'] ?? '请求失败[$errorCode]';

      if (errorCode == -1001 /*未登录错误码*/) {
        dio.clear();
        goLogin();
        return dio.reject(errorMsg);
      } else if (errorCode < 0) {
        return dio.reject(errorMsg);
      } else {
        return response;
      }
    }

    return response;
  }

  void goLogin() {
    ///在拿不到context的地方通过navigatorKey进行路由跳转：
    ///https://stackoverflow.com/questions/52962112/how-to-navigate-without-context-in-flutter-app
    navigatorKey.currentState.pushNamed(LoginWanandroidPage.ROUTER_NAME);
  }
}
