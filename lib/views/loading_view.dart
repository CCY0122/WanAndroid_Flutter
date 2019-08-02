import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanandroid_flutter/res/index.dart';

Widget getLoading({bool start = true}) {
  return IgnorePointer(
    child: Container(
      alignment: Alignment.center,
      color: Colors.transparent,
      child: FlareActor(
        'assets/loading.flr',
        animation: 'start', //该动画定义的名字
        color: WColors.theme_color_dark,
        isPaused: start != true,
      ),
    ),
  );
}

Widget getLoadingParent({@required Widget child,Key key, bool isLoading = false}) {
  return Stack(
    key: key,
    children: <Widget>[
      child,
      Offstage(
        offstage: !isLoading,
        child: getLoading(start: isLoading),
      ),
    ],
  );
}
