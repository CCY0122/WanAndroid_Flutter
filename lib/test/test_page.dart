import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wanandroid_flutter/http/index.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/res/shared_preference_util.dart';

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  TextEditingController userNameController;
  TextEditingController psdController;

  @override
  void initState() {
    super.initState();
    userNameController = TextEditingController();
    psdController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return accountWidget();
        }
        if (index == 1) {
          return accountTest();
        }
        if (index == 2) {
          return TodoTest();
        }
      },
      itemCount: 3,
    );
  }

  Widget accountWidget() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text('账号 = '),
            Expanded(
              child: TextField(
                controller: userNameController,
                decoration: InputDecoration(hintText: '账号'),
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Text('密码 = '),
            Expanded(
              child: TextField(
                controller: psdController,
                decoration: InputDecoration(hintText: '密码'),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              RaisedButton(
                color: WColors.theme_color,
                textColor: Colors.white,
                child: Text('登录'),
                onPressed: () {
                  login(userNameController.text, psdController.text);
                },
              ),
              RaisedButton(
                color: WColors.theme_color,
                textColor: Colors.white,
                child: Text('注册'),
                onPressed: () {
                  regist(userNameController.text, psdController.text);
                },
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget accountTest() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          RaisedButton(
            child: Text('退出登录'),
            onPressed: () {
              logout();
            },
          ),
          RaisedButton(
            onPressed: () {
              collectTest();
            },
            child: Text('测试收藏'),
          ),
          RaisedButton(
            onPressed: () {
              printCookieFile();
            },
            child: Text('打印cookie本地文件'),
          ),
          RaisedButton(
            onPressed: () {
              printSPisLogin();
            },
            child: Text('打印SP是否登录'),
          ),
        ],
      ),
    );
  }

  Future collectTest() async {
    try {
      await dio.post("/lg/collect/1165/json");

      print("collect success");
    } catch (e) {
      print(e);
    }
  }

  Future login(String username, String password) async {
    try {
      Response response = await AccountApi.login(username, password);
      await SPUtil.setLogin(true);
      print("login success");
    } catch (e) {
      print(DioUtil.parseError(e));
    }
  }

  Future regist(String username, String password) async {
    try {
      await AccountApi.regist(username, password, password);
      print("regist success");
    } catch (e) {
      print(DioUtil.parseError(e));
    }
  }

  Future logout() async {
    try {
      await AccountApi.logout();
      await SPUtil.setLogin(false);
      print('logout success');
    } catch (e) {
      print(DioUtil.parseError(e));
    }
  }

  Future printCookieFile() async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path + "/dioCookie";
    Directory dire = Directory(tempPath);
    bool ex = await dire.exists();
    print('exists = $ex');
    flatPrintFiles(dire);

//    String s = await file.readAsString();
//    print('[[[[${s}');
  }

  flatPrintFiles(Directory dire) {
    dire.list().listen((f) {
      if (f is File) {
        print('f.name = ${f.toString()}');
        print('file = ${f.readAsStringSync()}');
      } else {
        flatPrintFiles(f);
      }
    });
  }

  Future printSPisLogin() async {
    bool islogin = await SPUtil.isLogin();
    print('isLogin = $islogin');
  }
}

class TodoTest extends StatefulWidget {
  @override
  _TodoTestState createState() => _TodoTestState();
}

class _TodoTestState extends State<TodoTest> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: <Widget>[
        RaisedButton(
          child: Text('add'),
          onPressed: () {
            TodoApi.addTodo(
              'test2',
              'test content2',
              date: TodoApi.dateFormat(
                DateTime(2019),
              ),
              type: 1,
            ).then((result) {
              print('success:${result.toString()}');
            }).catchError((e) {
              print('failed:$e');
            });
          },
        ),
        RaisedButton(
          child: Text('DELETE'),
          onPressed: (){
            TodoApi.deleteTodo(11511);
          },
        )
      ],
    );
  }
}
