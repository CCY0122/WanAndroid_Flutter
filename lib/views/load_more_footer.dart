import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/utils/index.dart';

Widget getLoadMoreFooter(bool hasMore,{Color color = WColors.gray_background}) {
  return Container(
    width: double.infinity,
    height: pt(45),
    color: color,
    alignment: Alignment.center,
    child: hasMore
        ? CupertinoActivityIndicator()
        : Text(
            res.isBottomst,
            style: TextStyle(color: WColors.hint_color),
          ),
  );
}
