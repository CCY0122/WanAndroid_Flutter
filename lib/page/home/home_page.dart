import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wanandroid_flutter/http/index.dart';
import 'package:wanandroid_flutter/page/base/custom_sliver_app_bar_delegate.dart';
import 'package:wanandroid_flutter/page/todo/todo_main.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/utils/index.dart';
import 'package:wanandroid_flutter/views/loading_view.dart';
import 'package:wanandroid_flutter/views/saerch_bar.dart';

import 'bloc/home_index.dart';
import 'home_drawer.dart';

class HomePage extends StatefulWidget {
  static const ROUTER_NAME = '/HomePage';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  BuildContext innerContext;
  HomeBloc homeBloc = HomeBloc();
  bool isLogin = false;
  TabController _tabController;
  Map<String, Widget> tabs = {
    '1': SimpleList(
      'a',
      key: PageStorageKey(1),
    ),
    '2': SimpleList(
      'b',
      key: PageStorageKey(2),
    ),
    '333': SimpleList(
      'c',
      key: PageStorageKey(3),
    ),
    'asdasd': SimpleList(
      'd',
      key: PageStorageKey(4),
    ),
    'hhh': SimpleList(
      'e',
      key: PageStorageKey(5),
    ),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    homeBloc.dispatch(LoadHome());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProviderTree(
      blocProviders: [
        BlocProvider<HomeBloc>(
          builder: (context) => homeBloc,
        ),
      ],
      child: BlocBuilder<HomeEvent, HomeState>(
          bloc: homeBloc,
          builder: (context, state) {
            return Scaffold(
              body: Builder(builder: (context) {
                innerContext = context;
                return Stack(
                  children: <Widget>[
                    DecoratedBox(
                      decoration: _themeGradientDecoration(),
                      child: SafeArea(
                        child: NestedScrollView(
                          headerSliverBuilder:
                              (BuildContext context, bool innerBoxIsScrolled) {
                            //为了练习代码，并不是直接使用SliverAppBar来实现头部
                            return <Widget>[
                              SliverToBoxAdapter(
                                child: Container(
                                  decoration: _themeGradientDecoration(),
                                  child: appBarHeader(),
                                ),
                              ),
                              SliverPersistentHeader(
                                pinned: true,
                                floating: true,
                                delegate: CustomSliverAppBarDelegate(
                                  minHeight: pt(40),
                                  maxHeight: pt(40),
                                  child: Container(
                                    height: pt(40),
                                    decoration: _themeGradientDecoration(),
                                    child: appBarTab(_tabController),
                                  ),
                                ),
                              ),
                            ];
                          },
                          body: TabBarView(
                            controller: _tabController,
                            children: tabs.values.map((page) => page).toList(),
                          ),
                        ),
                      ),
                    ),
                    Offstage(
                      offstage: state is! HomeLoading,
                      child: getLoading(),
                    )
                  ],
                );
              }),
              drawer: Drawer(
                child: HomeDrawer(),
              ),
            );
          }),
    );
  }

  Decoration _themeGradientDecoration() {
    return BoxDecoration(
        gradient: LinearGradient(
      colors: [
//        WColors.theme_color_dark,
        WColors.theme_color,
        WColors.theme_color_light,
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ));
  }

  ///头部标题栏
  Widget appBarHeader() {
    HomeState state = homeBloc.currentState;
    if (state is HomeLoaded) {
      isLogin = state.isLogin;
    }
    return Container(
      height: pt(60),
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Scaffold.of(innerContext).openDrawer();
            },
            child: Container(
              width: pt(34),
              height: pt(34),
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: pt(12)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(pt(17)),
                child: isLogin
                    ? Image.asset(
                        'images/todo_bg.jpeg',
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
            ),
          ),
          Expanded(
            child: SearchBar(
              height: pt(30),
              color: Colors.grey[200],
              child: TextField(
                textInputAction: TextInputAction.search,
                onSubmitted: (text) {
                  //todo 去搜索结果页
                  print('on submitted');
                  DisplayUtil.showMsg(innerContext, text: 'asd');
                },
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                    hintText: res.searchTips,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(),
                    hintStyle: TextStyle(
                      fontSize: 12,
                      color: WColors.hint_color_dark,
                    )),
              ),
              iconColor: WColors.hint_color_dark,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, TodoPage.ROUTER_NAME);
            },
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(left: pt(12), right: pt(6)),
              child: Icon(
                Icons.assignment,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///头部tab栏
  Widget appBarTab(TabController tabController) {
    return TabBar(
      isScrollable: true,
      controller: tabController,
      indicatorSize: TabBarIndicatorSize.label,
      indicatorColor: Colors.white,
      tabs: tabs.keys.map((title) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: pt(10), horizontal: pt(8)),
          child: Text(
            title,
            style: TextStyle(fontSize: 15),
          ),
        );
      }).toList(),
    );
  }

  Future logout() async {
    try {
      await AccountApi.logout();
      await SPUtil.setLogin(false);
      print('logout success');
      setState(() {
        isLogin = false;
      });
    } catch (e) {
      DisplayUtil.showMsg(innerContext, exception: e);
    }
  }
}

class SimpleList extends StatefulWidget {
  String prefix;
  PageStorageKey scrollableWidgetKey;

  SimpleList(this.prefix, {Key key}) : scrollableWidgetKey = key;

  @override
  _SimpleListState createState() => _SimpleListState();
}

class _SimpleListState extends State<SimpleList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WColors.gray_background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: ListView.builder(
        key: widget.scrollableWidgetKey,
        itemBuilder: (c, i) {
          return Container(
            height: pt(50),
            alignment: Alignment.center,
            child: Text('${widget.prefix} $i'),
          );
        },
        itemCount: 20,
      ),
    );
  }
}
