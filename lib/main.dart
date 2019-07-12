// Flutter code sample for material.AppBar.1

// This sample shows an [AppBar] with two simple actions. The first action
// opens a [SnackBar], while the second action navigates to a new page.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanandroid_flutter/page/account/login_wanandroid_page.dart';
import 'package:wanandroid_flutter/page/home/home_page.dart';
import 'package:wanandroid_flutter/page/todo/todo_create.dart';
import 'package:wanandroid_flutter/page/todo/todo_main.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/test/test_page.dart';
import 'package:bloc/bloc.dart';
import 'http/index.dart';

///在拿不到context的地方通过navigatorKey进行路由跳转：
///https://stackoverflow.com/questions/52962112/how-to-navigate-without-context-in-flutter-app
final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

final Map<String, WidgetBuilder> routes = {
  LoginWanandroidPage.ROUTER_NAME: (context) => new LoginWanandroidPage(),
  HomePage.ROUTER_NAME: (context) => new HomePage(),
  TodoPage.ROUTER_NAME: (context) => new TodoPage(),
  TodoCreatePage.ROUTER_NAME: (context) => new TodoCreatePage(),
};

class GlobalBlocDel extends BlocDelegate {

  @override
  void onEvent(Bloc bloc, Object event) {
    if(true){
      print('Bloc-event : $event');
    }
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    if(true){
      print('Bloc-error : $error ; $stacktrace');
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    if(true){
      print('Bloc-Transition : $transition');
    }
  }
}

void main() async {
  BlocSupervisor.delegate = GlobalBlocDel();
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
      home: TodoPage(),
    );
  }
}



