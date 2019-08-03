import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wanandroid_flutter/entity/article_type_entity.dart';
import 'package:wanandroid_flutter/entity/project_entity.dart';
import 'package:wanandroid_flutter/page/account/login_wanandroid_page.dart';
import 'package:wanandroid_flutter/page/home/home/bloc/home_index.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/utils/index.dart';
import 'package:wanandroid_flutter/utils/string_decode.dart';
import 'package:wanandroid_flutter/views/Article_type_view.dart';
import 'package:wanandroid_flutter/views/load_more_footer.dart';
import 'package:wanandroid_flutter/views/loading_view.dart';

import '../web_view.dart';
import 'bloc/wxArticle_index.dart';

///公众号页.
///BloC模式
///如法炮制博文页[ArticleSubPage]，但是多了公众号搜索功能逻辑
class WXArticleSubPage extends StatefulWidget {
  PageStorageKey pageStorageKey;

  WXArticleSubPage(this.pageStorageKey);

  @override
  _WXArticleSubPageState createState() => _WXArticleSubPageState();
}

class _WXArticleSubPageState extends State<WXArticleSubPage>
    with AutomaticKeepAliveClientMixin {
  WXArticleBloc wXArticleBloc;
  List<ArticleTypeEntity> types;
  List<ProjectEntity> wXArticleDatas;
  int currentProjectPage;
  int totalProjectPage;
  int selectTypeId;
  ScrollController collaspTypeScrollController;
  bool typeIsExpanded;
  String searchKey;

  ///不能直接使用[WXArticleLoading]作为是否在加载的依据
  bool isLoading = false;

  GlobalKey rootKey;
  GlobalKey typeKey;

  @override
  void initState() {
    super.initState();
    wXArticleBloc = WXArticleBloc(BlocProvider.of<HomeBloc>(context));
    types ??= [];
    wXArticleDatas ??= [];
    currentProjectPage ??= 1;
    totalProjectPage ??= 1;
    selectTypeId = 408; //408是'鸿洋'公众号分类id
    typeIsExpanded = false;
    rootKey = GlobalKey();
    typeKey = GlobalKey();
    collaspTypeScrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProviderTree(
      key: rootKey,
      blocProviders: [
        BlocProvider<WXArticleBloc>(builder: (context) => wXArticleBloc),
      ],
      child: BlocListenerTree(
        blocListeners: [
          BlocListener<HomeEvent, HomeState>(
            bloc: BlocProvider.of<HomeBloc>(context),
            listener: (context, state) {
              if (state is HomeSearchStarted) {
                if (state.isSearchWXArticle && !isLoading) {
                  searchKey = state.searchKey;
                  wXArticleBloc.dispatch(LoadMoreWXArticleDatas(
                    originDatas: [],
                    id: selectTypeId,
                    page: 1,
                    searchKey: searchKey,
                  ));
                }
              }
            },
          ),
          BlocListener<WXArticleEvent, WXArticleState>(
            bloc: wXArticleBloc,
            listener: (context, state) {
              if (state is WXArticleLoading) {
                isLoading = true;
              } else if (state is WXArticleLoaded ||
                  state is WXArticleLoadError) {
                isLoading = false;
              }

              if (state is WXArticleTypesloaded) {
                types = state.WXArticleTypes;
              } else if (state is WXArticleDatasLoaded) {
                wXArticleDatas = state.datas;
                currentProjectPage = state.curretnPage;
                totalProjectPage = state.totalPage;
              } else if (state is WXArticleCollectChanged) {
                wXArticleDatas
                    .where((e) => e.id == state.id)
                    .map((e) => e.collect = state.collect)
                    .toList();
              } else if (state is WXArticleLoadError) {
                DisplayUtil.showMsg(context, exception: state.exception);
              }
            },
          )
        ],
        child: BlocBuilder<WXArticleEvent, WXArticleState>(
          bloc: wXArticleBloc,
          builder: (context, state) {
            return NotificationListener(
              onNotification: (notification) {
                //不要在这里检测加载更多，因为子树可能有多个垂直滚动widget
                //so问题来了：如何在NotificationListener确定一个ScrollNotification是由哪个scrollable widget发来的？
              },
              child: Stack(
                children: <Widget>[
                  NotificationListener(
                    onNotification: (notification) {
                      if (notification is ScrollUpdateNotification) {
                        //确定是公众号列表发出来的滚动，而不是公众号分类栏发出来的滚动
                        if (notification.metrics.axis == Axis.vertical) {
                          //确定是否到达了底部
                          if (notification.metrics.pixels >=
                              notification.metrics.maxScrollExtent) {
                            //确定当前允许加载更多
                            if (state is WXArticleLoaded &&
                                currentProjectPage < totalProjectPage) {
                              wXArticleBloc.dispatch(
                                LoadMoreWXArticleDatas(
                                  originDatas: wXArticleDatas,
                                  page: currentProjectPage + 1,
                                  id: selectTypeId,
                                  searchKey: searchKey,
                                ),
                              );
                            }
                            return false;
                          }
                        }
                      }
                      return false;
                    },
                    child: RefreshIndicator(
                      color: WColors.theme_color,
                      onRefresh: () async {
                        if (!isLoading) {
                          searchKey = null; //下拉刷新时取消掉搜索key
                          wXArticleBloc.dispatch(LoadWXArticle(selectTypeId));
                        }
                        //app有自己的加载框样式，不使用RefreshIndicator拉出来的圆球作为加载框。所以onRefresh立即返回，让圆球立即消失
                        return;
                      },
                      child: CustomScrollView(
                        key: widget.pageStorageKey,
                        //在NestedScrollView的文档注释里有这句话：
                        // The "controller" and "primary" members should be left
                        // unset, so that the NestedScrollView can control this
                        // inner scroll view.
                        // If the "controller" property is set, then this scroll
                        // view will not be associated with the NestedScrollView.
                        // 所以这里不能设置controller
//                controller: _scrollController,
                        physics: AlwaysScrollableScrollPhysics(
                            parent: ClampingScrollPhysics()),
                        slivers: <Widget>[
                          //头部分类栏
                          SliverToBoxAdapter(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                colors: [
                                  WColors.theme_color,
                                  WColors.theme_color_light,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              )),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  //分类
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: pt(16), top: pt(16)),
                                    child: Text(
                                      res.author,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  ArticleTypeView.collaspTypesView(
                                    collaspTypeScrollController:
                                        collaspTypeScrollController,
                                    key: typeKey,
                                    types: types,
                                    selectId: selectTypeId,
                                    onExpanded: () {
                                      setState(() {
                                        typeIsExpanded = true;
                                      });
                                    },
                                    onSelected: (selectId) {
                                      if (!isLoading) {
                                        setState(() {
                                          selectTypeId = selectId;
                                          wXArticleBloc.dispatch(
                                            LoadMoreWXArticleDatas(
                                              originDatas: [],
                                              page: 1,
                                              id: selectTypeId,
                                              searchKey: searchKey,
                                            ),
                                          );
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //文章列表
                          SliverPadding(
                              padding: EdgeInsets.only(
                                top: pt(10),
                              ),
                              sliver: WXArticleList(datas: wXArticleDatas)),
                          //底部footer
                          SliverToBoxAdapter(
                            child: getLoadMoreFooter(
                              currentProjectPage < totalProjectPage,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //展开的分类
                  Positioned(
                    top: _getExpandedViewMarginTop(typeKey),
                    left: 0,
                    right: 0,
                    child: Offstage(
                      offstage: !typeIsExpanded,
                      child: AnimatedOpacity(
                        opacity: typeIsExpanded ? 1 : 0,
                        duration: Duration(milliseconds: 400),
                        child: ArticleTypeView.expandedTypesView(
                          types: types,
                          selectId: selectTypeId,
                          onExpanded: () {
                            setState(() {
                              typeIsExpanded = false;
                            });
                          },
                          onSelected: (selectId) {
                            if (!isLoading) {
                              setState(() {
                                typeIsExpanded = false;
                                selectTypeId = selectId;
                                wXArticleBloc.dispatch(
                                  LoadMoreWXArticleDatas(
                                    originDatas: [],
                                    page: 1,
                                    id: selectTypeId,
                                    searchKey: searchKey,
                                  ),
                                );
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  //加载框
                  Offstage(
                    offstage: !isLoading,
                    child: getLoading(start: isLoading),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  double _getExpandedViewMarginTop(GlobalKey relativeViewkey) {
    if (rootKey.currentContext?.findRenderObject() == null ||
        relativeViewkey.currentContext?.findRenderObject() == null) {
      return 0.0;
    }
    RenderBox renderBox = rootKey.currentContext.findRenderObject();
    double rootGlobalY = renderBox.localToGlobal(Offset.zero).dy;
    renderBox = relativeViewkey.currentContext.findRenderObject();
    double relativeViewGlobalY = renderBox.localToGlobal(Offset.zero).dy;
    return Math.max(0.0, relativeViewGlobalY - rootGlobalY);
  }

  ///公众号列表
  Widget WXArticleList({List<ProjectEntity> datas = const []}) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        ProjectEntity data = datas[index];
        return WXArticleItem(data, isLoading);
      }, childCount: datas.length),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class WXArticleItem extends StatefulWidget {
  ProjectEntity data;
  bool isLoading;

  WXArticleItem(
    this.data,
    this.isLoading,
  );

  @override
  _WXArticleItemState createState() => _WXArticleItemState();
}

class _WXArticleItemState extends State<WXArticleItem>
    with SingleTickerProviderStateMixin {
  bool lastCollectState;
  AnimationController _collectController;
  Animation _collectAnim;

  @override
  void initState() {
    super.initState();
    _collectController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    CurvedAnimation curvedAnimation =
        CurvedAnimation(parent: _collectController, curve: Curves.easeOut);
    _collectAnim = Tween<double>(begin: 1, end: 1.8).animate(curvedAnimation);
  }

  @override
  void dispose() {
    _collectController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (lastCollectState == false && lastCollectState != widget.data.collect) {
      _collectController.forward(from: 0).then((_) {
        _collectController.reverse();
      });
    }
    lastCollectState = widget.data.collect;
    return Column(
      children: [
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.only(right: pt(8), left: pt(8)),
          leading: GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: Container(
              alignment: Alignment.center,
              width: 40, //查看源码，这是leading的最小宽高
              height: 40,
              child: ScaleTransition(
                scale: _collectAnim,
                child: Icon(
                  widget.data.collect ? Icons.favorite : Icons.favorite_border,
                  color:
                      widget.data.collect ? WColors.warning_red : Colors.grey,
                  size: 24,
                ),
              ),
            ),
            onTap: () {
              if (!widget.isLoading) {
                if (BlocProvider.of<HomeBloc>(context).isLogin) {
                  BlocProvider.of<WXArticleBloc>(context).dispatch(
                    CollectWXArticle(widget.data.id, !widget.data.collect),
                  );
                } else {
                  Navigator.pushNamed(context, LoginWanandroidPage.ROUTER_NAME)
                      .then((_) {
                    BlocProvider.of<HomeBloc>(context).dispatch(LoadHome());
                  });
                }
              }
            },
          ),
          title: Text(
            decodeString(widget.data.title),
            style: TextStyle(
              fontSize: 15,
            ),
          ),
          subtitle: Row(
            children: [
              widget.data.type == 1 //目前本人通过对比json差异猜测出type=1表示置顶类型
                  ? Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.red[700])),
                      margin: EdgeInsets.only(right: pt(6)),
                      padding: EdgeInsets.symmetric(horizontal: pt(4)),
                      child: Text(
                        res.stickTop,
                        style: TextStyle(
                            color: Colors.red[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 10),
                      ),
                    )
                  : Container(),
              widget.data.fresh
                  ? Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: WColors.warning_red)),
                      margin: EdgeInsets.only(right: pt(6)),
                      padding: EdgeInsets.symmetric(horizontal: pt(4)),
                      child: Text(
                        res.New,
                        style: TextStyle(
                            color: WColors.warning_red,
                            fontWeight: FontWeight.w600,
                            fontSize: 10),
                      ),
                    )
                  : Container(),

              ///WanAndroid文档原话：superChapterId其实不是一级分类id，因为要拼接跳转url，内容实际都挂在二级分类下，所以该id实际上是一级分类的第一个子类目的id，拼接后故可正常跳转
              widget.data.superChapterId == 294 //项目
                  ? Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: WColors.theme_color_dark)),
                      margin: EdgeInsets.only(right: pt(6)),
                      padding: EdgeInsets.symmetric(horizontal: pt(4)),
                      child: Text(
                        res.project,
                        style: TextStyle(
                            color: WColors.theme_color_dark,
                            fontWeight: FontWeight.w600,
                            fontSize: 10),
                      ),
                    )
                  : Container(),
              widget.data.superChapterId == 440 //问答
                  ? Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: WColors.theme_color)),
                      margin: EdgeInsets.only(right: pt(6)),
                      padding: EdgeInsets.symmetric(horizontal: pt(4)),
                      child: Text(
                        res.QA,
                        style: TextStyle(
                            color: WColors.theme_color,
                            fontWeight: FontWeight.w600,
                            fontSize: 10),
                      ),
                    )
                  : Container(),
              Expanded(
                child: Text(
                    '${res.author}：${widget.data.author}  ${res.time}：${widget.data.niceDate}'),
              ),
            ],
          ),
          onTap: () {
            Navigator.pushNamed(
              context,
              WebViewPage.ROUTER_NAME,
              arguments: {
                'title': widget.data.title,
                'url': widget.data.link,
              },
            );
          },
        ),
        Divider(
          height: 10,
        ),
      ],
    );
  }
}
