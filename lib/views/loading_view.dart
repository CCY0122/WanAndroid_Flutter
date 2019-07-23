import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanandroid_flutter/utils/index.dart';

//后期改flare动画
Widget getLoading() {
  return IgnorePointer(
    child: Container(
      alignment: Alignment.center,
      color: Colors.transparent,
      child: Container(
        color: Colors.red[200],
        width: pt(100),
        height: pt(100),
        alignment: Alignment.center,
        child: CupertinoActivityIndicator(),
      ),
    ),
  );
}
