import 'package:flutter/material.dart';
import 'package:wanandroid_flutter/page/notifications.dart';
import 'package:wanandroid_flutter/page/todo/todo_console.dart';
import 'package:wanandroid_flutter/page/todo/todo_list.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/utils/index.dart';

class TodoFilterNotification extends Notification {
  //0或null视为不过滤。

  int type;
  int priority;
  int order;

  TodoFilterNotification(this.type, this.priority, this.order);
}

///to-do 主页
class TodoPage extends StatefulWidget {
  static const String ROUTER_NAME = "/TodoPage";

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  TextEditingController addTodoC;
  int type;
  int priority;
  int order = 4;
  bool forceRegetList = false;

  @override
  void initState() {
    super.initState();
    addTodoC = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    Widget widget = Scaffold(
      appBar: AppBar(
        backgroundColor: WColors.theme_color,
        title: Text(
          res.todo,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: NotificationListener(
        onNotification: (Notification notification) {
          switch (notification.runtimeType) {
            case TodoFilterNotification:
              setState(() {
                this.type = (notification as TodoFilterNotification).type;
                this.priority =
                    (notification as TodoFilterNotification).priority;
                this.order = (notification as TodoFilterNotification).order;
              });
              return true;
            case UpdateNotification:
              if ((notification as UpdateNotification).update) {
                setState(() {
                  forceRegetList = true;
                });
              }
              return true;
          }
          return false;
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: WColors.gray_background,
          ),
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    height: pt(130),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
//                          WColors.theme_color_dark,
                          WColors.theme_color,
                          WColors.theme_color_light,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TodoListPage(
                      this.type,
                      this.priority,
                      this.order,
                      forceUpdate: this.forceRegetList,
                    ),
                  ),
                ],
              ),
              Positioned(
                top: pt(10),
                left: 0,
                right: 0,
                child: TodoConsole(),
              )
            ],
          ),
        ),
      ),
    );

    forceRegetList = false;
    return widget;
  }
}
