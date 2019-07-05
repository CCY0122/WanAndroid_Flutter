import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanandroid_flutter/http/index.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/utils/index.dart';

///页面的模式
enum LoginMode {
  ///登录账户
  LOGIN,

  ///注册账户
  REGIST,
}

class LoginModeNotification extends Notification {
  final LoginMode mode;

  LoginModeNotification(this.mode);
}

///wanAndroid登录
class LoginWanandroidPage extends StatefulWidget {
  static const String ROUTER_NAME = "login_wanandroid_page";

  @override
  _LoginWanandroidPageState createState() => _LoginWanandroidPageState();
}

class _LoginWanandroidPageState extends State<LoginWanandroidPage> {
  LoginMode mode;

  @override
  void initState() {
    super.initState();
    mode = LoginMode.LOGIN;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: WColors.theme_color_dark,
        elevation: 0,
        centerTitle: true,
        title: Text(mode == LoginMode.LOGIN ? res.login : res.regist),
      ),
      body: NotificationListener<LoginModeNotification>(
        onNotification: (notification) {
          setState(() {
            mode = notification.mode;
          });
        },
        child: Container(
          color: WColors.gray_background,
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                Container(
                  height: pt(200),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        WColors.theme_color_dark,
                        WColors.theme_color,
                        WColors.theme_color_light
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  //todo 这里放自己的app logo，或者放微信？
                  top: pt(50),
                  child: Image.asset(
                    'images/ic_launcher.png',
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: pt(170)),
                  child: LoginCard(
                    mode: mode,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginCard extends StatefulWidget {
  bool isLogining;
  LoginMode mode;

  LoginCard({
    this.isLogining = false,
    this.mode = LoginMode.LOGIN,
  });

  @override
  _LoginCardState createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  TextEditingController userController;
  TextEditingController pwdController;
  TextEditingController pwdAgainController;
  FocusNode pwdFocus;
  FocusNode pwdAgainFocus;

  @override
  void initState() {
    super.initState();
    userController = TextEditingController();
    pwdController = TextEditingController();
    pwdAgainController = TextEditingController();
    pwdFocus = FocusNode();
    pwdAgainFocus = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: Colors.white,
        shadows: <BoxShadow>[
          DisplayUtil.lightElevation(),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(1),
            bottomRight: Radius.circular(1),
            topRight: Radius.elliptical(25, 25),
            bottomLeft: Radius.elliptical(25, 25),
          ),
        ),
      ),
      child: Container(
          width: pt(310),
          padding: EdgeInsets.all(
            pt(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              //用户名
              Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: pt(16)),
                    child: Icon(
                      Icons.account_circle,
                      color: WColors.theme_color,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      onSubmitted: (String str) {
                        FocusScope.of(context).requestFocus(pwdFocus);
                      },
                      textInputAction: TextInputAction.next,
                      controller: userController,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w300,
                      ),
                      decoration: InputDecoration(
                        hintText: res.username,
                        hintStyle: TextStyle(
                          fontSize: 16,
                          color: WColors.hint_color,
                        ),
                        contentPadding: EdgeInsets.only(
                          top: pt(10),
                          bottom: pt(4),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: pt(20),
              ),
              //密码
              Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: pt(16)),
                    child: Icon(
                      Icons.lock,
                      color: WColors.theme_color,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      onSubmitted: (String str) {
                        if (widget.mode == LoginMode.REGIST) {
                          FocusScope.of(context).requestFocus(pwdAgainFocus);
                        }
                      },
                      textInputAction: widget.mode == LoginMode.LOGIN
                          ? TextInputAction.done
                          : TextInputAction.next,
                      focusNode: pwdFocus,
                      controller: pwdController,
                      style: TextStyle(
                          fontSize: pt(22), fontWeight: FontWeight.w300),
                      decoration: InputDecoration(
                        hintText: res.password,
                        hintStyle: TextStyle(
                          fontSize: 16,
                          color: WColors.hint_color,
                        ),
                        contentPadding: EdgeInsets.only(
                          top: pt(10),
                          bottom: pt(4),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              //确认密码
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.only(
                    top: widget.mode == LoginMode.LOGIN ? 0 : pt(20)),
                child: Offstage(
                  offstage: widget.mode != LoginMode.REGIST,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: pt(0),
                    ),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: pt(16)),
                          child: Icon(
                            Icons.lock,
                            color: WColors.theme_color,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            focusNode: pwdAgainFocus,
                            controller: pwdAgainController,
                            style: TextStyle(
                                fontSize: pt(22), fontWeight: FontWeight.w300),
                            decoration: InputDecoration(
                              hintText: res.rePassword,
                              hintStyle: TextStyle(
                                fontSize: 16,
                                color: WColors.hint_color,
                              ),
                              contentPadding: EdgeInsets.only(
                                top: pt(10),
                                bottom: pt(4),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: pt(30),
              ),
              //登录注册按钮
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: pt(20)),
                child: RaisedButton(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(1),
                          topRight: Radius.elliptical(14, 14),
                          bottomLeft: Radius.elliptical(14, 14),
                          bottomRight: Radius.circular(1)),
                    ),
                    onPressed: widget.isLogining
                        ? null
                        : () {
                            if (widget.mode == LoginMode.LOGIN) {
                              login(userController.text, pwdController.text);
                            } else {
                              regist(userController.text, pwdController.text,
                                  pwdAgainController.text);
                            }
                          },
                    textColor: Colors.white,
                    color: WColors.theme_color,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: pt(8)),
                      child: widget.isLogining
                          ? CupertinoActivityIndicator()
                          : Text(
                              widget.mode == LoginMode.LOGIN
                                  ? res.login
                                  : res.regist,
                              style: TextStyle(fontSize: 18),
                            ),
                    )),
              ),
              SizedBox(
                height: pt(15),
              ),
              //登录注册切换按钮
              Container(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                    child: Text(
                      widget.mode == LoginMode.LOGIN ? res.regist : res.login,
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.grey,
                      ),
                    ),
                    onTap: () {
                      if (widget.isLogining) {
                        return;
                      }
                      LoginModeNotification(widget.mode == LoginMode.LOGIN
                              ? LoginMode.REGIST
                              : LoginMode.LOGIN)
                          .dispatch(context);
                    }),
              ),
            ],
          )),
    );
  }

  ///登录
  Future login(String username, String password) async {
    setState(() {
      widget.isLogining = true;
    });

    try {
      await AccountApi.login(username, password);
      await SPUtil.setLogin(true);
      print('_LoginCardState : login success');
      Navigator.of(context).pop();
      return;
    } catch (e) {
      DisplayUtil.showMsg(context, exception: e);
    }

    setState(() {
      widget.isLogining = false;
    });
  }

  ///注册并登录
  Future regist(String username, String password, String rePassword) async {
    setState(() {
      widget.isLogining = true;
    });

    try {
      await AccountApi.regist(username, password, rePassword);
      print('_LoginCardState : regist success');
      await AccountApi.login(username, password);
      await SPUtil.setLogin(true);
      print('_LoginCardState : login success');
      Navigator.of(context).pop();
      return;
    } catch (e) {
      DisplayUtil.showMsg(context, exception: e);
    }

    setState(() {
      widget.isLogining = false;
    });
  }
}
