import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import 'api.dart';
import 'interceptors/log_interceptors.dart';

Dio _dio = Dio();

Dio get dio => _dio;

class DioUtil {
  static Future init() async {
    dio.options.baseUrl = Api.BASE_URL;
    dio.options.connectTimeout = 5 * 1000;
    dio.options.sendTimeout = 5 * 1000;
    dio.options.receiveTimeout = 3 * 1000;

    dio.interceptors.add(LogsInterceptors());

    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    print('DioUtil : http cookie path = $tempPath');
    CookieJar cj = PersistCookieJar(dir: tempPath);
    dio.interceptors.add(CookieManager(cj));
  }
}
