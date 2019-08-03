import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'collect_web_model.dart';
import 'collect_web_view.dart';

///收藏子页
class CollectSubPage extends StatefulWidget {
  @override
  _CollectSubPageState createState() => _CollectSubPageState();
}

class _CollectSubPageState extends State<CollectSubPage> with AutomaticKeepAliveClientMixin {
  GlobalKey<AnimatedListState> animatedListKey;

  @override
  void initState() {
    super.initState();
    animatedListKey = GlobalKey();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: <Widget>[
        CollectWebView(),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
