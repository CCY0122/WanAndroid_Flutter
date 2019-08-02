import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:wanandroid_flutter/entity/banner_entity.dart';
import 'package:wanandroid_flutter/entity/project_entity.dart';
import 'package:wanandroid_flutter/entity/project_type_entity.dart';
import 'package:wanandroid_flutter/entity/todo_entity.dart';
import 'package:wanandroid_flutter/page/account/login_wanandroid_page.dart';
import 'package:wanandroid_flutter/page/home/home/bloc/home_index.dart';
import 'package:wanandroid_flutter/page/home/project/bloc/project_index.dart';
import 'package:wanandroid_flutter/page/home/project/project_detail_page.dart';
import 'package:wanandroid_flutter/page/home/web_view.dart';
import 'package:wanandroid_flutter/page/todo/todo_main.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/utils/index.dart';
import 'package:wanandroid_flutter/utils/string_decode.dart';
import 'package:wanandroid_flutter/views/flat_pagination.dart';
import 'package:wanandroid_flutter/views/load_more_footer.dart';
import 'package:wanandroid_flutter/views/loading_view.dart';

///项目页
///BloC模式
class ProjectSubPage extends StatefulWidget {
  PageStorageKey pageStorageKey;

  ProjectSubPage(this.pageStorageKey);

  @override
  _ProjectSubPageState createState() => _ProjectSubPageState();
}

