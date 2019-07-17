import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wanandroid_flutter/page/account/login_wanandroid_page.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/utils/index.dart';

import 'bloc/home_index.dart';

///主页侧滑菜单
class HomeDrawer extends StatefulWidget {
  bool isLogin;

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
        }
        return Column(
          children: <Widget>[
            Container(
              color: WColors.theme_color_dark,
              height: pt(200),
            ),
            Container(
              height: pt(50),
              width: double.infinity,
              color: WColors.warning_red,
              child: FlatButton(
                onPressed: () {
                  if (widget.isLogin) {
                    homeBloc.dispatch(LogoutHome());
                  } else {
                    Navigator.pushNamed(
                            context, LoginWanandroidPage.ROUTER_NAME)
                        .then((_) {
                      homeBloc.dispatch(LoadHome());
                    });
                  }
                },
                child: Text(
                  widget.isLogin ? res.logout : res.login,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
