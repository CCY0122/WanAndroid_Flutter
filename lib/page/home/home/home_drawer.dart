import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wanandroid_flutter/page/account/login_wanandroid_page.dart';
import 'package:wanandroid_flutter/page/home/drawer/support_author.dart';
import 'package:wanandroid_flutter/page/home/home/bloc/home_index.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/test/nested_test_page.dart';
import 'package:wanandroid_flutter/test/test_page.dart';
import 'package:wanandroid_flutter/utils/index.dart';

///主页侧滑菜单
class HomeDrawer extends StatefulWidget {
  bool isLogin = false;
  String userName;

  @override
  _HomeDrawerState createState() => _HomeDrawerState();

  HomeDrawer(this.isLogin);
}

class _HomeDrawerState extends State<HomeDrawer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    HomeBloc homeBloc = BlocProvider.of<HomeBloc>(context);
    return BlocBuilder<HomeEvent, HomeState>(
      bloc: homeBloc,
      builder: (context, state) {
        if (state is HomeLoaded) {
          widget.isLogin = state.isLogin;
          widget.userName = state.userName;
        }
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
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: pt(10),
                    top: pt(100),
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
                                padding:
                                    EdgeInsets.symmetric(horizontal: pt(10)),
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
                        Text(
                          '打卡机制（待做）',
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _menuItem(Icon(Icons.feedback), res.feedback, () {
              DisplayUtil.showMsg(context, text: res.feedback);
            }),
            _menuItem(Icon(Icons.attach_money), res.supportAuthor, () {
              Navigator.pushNamed(context, SupportAuthorPage.ROUTER_NAME);
            }),
            _menuItem(Icon(Icons.error_outline), res.about, () {
              DisplayUtil.showMsg(context, text: res.about);
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
//            FlatButton(
//              child: Text('去测试页'),
//              onPressed: () {
//                Navigator.push(
//                  context,
//                  MaterialPageRoute(
//                    builder: (context) {
//                      return Scaffold(
//                        body: TestPage(),
//                      );
//                    },
//                  ),
//                );
//              },
//            ),
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
    );
  }

  Widget _menuItem(Widget icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: icon,
      title: Text(title),
      onTap: onTap,
    );
  }
}
