import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wanandroid_flutter/http/index.dart';
import 'package:wanandroid_flutter/page/base/custom_sliver_app_bar_delegate.dart';
import 'package:wanandroid_flutter/page/todo/todo_main.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/utils/index.dart';
import 'package:wanandroid_flutter/views/loading_view.dart';
import 'package:wanandroid_flutter/views/saerch_bar.dart';

import 'article/article_page.dart';
import 'bloc/home_index.dart';
import 'home_drawer.dart';
import 'project/project_page.dart';

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
  static List<PageStorageKey<String>> keys = [
    PageStorageKey<String>('1'),
    PageStorageKey<String>('2'),
    PageStorageKey<String>('3'),
    PageStorageKey<String>('4'),
    PageStorageKey<String>('5'),
  ];
  Map<String, Widget> tabs = {
    res.project: ProjectSubPage(keys[0]),
    res.article: ArticleSubPage(keys[1]),
    res.vxArticle: ProjectSubPage(keys[2]),
    res.navigation: ProjectSubPage(keys[3]),
    res.collect: ProjectSubPage(keys[4]),
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
      child: BlocListener(
        bloc: homeBloc,
        listener: (context, state) {
          if (state is HomeLoadError) {
            if (innerContext != null) {
              DisplayUtil.showMsg(innerContext, exception: state.exception);
            }
          }
          if (state is HomeLoaded) {
            isLogin = state.isLogin;
          }
        },
        child: BlocBuilder<HomeEvent, HomeState>(
            bloc: homeBloc,
            builder: (context, state) {
              return Stack(
                children: <Widget>[
                  Scaffold(
                    body: Builder(builder: (context) {
                      innerContext = context;
                      return Stack(
                        children: <Widget>[
                          DecoratedBox(
                            decoration: _themeGradientDecoration(),
                            child: SafeArea(
                              child: NestedScrollView(
                                headerSliverBuilder: (BuildContext context,
                                    bool innerBoxIsScrolled) {
                                  //为了练习代码，并不是直接使用SliverAppBar来实现头部
                                  return <Widget>[
                                    SliverToBoxAdapter(
                                      child: Container(
                                        decoration: _themeGradientDecoration(),
                                        child: appBarHeader(),
                                      ),
                                    ),
                                    //因为子页TabBarView不一定都会用CustomScrollView,放弃使用SliverOverlapAbsorber + SliverOverlapInjector
                                    //使不使用所带来的影响自行修改[NestedTestPage]代码并观察滑动效果（滑到顶部后子页还能继续上滑一段距离）
                                    SliverPersistentHeader(
                                      pinned: true,
                                      floating: true,
                                      delegate: CustomSliverAppBarDelegate(
                                        minHeight: pt(40),
                                        maxHeight: pt(40),
                                        child: Container(
                                          height: pt(40),
                                          decoration:
                                              _themeGradientDecoration(),
                                          child: appBarTab(_tabController),
                                        ),
                                      ),
                                    ),
                                  ];
                                },
                                body: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(pt(10)),
                                      topRight: Radius.circular(pt(10)),
                                    ),
                                  ),
                                  child: TabBarView(
                                    controller: _tabController,
                                    children: tabs.values
                                        .map((page) => page)
                                        .toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    drawer: Drawer(
                      child: HomeDrawer(isLogin),
                    ),
                  ),
                  Offstage(
                    offstage: state is! HomeLoading,
                    child: getLoading(),
                  )
                ],
              );
            }),
      ),
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
            ),
          ),
          Expanded(
            child: SearchBar(
              height: pt(30),
              color: Colors.grey[50],
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
//              Navigator.push(context, MaterialPageRoute(builder: (c){
//                return Scaffold(body: TestPage());
//              }));
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
          padding: EdgeInsets.symmetric(vertical: pt(10), horizontal: pt(6)),
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
