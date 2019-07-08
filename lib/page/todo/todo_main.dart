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

  @override
  void initState() {
    super.initState();
    addTodoC = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: WColors.theme_color_dark,
        title: Text(
          res.todo,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          color: WColors.gray_background,
        ),
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  height: pt(100),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        WColors.theme_color_dark,
                        WColors.theme_color,
                        WColors.theme_color_light,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Expanded(
                  child: TodoListPage(),
                ),
              ],
            ),
            Positioned(
              top: pt(38),
              left: 0,
              right: 0,
              child: Container(
                height: pt(80),
                margin: EdgeInsets.symmetric(horizontal: pt(16)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    DisplayUtil.supreLightElevation()
                  ],
                ),
              ),
            )
          ],
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