class _ProjectSubPageState extends State<ProjectSubPage>
    with AutomaticKeepAliveClientMixin {
  ProjectBloc projectBloc;
  List<BannerEntity> banners;
  List<ProjectTypeEntity> projectTypes;
  List<ProjectEntity> projectDatas;
  List<TodoEntity> todoDatas;
  int currentProjectPage;
  int totalProjectPage;

  ///不能直接使用[ProjectLoading]作为是否在加载的依据，原因见[ProjectBloc]
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    projectBloc = ProjectBloc(BlocProvider.of<HomeBloc>(context));
    banners ??= [];
    projectTypes ??= [];
    todoDatas ??= [];
    projectDatas ??= [];
    currentProjectPage ??= 1;
    totalProjectPage ??= 1;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProviderTree(
      blocProviders: [
        BlocProvider<ProjectBloc>(
          builder: (context) => projectBloc,
        ),
      ],
      child: BlocListenerTree(
        blocListeners: [
          BlocListener<ProjectEvent, ProjectState>(
            bloc: projectBloc,
            listener: (context, state) {
              if (state is ProjectLoading) {
                isLoading = true;
              } else if (state is ProjectLoaded || state is ProjectLoadError) {
                isLoading = false;
              }

              if (state is ProjectBannerLoaded) {
                banners = state.banners;
              } else if (state is ProjectTypesLoaded) {
                projectTypes = state.types;
              } else if (state is ProjectTodoLoaded) {
                todoDatas = state.todos;
              } else if (state is ProjectDatasLoaded) {
                currentProjectPage = state.curretnPage;
                totalProjectPage = state.totalPage;
                projectDatas = state.datas;
              } else if (state is ProjectCollectChanged) {
                projectDatas
                    .where((e) => e.id == state.id)
                    .map((e) => e.collect = state.collect)
                    .toList();
              } else if (state is ProjectLoadError) {
                DisplayUtil.showMsg(context, exception: state.exception);
              }
            },
          ),
        ],
        child: BlocBuilder<ProjectEvent, ProjectState>(
          bloc: projectBloc,
          builder: (context, state) {
            return NotificationListener(
              onNotification: (notification) {
                if (notification is ScrollUpdateNotification) {
//                  print('scroll key = ${widget.pageStorageKey}');
                  //确定是项目列表发出来的滚动，而不是项目分类栏发出来的滚动
                  if (notification.metrics.axis == Axis.vertical) {
                    //确定是否到达了底部
                    if (notification.metrics.pixels >=
                        notification.metrics.maxScrollExtent) {
                      //确定当前允许加载更多
                      if (state is ProjectLoaded &&
                          currentProjectPage < totalProjectPage) {
                        projectBloc.dispatch(LoadMoreProjectDatas(
                            projectDatas, currentProjectPage + 1));
                      }
                      return false;
                    }
                  }
                }
                return false;
              },
              child: Stack(
                children: <Widget>[
                  RefreshIndicator(
                    color: WColors.theme_color,
                    onRefresh: () async {
                      ///鉴于flutter关于NestedScrollView的这个bug：https://github.com/flutter/flutter/issues/36419。
                      ///所以当本页的下拉被拉出来时，实际上其他页（如articlePage）的下拉也被拉出来了。导致其他页也会触发刷新。
                      if (!isLoading) {
                        projectBloc.dispatch(LoadProject());
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
                        //banner
                        SliverToBoxAdapter(
                          child: bannerView(
                              datas: banners.map((entity) {
                            return BannerModel(
                              entity.title ?? '',
                              entity.imagePath ?? '',
                              entity.url ?? '',
                            );
                          }).toList()),
                        ),
                        //分类
                        SliverToBoxAdapter(
                          child: typesGridView(
                            datas: projectTypes
                                .asMap()
                                .map<int, ProjectTypesModel>((index, entity) {
                                  return MapEntry(
                                    index,
                                    ProjectTypesModel(
                                      entity.id,
                                      entity.name,
                                      Image.asset(
                                        MyImage.animals[
                                            index % MyImage.animals.length],
                                        width: pt(40),
                                        height: pt(40),
                                      ),
                                    ),
                                  );
                                })
                                .values
                                .toList(),
                          ),
                        ),
                        //to-do轮播栏
                        SliverToBoxAdapter(
                          child: todoViewFlipper(datas: todoDatas),
                        ),
                        //最新项目标题
                        SliverToBoxAdapter(
                          child: Container(
                            color: WColors.gray_background,
                            padding: EdgeInsets.only(left: pt(16), top: pt(8)),
                            child: Row(
                              children: <Widget>[
                                Image.asset(
                                  'images/new.png',
                                  width: pt(30),
                                  height: pt(30),
                                ),
                                SizedBox(
                                  width: pt(10),
                                ),
                                Text(
                                  res.newestProject,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                        ),
                        //项目列表
                        projectGrid(datas: projectDatas),
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

  ///banner
  Widget bannerView({List<BannerModel> datas = const []}) {
    return Container(
      height: pt(140 + 16 * 2.0),
      padding: EdgeInsets.all(pt(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(pt(6)),
        child: (datas == null || datas.length == 0)
            ? Container(
                color: Colors.grey[300],
              )
            : Swiper(
                itemCount: datas.length,
                itemBuilder: (context, index) {
                  BannerModel data = datas[index];
                  return CachedNetworkImage(
                    imageUrl: data.imagePath,
                    fit: BoxFit.cover,
                    placeholder: (context, url) {
                      return DecoratedBox(
                        decoration: BoxDecoration(color: Colors.grey[300]),
                      );
                    },
                  );
                },
                autoplay: datas.length > 1,
                pagination: SwiperPagination(
                  builder: FlatDotSwiperPaginationBuilder(
                    color: Colors.white,
                    activeColor: WColors.theme_color_light,
                    size: 5,
                    activeSize: 5,
                    space: 2.5,
                  ),
                  alignment: Alignment.bottomRight,
                ),
                onTap: (index) {
                  Navigator.pushNamed(
                    context,
                    WebViewPage.ROUTER_NAME,
                    arguments: {
                      'title': datas[index].title,
                      'url': datas[index].url,
                    },
                  );
                },
              ),
      ),
    );
  }

  ///项目分类网格布局，固定两行
  Widget typesGridView({List<ProjectTypesModel> datas = const []}) {
    if (datas == null || datas.length == 0) {
      //占位view
      return GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Container(
            color: Colors.grey[300],
            margin:
                EdgeInsets.symmetric(horizontal: pt(9.375), vertical: pt(6)),
          );
        },
        itemCount: 8,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, childAspectRatio: 1.25),
      );
    }

    //这里无法用table实现。
    //一行最多item
    int maxOneRowCount = (datas.length / 2).ceil();
    if (datas.length == 1) {
      maxOneRowCount = 1;
    }
    //一行的一屏内最多可显示item
    int maxOnScreenCount = 5;
    double itemWidth;
    if (maxOneRowCount <= maxOnScreenCount) {
      //一屏放得下，均分屏幕宽
      itemWidth = pt(375) / maxOneRowCount;
    } else {
      //一屏放不下，可横向滚动，末尾露出一半item让用户好发现这是可以横向滚动的
      itemWidth = pt(375) / (maxOnScreenCount + 0.5);
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: Iterable.generate(maxOneRowCount, (index) {
              ProjectTypesModel data = datas[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                      context, ProjectDetailPage.ROUTER_NAME, arguments: {
                    'id': data.id,
                    'name': decodeString(data.title)
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  width: itemWidth,
                  height: pt(75),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      data.icon,
                      Text(
                        decodeString(data.title),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: WColors.hint_color_dark, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          datas.length == 1
              ? Container()
              : Row(
                  children:
                      Iterable.generate(datas.length - maxOneRowCount, (index) {
                    ProjectTypesModel data = datas[index + maxOneRowCount];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                            context, ProjectDetailPage.ROUTER_NAME, arguments: {
                          'id': data.id,
                          'name': decodeString(data.title)
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: itemWidth,
                        height: pt(75),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            data.icon,
                            Text(
                              decodeString(data.title),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: WColors.hint_color_dark,
                                  fontSize: 11.5),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  ///to-do轮播栏
  Widget todoViewFlipper({List<TodoEntity> datas = const []}) {
    if (datas == null || datas.length == 0) {
      return Container();
    }
    return Column(
      children: <Widget>[
        Divider(
          height: 1,
        ),
        Container(
          height: pt(35),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: pt(16)),
          //目前Swiper不能禁止掉手势滑动，实际这里禁用掉用户体验会更好。
          child: Swiper(
            onTap: (index) {
              Navigator.pushNamed(context, TodoPage.ROUTER_NAME);
            },
            autoplayDelay: 5000,
            duration: 1000,
            scrollDirection: Axis.vertical,
            itemCount: datas.length,
            autoplay: datas.length > 1,
            itemBuilder: (context, index) {
              TodoEntity data = datas[index];
              return Row(
                children: <Widget>[
                  Icon(
                    Icons.alarm,
                    size: 20,
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: pt(5)),
                      child: Text(
                        data.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: pt(5)),
                    child: Text(
                      data.completeDateStr,
                      style: TextStyle(
                        fontSize: 12,
                        color: WColors.hint_color_dark,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: data.status == 1
                                ? WColors.theme_color
                                : WColors.warning_red),
                        borderRadius: BorderRadius.circular(4)),
                    padding: EdgeInsets.symmetric(
                        horizontal: pt(4), vertical: pt(1)),
                    child: Text(
                      data.status == 1 ? res.done : res.undone,
                      style: TextStyle(
                          fontSize: 12,
                          color: data.status == 1
                              ? WColors.theme_color
                              : WColors.warning_red),
                    ),
                  ),
                ],
              );
            },
          ),
        )
      ],
    );
  }

  ///项目列表
  Widget projectGrid({List<ProjectEntity> datas = const []}) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          //问题：没有类似SliverDecoration这种控件，那么怎么独立设置sliver的背景颜色呢？暂时通过改变每个item的颜色来实现吧
          return Container(
            color: WColors.gray_background,
            padding: index % 2 == 0
                ? EdgeInsets.only(
                    left: pt(12), right: pt(6), top: pt(6), bottom: pt(6))
                : EdgeInsets.only(
                    left: pt(6), right: pt(12), top: pt(6), bottom: pt(6)),
            child: projectItem(datas[index]),
          );
        },
        childCount: datas.length,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9,
      ),
    );
  }

  ///项目item
  Widget projectItem(ProjectEntity data) {
    return ProjectItem(data, isLoading);
  }

  @override
  bool get wantKeepAlive => true;
}

class ProjectItem extends StatefulWidget {
  ProjectEntity data;
  bool isLoading;

  ProjectItem(this.data, this.isLoading);

  @override
  _ProjectItemState createState() => _ProjectItemState();
}

class _ProjectItemState extends State<ProjectItem>
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
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(pt(6))),
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Stack(
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl: widget.data.envelopePic,
                    width: double.infinity,
                    alignment: Alignment(0.0, -0.95),
                    fit: BoxFit.cover,
                    placeholder: (BuildContext context, String url) {
                      return Container(
                        color: Colors.grey[300],
                      );
                    },
                    errorWidget:
                        (BuildContext context, String url, Object error) {
                      return Container(
                        color: Colors.grey[300],
                      );
                    },
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black26,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )),
                      padding: EdgeInsets.only(
                        left: pt(4),
                        bottom: pt(2),
                        top: pt(10),
                      ),
                      child: Text(
                        widget.data.author,
                        style: TextStyle(color: Colors.white, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: pt(4), horizontal: pt(4)),
              child: Text(
                widget.data.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            GestureDetector(
//              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.pushNamed(context, ProjectDetailPage.ROUTER_NAME,
                    arguments: {
                      'id': widget.data.chapterId,
                      'name': decodeString(widget.data.chapterName)
                    });
              },
              child: Padding(
                padding:
                    EdgeInsets.only(bottom: pt(6), left: pt(4), right: pt(4)),
                child: Row(
                  children: <Widget>[
                    Text(
                      widget.data.chapterName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: WColors.hint_color_dark,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: WColors.hint_color_dark,
                      size: pt(12),
                    ),
                    Expanded(
                        child: Align(
                      alignment: Alignment(0.9, 0),
                      child: GestureDetector(
                        child: ScaleTransition(
                          scale: _collectAnim,
                          child: Icon(
                            widget.data.collect
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: widget.data.collect
                                ? WColors.warning_red
                                : Colors.grey,
                            size: 18,
                          ),
                        ),
                        onTap: () {
                          if (!widget.isLoading) {
                            if (BlocProvider.of<HomeBloc>(context).isLogin) {
                              BlocProvider.of<ProjectBloc>(context).dispatch(
                                CollectProject(
                                    widget.data.id, !widget.data.collect),
                              );
                            } else {
                              Navigator.pushNamed(
                                      context, LoginWanandroidPage.ROUTER_NAME)
                                  .then((_) {
                                BlocProvider.of<HomeBloc>(context)
                                    .dispatch(LoadHome());
                              });
                            }
                          }
                        },
                      ),
                    ))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BannerModel {
  BannerModel(
    this.title,
    this.imagePath,
    this.url,
  );

  String title;
  String imagePath;
  String url;
}

class ProjectTypesModel {
  int id;
  String title;
  Widget icon;

  ProjectTypesModel(this.id, this.title, this.icon);
}
