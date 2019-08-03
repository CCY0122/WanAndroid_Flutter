import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wanandroid_flutter/page/home/home/bloc/home_index.dart';
import 'package:wanandroid_flutter/res/index.dart';

import 'collect_list_view.dart';
import 'collect_web_view.dart';

///收藏子页
class CollectSubPage extends StatefulWidget {
  @override
  _CollectSubPageState createState() => _CollectSubPageState();
}

class _CollectSubPageState extends State<CollectSubPage>
    with AutomaticKeepAliveClientMixin {
  GlobalKey<AnimatedListState> animatedListKey;
  bool isLogin = false;
  StreamSubscription subscription;

  @override
  void initState() {
    super.initState();
    animatedListKey = GlobalKey();
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (subscription == null) {
      HomeBloc homeBloc = BlocProvider.of<HomeBloc>(context);
      subscription = homeBloc.state.listen((state) {
        if (state is HomeLoaded) {
          print('收藏子页：主页加载完成，获取最新登录状态');
          setState(() {
            isLogin = state.isLogin;
          });
        } else if (homeBloc.alredyHomeloaded) {
          print('收藏子页：在构造函数之前主页就已经加载完成并可能已经发送了其他bloc state，获取最新登录状态');
          setState(() {
            isLogin = homeBloc.isLogin;
          });
        }
      });
    }
    print('build');
    return !isLogin
        ? Center(
            child: Text(res.loginFirst),
          )
        : Column(
            children: <Widget>[
              //两个子布局相互独立，各自拥有各自的provider
              CollectWebView(),
              Expanded(
                child: CollectListView(),
              ),
            ],
          );
  }

  @override
  bool get wantKeepAlive => true;
}
