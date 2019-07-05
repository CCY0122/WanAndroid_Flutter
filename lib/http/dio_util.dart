import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import 'api.dart';
import 'interceptors/log_interceptors.dart';
import 'interceptors/wanandroid_error_interceptors.dart';

Dio _dio = Dio();

Dio get dio => _dio;

class DioUtil {
  static Future init() async {
    dio.options.baseUrl = Api.BASE_URL;
    dio.options.connectTimeout = 5 * 1000;
    dio.options.sendTimeout = 5 * 1000;
    dio.options.receiveTimeout = 3 * 1000;

    dio.interceptors.add(LogsInterceptors());
    dio.interceptors.add(WanAndroidErrorInterceptors());

    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path + "/dioCookie";
    print('DioUtil : http cookie path = $tempPath');
    CookieJar cj = PersistCookieJar(dir: tempPath);
    dio.interceptors.add(CookieManager(cj));
  }

  static String parseError(error, {String defErrorString = '网络连接超时或者服务器未响应'}) {
    String errStr;
    if (error is DioError) {
      if (error.type == DioErrorType.CONNECT_TIMEOUT ||
          error.type == DioErrorType.SEND_TIMEOUT ||
          error.type == DioErrorType.RECEIVE_TIMEOUT) {
        errStr = defErrorString;
      } else {
        errStr = error.message;
      }
    }
    return errStr ?? defErrorString;
  }
}
