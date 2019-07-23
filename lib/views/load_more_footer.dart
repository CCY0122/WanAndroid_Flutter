import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/utils/index.dart';

Widget getLoadMoreFooter(bool hasMore) {
  return Container(
    width: double.infinity,
    height: pt(45),
    color: WColors.gray_background,
    alignment: Alignment.center,
    child: hasMore
        ? CupertinoActivityIndicator()
        : Text(
            res.isBottomst,
            style: TextStyle(color: WColors.hint_color),
          ),
  );
}
