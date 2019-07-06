import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wanandroid_flutter/http/index.dart';
import 'package:wanandroid_flutter/page/todo/todo_list.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/utils/index.dart';

///to-do 主页
class TodoPage extends StatefulWidget {
  static const String ROUTER_NAME = "/TodoPage";

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  TextEditingController addTodoC;
  List<String> todoTemplates;

  @override
  void initState() {
    super.initState();
    addTodoC = TextEditingController();
    if (todoTemplates == null) {
      todoTemplates = ['便笺模板1', '便笺模板2', '便笺模板3', '便笺模板4'];
    }
    _getTodoTemplates().then((s) {
      todoTemplates = s;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/todo_bg.jpeg'), fit: BoxFit.cover),
        ),
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Expanded(
                    child: TodoListPage(),
                  ),
                ],
              ),
              SingleChildScrollView(
                //fixme 在android上仍不过过渡滑动
                physics: AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    Container(
                      width: pt(120),
                      height: pt(110),
                      margin: EdgeInsets.only(
                        top: pt(16),
                        bottom: pt(16),
                        left: pt(16),
                        right: pt(8),
                      ),
                      decoration: BoxDecoration(
                          color: Colors.white24,
                          boxShadow: <BoxShadow>[
                            DisplayUtil.lightElevation(),
                          ],
                          borderRadius: BorderRadius.circular(6)),
                      child: Text('xin jian'),
                      alignment: Alignment.center,
                    ),
                  ]..addAll(todoTemplates.map((s) {
                      return Container(
                        width: pt(120),
                        height: pt(110),
                        margin: EdgeInsets.only(
                          top: pt(16),
                          bottom: pt(16),
                          left: pt(8),
                          right: pt(todoTemplates.indexOf(s) ==
                                  (todoTemplates.length - 1)
                              ? 16
                              : 8),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: <BoxShadow>[
                            DisplayUtil.lightElevation(),
                          ],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Text(s),
                      );
                    }).toList()),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<List<String>> _getTodoTemplates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> temps = prefs.getStringList(SPKey.TODO_TEMPLATES);
    if (temps == null) {
      return ['便笺模板1', '便笺模板2', '便笺模板3', '便笺模板4'];
    }
    return temps;
  }

  Future _saveTodoTemplates(List<String> temps) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(SPKey.TODO_TEMPLATES, temps);
  }

  addTodo() async {
    try {
      await TodoApi.addTodo(addTodoC.text, 'content is ${addTodoC.text}');
      print('add success');
    } catch (e) {
      print(e);
    }
    if (mounted) {
      setState(() {});
    }
  }
}
