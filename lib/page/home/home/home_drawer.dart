import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wanandroid_flutter/entity/bmob_user_entity.dart';
import 'package:wanandroid_flutter/page/account/login_wanandroid_page.dart';
import 'package:wanandroid_flutter/page/home/drawer/about_page.dart';
import 'package:wanandroid_flutter/page/home/drawer/support_author.dart';
import 'package:wanandroid_flutter/page/home/home/bloc/home_index.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/test/test_page.dart';
import 'package:wanandroid_flutter/utils/index.dart';
import 'package:wanandroid_flutter/views/level_view.dart';

///主页侧滑菜单
class HomeDrawer extends StatefulWidget {
  bool isLogin = false;
  String userName;
  BmobUserEntity bmobUserEntity;

  HomeDrawer(this.isLogin, this.userName, this.bmobUserEntity);

  @override
  _HomeDrawerState createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  HomeBloc homeBloc;

  @override
  void initState() {
    super.initState();
    homeBloc = BlocProvider.of<HomeBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    bool canSignin = widget.bmobUserEntity != null &&
        !isToday(DateTime.parse(widget.bmobUserEntity.updatedAt));
    return BlocListener<HomeEvent, HomeState>(
      bloc: homeBloc,
      listener: (context, state) {
        //这里监听状态并赋值属性不合适。因为侧滑菜单在直到第一次展开时才被初始化。此时监听为时已晚
      },
      child: BlocBuilder<HomeEvent, HomeState>(
        bloc: homeBloc,
        builder: (context, state) {
          return Column(
            children: <Widget>[
              Container(
                height: pt(200),
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('images/drawer_bg.jpeg'),
                        fit: BoxFit.cover,
                        alignment: Alignment.center)),
                alignment: Alignment.center,
                child: SafeArea(
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        left: pt(10),
                        top: pt(15),
                        child: widget.bmobUserEntity == null
                            ? Container()
                            : GestureDetector(
                                onTap: () {
                                  if (canSignin) {
                                    widget.bmobUserEntity.level++;
                                    homeBloc.dispatch(
                                        UpdateBmobInfo(widget.bmobUserEntity));
                                  }
                                },
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      canSignin ? res.signin : res.signined,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    SizedBox(
                                      width: pt(5),
                                    ),
                                    Image.asset(
                                      'images/signin.png',
                                      color: Colors.white,
                                      width: 25,
                                      height: 25,
                                    )
                                  ],
                                ),
                              ),
                      ),
                      Positioned(
                        right: pt(10),
                        top: pt(15),
                        child: widget.bmobUserEntity == null
                            ? Container()
                            : GestureDetector(
                                onTap: () {
                                  DisplayUtil.showMsg(context, text: '点击了排行榜');
                                },
                                child: Image.asset(
                                  'images/rank.png',
                                  color: Colors.white,
                                  width: 30,
                                  height: 30,
                                ),
                              ),
                      ),
                      Positioned(
                        left: pt(10),
                        bottom: pt(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(pt(17)),
                                  child: widget.isLogin
                                      ? Image.asset(
                                          'images/user_icon.jpeg',
                                          fit: BoxFit.cover,
                                          width: pt(34),
                                          height: pt(34),
                                        )
                                      : Icon(
                                          Icons.account_circle,
                                          color: Colors.white,
                                          size: pt(34),
                                        ),
                                ),
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    if (!widget.isLogin) {
                                      Navigator.pushNamed(context,
                                              LoginWanandroidPage.ROUTER_NAME)
                                          .then((_) {
                                        homeBloc.dispatch(LoadHome());
                                      });
                                    }
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: pt(10)),
                                    child: Text(
                                      widget.userName ?? res.login,
                                      style: TextStyle(
                                          fontSize: 26,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: widget.bmobUserEntity == null
                                  ? Container()
                                  : GestureDetector(
                                      onTap: () {
                                        //todo 个性签名
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            widget.bmobUserEntity.signature,
                                            style:
                                                TextStyle(color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          getLevelWidgets(
                                              widget.bmobUserEntity.level),
                                        ],
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _menuItem(Icon(Icons.feedback), res.feedback, () {
                DisplayUtil.showMsg(context, text: res.feedback);
              }),
              _menuItem(Icon(Icons.attach_money), res.supportAuthor, () {
                Navigator.pushNamed(context, SupportAuthorPage.ROUTER_NAME);
              }),
              _menuItem(Icon(Icons.error_outline), res.about, () {
                Navigator.pushNamed(context, AboutPage.ROUTER_NAME);
              }),
              _menuItem(Icon(Icons.account_circle),
                  widget.isLogin ? res.logout : res.login, () {
                Navigator.pop(context);
                if (widget.isLogin) {
                  homeBloc.dispatch(LogoutHome());
                } else {
                  Navigator.pushNamed(context, LoginWanandroidPage.ROUTER_NAME)
                      .then((_) {
                    homeBloc.dispatch(LoadHome());
                  });
                }
              }),
              FlatButton(
                child: Text('去测试页'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return Scaffold(
                          body: TestPage(),
                        );
                      },
                    ),
                  );
                },
              ),
//            FlatButton(
//              child: Text('去nest'),
//              onPressed: () {
//                Navigator.push(
//                  context,
//                  MaterialPageRoute(
//                    builder: (context) {
//                      return Scaffold(
//                        body: NestedTestPage(),
//                      );
//                    },
//                  ),
//                );
//              },
//            ),
            ],
          );
        },
      ),
    );
  }

  Widget _menuItem(Widget icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: icon,
      title: Text(title),
      onTap: onTap,
    );
  }

  //更新时间是否在今天？
  bool isToday(DateTime updateTime) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(
      now.year,
      now.month,
      now.day,
    );
    return updateTime.isAfter(today.toUtc());
  }
}
