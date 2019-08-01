import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wanandroid_flutter/entity/article_type_entity.dart';
import 'package:wanandroid_flutter/entity/project_entity.dart';
import 'package:wanandroid_flutter/page/account/login_wanandroid_page.dart';
import 'package:wanandroid_flutter/page/home/article/bloc/article_index.dart';
import 'package:wanandroid_flutter/page/home/home/bloc/home_index.dart';
import 'package:wanandroid_flutter/page/home/web_view.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/utils/index.dart';
import 'package:wanandroid_flutter/utils/string_decode.dart';
import 'package:wanandroid_flutter/views/article_type_view.dart';
import 'package:wanandroid_flutter/views/load_more_footer.dart';
import 'package:wanandroid_flutter/views/loading_view.dart';

///博文页
class ArticleSubPage extends StatefulWidget {
  PageStorageKey pageStorageKey;

  ArticleSubPage(this.pageStorageKey);

  @override
  _ArticleSubPageState createState() => _ArticleSubPageState();
}

class _ArticleSubPageState extends State<ArticleSubPage>
    with AutomaticKeepAliveClientMixin {
  ArticleBloc articleBloc;
  List<ArticleTypeEntity> types;
  List<ProjectEntity> articleDatas;
  int currentProjectPage;
  int totalProjectPage;
  int selectParentId;
  int selectChildId;
  ScrollController collaspTypeScrollController;
  bool parentTypeIsExpanded;
  bool childTypeIsExpanded;

  ///不能直接使用[ArticleLoading]作为是否在加载的依据
  bool isLoading = false;

  GlobalKey rootKey;
  GlobalKey parentTypeKey;
  GlobalKey childTypeKey;

  @override
  void initState() {
    super.initState();
    articleBloc = ArticleBloc(BlocProvider.of<HomeBloc>(context));
    types ??= [];
    articleDatas ??= [];
    currentProjectPage ??= 1;
    totalProjectPage ??= 1;
    selectParentId = -1;
    selectChildId = -1;
    parentTypeIsExpanded = false;
    childTypeIsExpanded = false;
    rootKey = GlobalKey();
    parentTypeKey = GlobalKey();
    childTypeKey = GlobalKey();
    collaspTypeScrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProviderTree(
      key: rootKey,
      blocProviders: [
        BlocProvider<ArticleBloc>(builder: (context) => articleBloc),
      ],
      child: BlocListenerTree(
        blocListeners: [
          BlocListener<ArticleEvent, ArticleState>(
            bloc: articleBloc,
            listener: (context, state) {
              if (state is ArticleLoading) {
                isLoading = true;
              } else if (state is ArticleLoaded || state is ArticleLoadError) {
                isLoading = false;
              }

              if (state is ArticleTypesloaded) {
                types = state.articleTypes;
                //插入'最新博文'类别
                types.insert(
                  0,
                  ArticleTypeEntity.simple(
                    res.newestArticle,
                    -1,
                    <ArticleTypeEntity>[
                      ArticleTypeEntity.simple(
                        res.newestArticle,
                        -1,
                        [],
                      ),
                    ],
                  ),
                );
              } else if (state is ArticleDatasLoaded) {
                articleDatas = state.datas;
                currentProjectPage = state.curretnPage;
                totalProjectPage = state.totalPage;
              } else if (state is ArticleCollectChanged) {
                articleDatas
                    .where((e) => e.id == state.id)
                    .map((e) => e.collect = state.collect)
                    .toList();
              } else if (state is ArticleLoadError) {
                DisplayUtil.showMsg(context, exception: state.exception);
              }
            },
          )
        ],
        child: BlocBuilder<ArticleEvent, ArticleState>(
          bloc: articleBloc,
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
                        //确定是博文列表发出来的滚动，而不是博文分类栏发出来的滚动
                        if (notification.metrics.axis == Axis.vertical) {
                          //确定是否到达了底部
                          if (notification.metrics.pixels >=
                              notification.metrics.maxScrollExtent) {
                            //确定当前允许加载更多
                            if (state is ArticleLoaded &&
                                currentProjectPage < totalProjectPage) {
                              articleBloc.dispatch(
                                LoadMoreArticleDatas(
                                  originDatas: articleDatas,
                                  page: currentProjectPage + 1,
                                  id: selectChildId,
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
                          articleBloc.dispatch(LoadArticle(selectChildId));
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
                                  //一级分类
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: pt(16), top: pt(16)),
                                    child: Text(
                                      res.typeLevel1,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  ArticleTypeView.collaspTypesView(
                                    collaspTypeScrollController:
                                        collaspTypeScrollController,
                                    key: parentTypeKey,
                                    types: types,
                                    selectId: selectParentId,
                                    onExpanded: () {
                                      setState(() {
                                        parentTypeIsExpanded = true;
                                        childTypeIsExpanded = false;
                                      });
                                    },
                                    onSelected: (selectId) {
                                      if (!isLoading) {
                                        setState(() {
                                          selectParentId = selectId;
                                          selectChildId =
                                              _getChildTypes()[0].id;
                                          articleBloc.dispatch(
                                            LoadMoreArticleDatas(
                                              originDatas: [],
                                              page: 1,
                                              id: selectChildId,
                                            ),
                                          );
                                        });
                                      }
                                    },
                                  ),
                                  //二级分类
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: pt(16),
                                    ),
                                    child: Text(
                                      res.typeLevel2,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  ArticleTypeView.collaspTypesView(
                                    collaspTypeScrollController:
                                        collaspTypeScrollController,
                                    key: childTypeKey,
                                    types: _getChildTypes(),
                                    selectId: selectChildId,
                                    onExpanded: () {
                                      setState(() {
                                        parentTypeIsExpanded = false;
                                        childTypeIsExpanded = true;
                                      });
                                    },
                                    onSelected: (selectId) {
                                      if (!isLoading) {
                                        setState(() {
                                          selectChildId = selectId;
                                          articleBloc.dispatch(
                                            LoadMoreArticleDatas(
                                              originDatas: [],
                                              page: 1,
                                              id: selectChildId,
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
                              sliver: articleList(datas: articleDatas)),
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
                  //展开的一级分类
                  Positioned(
                    top: _getExpandedViewMarginTop(parentTypeKey),
                    left: 0,
                    right: 0,
                    child: Offstage(
                      offstage: !parentTypeIsExpanded,
                      child: AnimatedOpacity(
                        opacity: parentTypeIsExpanded ? 1 : 0,
                        duration: Duration(milliseconds: 400),
                        child: ArticleTypeView.expandedTypesView(
                          types: types,
                          selectId: selectParentId,
                          onExpanded: () {
                            setState(() {
                              parentTypeIsExpanded = false;
                            });
                          },
                          onSelected: (selectId) {
                            if (!isLoading) {
                              ///todo 这里可以利用collaspTypeScrollController将折叠分类列表滚动到当前已选中的item位置，但是麻烦，flutter没有类似scrollTo(position)这种方法。(待实现）
                              setState(() {
                                parentTypeIsExpanded = false;
                                selectParentId = selectId;
                                selectChildId = _getChildTypes()[0].id;
                                articleBloc.dispatch(
                                  LoadMoreArticleDatas(
                                    originDatas: [],
                                    page: 1,
                                    id: selectChildId,
                                  ),
                                );
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  //展开的二级分类
                  Positioned(
                    top: _getExpandedViewMarginTop(childTypeKey),
                    left: 0,
                    right: 0,
                    child: Offstage(
                      offstage: !childTypeIsExpanded,
                      child: AnimatedOpacity(
                        opacity: childTypeIsExpanded ? 1 : 0,
                        duration: Duration(milliseconds: 400),
                        child: ArticleTypeView.expandedTypesView(
                          types: _getChildTypes(),
                          selectId: selectChildId,
                          onExpanded: () {
                            setState(() {
                              childTypeIsExpanded = false;
                            });
                          },
                          onSelected: (selectId) {
                            if (!isLoading) {
                              setState(() {
                                childTypeIsExpanded = false;
                                selectChildId = selectId;
                                articleBloc.dispatch(
                                  LoadMoreArticleDatas(
                                    originDatas: [],
                                    page: 1,
                                    id: selectChildId,
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

  List<ArticleTypeEntity> _getChildTypes() {
    List<ArticleTypeEntity> list =
        types.where((e) => e.id == selectParentId).toList();
    if (list.length >= 1) {
      return list[0].children;
    } else {
      return <ArticleTypeEntity>[
        ArticleTypeEntity.simple(
          res.newestArticle,
          -1,
          [],
        ),
      ];
    }
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

  ///博文列表
  Widget articleList({List<ProjectEntity> datas = const []}) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        ProjectEntity data = datas[index];
        return ArticleItem(data, isLoading);
      }, childCount: datas.length),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ArticleItem extends StatefulWidget {
  ProjectEntity data;
  bool isLoading;

  ArticleItem(
    this.data,
    this.isLoading,
  );

  @override
  _ArticleItemState createState() => _ArticleItemState();
}

class _ArticleItemState extends State<ArticleItem>
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
                  BlocProvider.of<ArticleBloc>(context).dispatch(
                    CollectArticle(widget.data.id, !widget.data.collect),
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
              widget.data.superChapterId == 408 //公众号
                  ? Container(
                decoration: BoxDecoration(
                    border: Border.all(color: WColors.theme_color_light)),
                margin: EdgeInsets.only(right: pt(6)),
                padding: EdgeInsets.symmetric(horizontal: pt(4)),
                child: Text(
                  res.vxArticle,
                  style: TextStyle(
                      color: WColors.theme_color_light,
                      fontWeight: FontWeight.w600,
                      fontSize: 10),
                ),
              )
                  : Container(),
              Expanded(
                child: Text(
                    '${res.author}：${widget.data.author}  ${res.time}：${widget.data.niceDate}',),
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
