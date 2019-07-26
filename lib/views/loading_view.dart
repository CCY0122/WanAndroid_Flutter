import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/utils/index.dart';

//后期改flare动画
Widget getLoading() {
  return IgnorePointer(
    child: Container(
      alignment: Alignment.center,
      color: Colors.transparent,
      child: Container(
        color: WColors.theme_color.withAlpha(0x99),
        width: pt(100),
        height: pt(100),
        alignment: Alignment.center,
        child: CupertinoActivityIndicator(),
      ),
    ),
  );
}
