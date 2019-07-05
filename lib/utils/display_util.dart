import 'package:flutter/material.dart';
import 'package:wanandroid_flutter/http/dio_util.dart';
import 'package:wanandroid_flutter/res/index.dart';

///统一风格的常用UI展示
class DisplayUtil {
  ///通用tosat。必须在Scaffold内
  static void showMsg(
    BuildContext context, {
    String text,
    Exception exception,
    bool isErrorMsg,
    Duration duration = const Duration(seconds: 2, milliseconds: 500),
  }) {
    isErrorMsg ??= (exception != null);
    Scaffold.of(context).showSnackBar(
      SnackBar(
        elevation: 4,
        backgroundColor: isErrorMsg ? WColors.warning_red : null,
        content: Text(
          text ?? DioUtil.parseError(exception),
          style: TextStyle(color: Colors.white),
        ),
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  ///比直接设置elevation的悬浮感更轻薄的背景阴影
  static BoxShadow lightElevation() {
    return BoxShadow(
      color: Color(0xFFEBEBEB),
      blurRadius: 9,
      spreadRadius: 3,
    );
  }
}
