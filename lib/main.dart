// Flutter code sample for material.AppBar.1

// This sample shows an [AppBar] with two simple actions. The first action
// opens a [SnackBar], while the second action navigates to a new page.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanandroid_flutter/page/account/login_wanandroid_page.dart';
import 'package:wanandroid_flutter/page/todo/todo_create.dart';
import 'package:wanandroid_flutter/page/todo/todo_main.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/test/test_page.dart';

import 'http/index.dart';

///在拿不到context的地方通过navigatorKey进行路由跳转：
///https://stackoverflow.com/questions/52962112/how-to-navigate-without-context-in-flutter-app
final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

final Map<String, WidgetBuilder> routes = {
LoginWanandroidPage.ROUTER_NAME: (context) => new LoginWanandroidPage(),
MyStatelessWidget.ROUTER_NAME: (context) => new MyStatelessWidget(),
TodoPage.ROUTER_NAME: (context) => new TodoPage(),
TodoCreatePage.ROUTER_NAME: (context) => new TodoCreatePage(),};

void main() async {
  await DioUtil.init();
  runApp(MyApp());
}

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        primaryColor: WColors.theme_color,
      ),
      routes: routes,
      title: _title,
      navigatorKey: navigatorKey,
//      home: MyStatelessWidget(),
    );
  }
}

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
final SnackBar snackBar = const SnackBar(content: Text('Showing Snackbar'));

void openPage(BuildContext context) {
  Navigator.push(
    context,
    CupertinoPageRoute(
      builder: (c) {
        return Scaffold(
          body: new TestPage(),
        );
        return Material(
          child: new TestPage(),
        );
      },
    ),
  );
}

/// This is the stateless widget that the main application instantiates.
class MyStatelessWidget extends StatelessWidget {
  static const String ROUTER_NAME = "/";

  MyStatelessWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('AppBar Demo'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add_alert),
            tooltip: 'Show Snackbar',
            onPressed: () {
              scaffoldKey.currentState.showSnackBar(snackBar);
            },
          ),
          IconButton(
            icon: const Icon(Icons.navigate_next),
            tooltip: 'Next page',
            onPressed: () {
              openPage(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            FlatButton(
              child: Text('去测试页'),
              onPressed: () {
                openPage(context);
              },
            ),
            FlatButton(
              child: Text('去登录'),
              onPressed: () {
                Navigator.pushNamed(context, LoginWanandroidPage.ROUTER_NAME);
              },
            ),
            FlatButton(
              child: Text('去todo'),
              onPressed: () {
                Navigator.pushNamed(context, TodoPage.ROUTER_NAME);
              },
            ),
          ],
        ),
      ),
    );
  }
}
