import 'dart:io';

import 'package:data_plugin/bmob/bmob_query.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:wanandroid_flutter/entity/bmob_feedback_entity.dart';
import 'package:wanandroid_flutter/entity/bmob_user_entity.dart';
import 'package:wanandroid_flutter/http/index.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/utils/shared_preference_util.dart';

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  TextEditingController userNameController;
  TextEditingController psdController;

  TextEditingController _tc;
  String appName;
  String packageName;
  String version;
  String buildNumber;

  var datas;
  int level = 0;

  CounterModel counterModel = CounterModel();

  @override
  void initState() {
    super.initState();
//    SystemChrome.setEnabledSystemUIOverlays([]);
    userNameController = TextEditingController();
    psdController = TextEditingController();
    _tc = TextEditingController();

    pkif();
  }

  Future pkif() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CounterModel>.value(
      value: counterModel,
      child: ListView.builder(
        // ignore: missing_return
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
          if (index == 3) {
            return BmboTest();
          }
          if (index == 4) {
//          return getLevelWidgets(level);
            print('1');
            return Consumer<CounterModel>(
              builder:
                  (BuildContext context, CounterModel value, Widget child) {
                return GestureDetector(
                  onTap: () {
                    value.increment();
                  },
                  child: Container(
                    width: 100,
                    height: 200,
                    child: Column(
                      children: <Widget>[
                        Text('va = ${value.value}'),
                        child,
                      ],
                    ),
                  ),
                );
              },
              child: AStful(),
            );
          }
        },
        itemCount: 5,
      ),
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

  Widget BmboTest() {
    return Row(
      children: <Widget>[
        RaisedButton(
          onPressed: () {
            createOne();
          },
          child: Text('创建一条'),
        ),
        RaisedButton(
          onPressed: () {
            updateOne();
          },
          child: Text('更新一条'),
        ),
        RaisedButton(
          onPressed: () {
            queryOne();
          },
          child: Text('查询'),
        ),
        RaisedButton(
          onPressed: () {
            String t = '2019-07-28 18:44:19';
            DateTime d1 = DateTime.parse(t);
            DateTime now = DateTime.now();
            DateTime d2 = DateTime(now.year, now.month, now.day + 1);
            if (d1.isAfter(d2)) {
              print('之后');
            } else {
              print('之前');
            }

            setState(() {
              level++;
            });
          },
          child: Text('同一天？'),
        ),
      ],
    );
  }
}

Future createOne() async {
  BmobUserEntity userEntity = BmobUserEntity.empty();
  userEntity.userName = 'ccy0122';
  userEntity.signature = 'asdasdas';
  userEntity.level = 100;
  userEntity.save().then((value) {
    print('save success:${value.objectId},${value.createdAt}');
  }, onError: (e, s) {
    print('save filed $e;$s');
  });

  BmobFeedbackEntity feedbackEntity = BmobFeedbackEntity.empty();
  feedbackEntity.userName = 'asd';
  feedbackEntity.feedback = '你好啊';
  feedbackEntity.save();
}

Future queryOne() async {
  BmobQuery<BmobUserEntity> query = BmobQuery();
  query.addWhereEqualTo('userName', 'ccy01221');
  query.queryObjects().then((results) {
    print('query size = ${results.length}');
    if (results != null && results.length >= 1) {
      print('query success ${(BmobUserEntity.fromJson(results[0])).userName}');
    }
  }, onError: (e, s) {
    print('query filed $e;$s');
  });
}

Future updateOne() async {
  BmobQuery<BmobUserEntity> query = BmobQuery();
  query.addWhereEqualTo('userName', 'ccy0122');
  query.queryObjects().then((results) {
    print('query size = ${results.length}');
    if (results != null && results.length >= 1) {
      BmobUserEntity entity = BmobUserEntity.fromJson(results[0]);
      entity.level = 110;
      entity.update().then((value) {
        print('update success = ${value.updatedAt}');
      });
    }
  }, onError: (e, s) {
    print('query filed $e;$s');
  });
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
//            TodoApi.addTodo(
//              'test2',
//              'test content2',
//              completeDateMilli: DateTime.now().millisecondsSinceEpoch,
//              type: 1,
//            ).then((result) {
//              print('success:${result.toString()}');
//            }).catchError((e) {
//              print('failed:$e');
//            });
          },
        ),
        RaisedButton(
          child: Text('DELETE'),
          onPressed: () {
            TodoApi.deleteTodo(11511);
          },
        )
      ],
    );
  }
}

class AStful extends StatefulWidget {

  @override
  _AStfulState createState() => _AStfulState();

  AStful(){
    print('constar');
  }
}

class _AStfulState extends State<AStful> {
  @override
  Widget build(BuildContext context) {
    //结论，只第一次build 后续不会
    print('_AStfulState : build');
    return Container(
      child: Text('asdasd'),
    );
  }
}

class CounterModel with ChangeNotifier {
  int _count = 0;

  int get value => _count;

  void increment() {
    _count++;
    notifyListeners();
  }
}
