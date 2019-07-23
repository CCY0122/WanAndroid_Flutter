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
  int selectId;

  ///不能直接使用[ArticleLoading]作为是否在加载的依据
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    articleBloc = ArticleBloc(BlocProvider.of<HomeBloc>(context));
    types ??= [];
    articleDatas ??= [];
    currentProjectPage ??= 1;
    totalProjectPage ??= 1;
    selectParentId ??= -1;
    selectId ??= -1;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProviderTree(
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
                if (notification is ScrollUpdateNotification) {
                  //确定是博文列表发出来的滚动，而不是博文分类栏发出来的滚动
                  if (notification.metrics.axis == Axis.vertical) {
                    //确定是否到达了底部
                    if (notification.metrics.pixels >=
                        notification.metrics.maxScrollExtent) {
                      //确定当前允许加载更多
                      if (state is ArticleLoaded &&
                          currentProjectPage < totalProjectPage) {
                        articleBloc.dispatch(LoadMoreArticleDatas(
                          originDatas: articleDatas,
                          page: currentProjectPage + 1,
                          id: selectId,
                        ));
                      }
                      return true;
                    }
                  }
                }
                return true;
              },
              child: Stack(
                children: <Widget>[
                  RefreshIndicator(
                    color: WColors.theme_color,
                    onRefresh: () async {
                      if (state is ArticleLoaded || state is ArticleLoadError) {
                        articleBloc.dispatch(LoadArticle(selectId));
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
                          parent: BouncingScrollPhysics()),
                      slivers: <Widget>[
                        //底部footer
                        SliverToBoxAdapter(
                          child: getLoadMoreFooter(
                              currentProjectPage < totalProjectPage),
                        ),
                      ],
                    ),
                  ),
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

  @override
  bool get wantKeepAlive => true;
}
