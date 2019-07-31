import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wanandroid_flutter/entity/bmob_user_entity.dart';
import 'package:wanandroid_flutter/page/base/custom_sliver_app_bar_delegate.dart';
import 'package:wanandroid_flutter/page/home/article/article_page.dart';
import 'package:wanandroid_flutter/page/home/home/bloc/home_index.dart';
import 'package:wanandroid_flutter/page/home/home/home_drawer.dart';
import 'package:wanandroid_flutter/page/home/project/project_page.dart';
import 'package:wanandroid_flutter/page/home/wxarticle/wx_article_page.dart';
import 'package:wanandroid_flutter/page/search/search_page.dart';
import 'package:wanandroid_flutter/page/todo/todo_main.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/utils/index.dart';
import 'package:wanandroid_flutter/views/loading_view.dart';
import 'package:wanandroid_flutter/views/saerch_bar.dart';

///主页
///本页存在该问题：【flutter关于NestedScrollView的这个bug：https://github.com/flutter/flutter/issues/36419】
class HomePage extends StatefulWidget {
  static const ROUTER_NAME = '/HomePage';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  BuildContext innerContext;
  HomeBloc homeBloc = HomeBloc();
  bool isLogin = false;
  String userName;
  BmobUserEntity bmobUserEntity;

  TabController _tabController;
  ScrollController _scrollController;
  bool isSearchWXArticle = false;
  TextEditingController _searchTextContriller;

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
    res.vxArticle: WXArticleSubPage(keys[1]),
    res.navigation: Scaffold(
      body: Center(
        child: Text('敬请期待'),
      ),
    ),
    res.collect: Scaffold(
      body: Center(
        child: Text('敬请期待'),
      ),
    ),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 2) {
        setState(() {
          isSearchWXArticle = true;
        });
      } else {
        setState(() {
          isSearchWXArticle = false;
        });
      }
    });
    _scrollController = ScrollController();
    _searchTextContriller = TextEditingController();
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
            userName = state.userName;
          }
          if (state is HomeSearchStarted) {
            if (!state.isSearchWXArticle) {
              Navigator.pushNamed(context, SearchPage.ROUTER_NAME,arguments: _searchTextContriller.text);
            }
          }
          if (state is HomeBmobLoaded) {
            bmobUserEntity = state.bmobUserEntity;
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
                                controller: _scrollController,
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
                                    //影响是滑到顶部后子页还能继续上滑一小段距离（我的tabBarView是包了一层上面有圆角的DecoratedBox的，滑动列表时可发现圆角背景还会上滑而不是固定住，但影响不大，页面和它内部滚动widget的滚动衔接还是在的，所以看上去都是在滑动）
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
                      child: HomeDrawer(isLogin, userName, bmobUserEntity),
                    ),
                    floatingActionButton: FloatingActionButton(
                      onPressed: () {
                        //本打算监听_scrollController，当滑动距离较大时再显示"返回顶部"按钮，但实际发现在NestedScrollView头部被收起后就收不到监听了。
                        //那么只能在TabBarView子页中监听它们自己的滚动距离，然后再通知到主页（可以用bloc发一个event、也可以发一个自定义Notification）显示"返回顶部"按钮。（嫌麻烦，不做了，永久显示吧）
                        _scrollController.animateTo(1,
                            duration: Duration(seconds: 1),
                            curve: Curves.decelerate);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.asset('images/rocket.png'),
                      ),
                      mini: true,
                      backgroundColor: WColors.theme_color,
                    ),
                  ),
                  Offstage(
                    offstage: state is! HomeLoading,
                    child: getLoading(start: state is HomeLoading),
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
            child: Hero(
              tag: 'searchBar',
              //hero的child中若有material系widget（如TextField），则父需要为Material系layout（如Scaffold、Material），否则在页面跳转期间会看到报错UI，提示祖先不是material
              child: Material(
                type: MaterialType.transparency,
                child: SearchBar(
                  height: pt(30),
                  color: Colors.grey[50],
                  child: TextField(
                    controller: _searchTextContriller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (text) {
                      if (_searchTextContriller.text != null) {
                        homeBloc.dispatch(
                          StartSearchEvent(
                              isSearchWXArticle, _searchTextContriller.text),
                        );
                      }
                    },
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                        hintText: isSearchWXArticle
                            ? res.searchWXArticleTips
                            : res.searchTips,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(),
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: isSearchWXArticle
                              ? WColors.wechat_green
                              : WColors.hint_color_dark,
                        )),
                  ),
                  iconColor: isSearchWXArticle
                      ? WColors.wechat_green
                      : WColors.hint_color_dark,
                  icon: isSearchWXArticle
                      ? Image.asset(
                          'images/wechat.png',
                          width: 24,
                          height: 24,
                        )
                      : null,
                ),
              ),
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
          padding: EdgeInsets.symmetric(vertical: pt(10), horizontal: pt(6)),
          child: Text(
            title,
            style: TextStyle(fontSize: 15),
          ),
        );
      }).toList(),
    );
  }
}
