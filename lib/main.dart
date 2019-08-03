// Flutter code sample for material.AppBar.1

// This sample shows an [AppBar] with two simple actions. The first action
// opens a [SnackBar], while the second action navigates to a new page.

import 'package:bloc/bloc.dart';
import 'package:data_plugin/bmob/bmob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wanandroid_flutter/page/account/login_wanandroid_page.dart';
import 'package:wanandroid_flutter/page/home/drawer/about_page.dart';
import 'package:wanandroid_flutter/page/home/drawer/rank_page.dart';
import 'package:wanandroid_flutter/page/home/drawer/support_author.dart';
import 'package:wanandroid_flutter/page/home/home/home_page.dart';
import 'package:wanandroid_flutter/page/home/project/project_detail_page.dart';
import 'package:wanandroid_flutter/page/home/web_view.dart';
import 'package:wanandroid_flutter/page/search/search_page.dart';
import 'package:wanandroid_flutter/page/todo/todo_create.dart';
import 'package:wanandroid_flutter/page/todo/todo_main.dart';
import 'package:wanandroid_flutter/res/index.dart';

import 'entity/project_entity.dart';
import 'http/index.dart';

///在拿不到context的地方通过navigatorKey进行路由跳转：
///https://stackoverflow.com/questions/52962112/how-to-navigate-without-context-in-flutter-app
final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

final Map<String, WidgetBuilder> routes = {
  LoginWanandroidPage.ROUTER_NAME: (context) => new LoginWanandroidPage(),
  HomePage.ROUTER_NAME: (context) => new HomePage(),
  TodoPage.ROUTER_NAME: (context) => new TodoPage(),
  TodoCreatePage.ROUTER_NAME: (context) => new TodoCreatePage(),
  ProjectDetailPage.ROUTER_NAME: (context) => new ProjectDetailPage(),
  WebViewPage.ROUTER_NAME: (context) => WebViewPage(),
  SupportAuthorPage.ROUTER_NAME: (context) => SupportAuthorPage(),
  AboutPage.ROUTER_NAME: (context) => AboutPage(),
  RankPage.ROUTER_NAME: (c) => RankPage(),
  SearchPage.ROUTER_NAME: (_) => SearchPage(),
};

///开源版本我不会上传appkey相关数据，bmob相关操作禁用。
bool bmobEnable = false;
bool _blocDebug = true;

class GlobalBlocDel extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    if (_blocDebug) {
      print('Bloc-event : $event');
    }
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    if (_blocDebug) {
      print('Bloc-error : $error ; $stacktrace');
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    if (_blocDebug) {
      print('Bloc-Transition : $transition');
    }
  }
}

void main() async {
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  BlocSupervisor.delegate = GlobalBlocDel();
  //SDK初始化
  Bmob.initMasterKey('', '', '');
  await DioUtil.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        primaryColor: WColors.theme_color,
      ),
      routes: routes,
      title: res.appName,
      navigatorKey: navigatorKey,
      home: HomePage(),
    );
  }
}
