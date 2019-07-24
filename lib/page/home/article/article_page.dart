import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wanandroid_flutter/entity/article_type_entity.dart';
import 'package:wanandroid_flutter/entity/project_entity.dart';
import 'package:wanandroid_flutter/page/home/article/bloc/article_index.dart';
import 'package:wanandroid_flutter/page/home/bloc/home_index.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/utils/index.dart';
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
    selectParentId ??= -1;
    selectChildId ??= -1;
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
        BlocProvider(builder: (context) => articleBloc),
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
                types.map((e) {}).toList();
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
                //不要在这里检测加载更多，因为其子树有多个垂直滚动widget
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
                            return true;
                          }
                        }
                      }
                      return true;
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
                                  collaspTypesView(
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
                                  collaspTypesView(
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
//                          articleList(),
                          //底部footer
                          SliverToBoxAdapter(
                            child: getLoadMoreFooter(
                                currentProjectPage < totalProjectPage),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //展开的一级分类
                  Offstage(
                    offstage: !parentTypeIsExpanded,
                    child: AnimatedOpacity(
                      opacity: parentTypeIsExpanded ? 1 : 0,
                      duration: Duration(milliseconds: 400),
                      child: expandedTypesView(
                        relativeViewkey: parentTypeKey,
                        types: types,
                        selectId: selectParentId,
                        onExpanded: () {
                          setState(() {
                            parentTypeIsExpanded = false;
                          });
                        },
                        onSelected: (selectId) {
                          if (!isLoading) {
                            ///这里可以利用collaspTypeScrollController将折叠分类列表滚动到当前已选中的item位置，但是实现很麻烦，flutter没有类似scrollTo(position)这种方法
                            setState(() {
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
                  //展开的二级分类
                  Offstage(
                    offstage: !childTypeIsExpanded,
                    child: AnimatedOpacity(
                      opacity: childTypeIsExpanded ? 1 : 0,
                      duration: Duration(milliseconds: 400),
                      child: expandedTypesView(
                        relativeViewkey: childTypeKey,
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
                  //加载框
                  Offstage(
                    offstage: !isLoading,
                    child: getLoading(),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  ///折叠时的type view
  Widget collaspTypesView({
    @required Key key,
    @required List<ArticleTypeEntity> types,
    @required int selectId,
    @required VoidCallback onExpanded,
    @required ValueChanged<int> onSelected,
  }) {
    return Row(
      key: key,
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            controller: collaspTypeScrollController,
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                types.length,
                (index) {
                  return typeItem(
                    id: types[index].id,
                    name: types[index].name,
                    selected: types[index].id == selectId,
                    onSelected: onSelected,
                  );
                },
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            onExpanded();
          },
          child: Container(
            width: pt(30),
            height: pt(30),
            child: Icon(
              Icons.keyboard_arrow_down,
              size: pt(30),
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  ///展开时的type view
  Widget expandedTypesView({
    @required Key relativeViewkey, //展开位置所依赖的view的key
    @required List<ArticleTypeEntity> types,
    @required int selectId,
    @required VoidCallback onExpanded,
    @required ValueChanged<int> onSelected,
  }) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
        colors: [
          WColors.theme_color,
          WColors.theme_color_light,
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      )),
      margin: EdgeInsets.only(top: _getExpandedViewMarginTop(relativeViewkey)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Wrap(
              children: List.generate(
                types.length,
                (index) {
                  return typeItem(
                    id: types[index].id,
                    name: types[index].name,
                    selected: types[index].id == selectId,
                    onSelected: onSelected,
                  );
                },
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              onExpanded();
            },
            child: Container(
              width: pt(30),
              height: pt(30),
              child: Icon(
                Icons.keyboard_arrow_up,
                size: pt(30),
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///type 单元
  Widget typeItem({
    @required int id,
    @required String name,
    @required bool selected,
    @required ValueChanged<int> onSelected,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: pt(8), horizontal: pt(2)),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          //只可选中，不可取消
          if (!selected) {
            onSelected(id);
          }
        },
        child: Container(
          height: pt(28),
          padding: EdgeInsets.symmetric(horizontal: pt(4)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: selected ? Border.all(color: Colors.white) : null,
          ),
          // 这里为什么用stack呢？因为我想让child居中。
          // 那居中为什么不直接给父container设置alignment呢？因为这会使Container约束变尽可能大，
          // 导致width占满剩余空间（height已经固定给了pt(28)，而width我不希望给固定值，它应当根据文字长度自动调整），
          // 最终导致expandedTypesView中的wrap是一行一个typeItem。所以换用stack来实现文字居中。
          // 如果你还不理解，去掉stack，给Container加上Alignment.center，运行看效果。
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                name,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
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

  Widget articleList() {
    return SliverToBoxAdapter(
      child: Container(),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
