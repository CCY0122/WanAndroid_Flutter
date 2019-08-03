import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wanandroid_flutter/entity/base_entity.dart';
import 'package:wanandroid_flutter/entity/project_entity.dart';
import 'package:wanandroid_flutter/http/index.dart';
import 'package:wanandroid_flutter/page/home/web_view.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/utils/index.dart';
import 'package:wanandroid_flutter/views/loading_view.dart';

///导航子页。
class NavigationSubPage extends StatefulWidget {
  @override
  _NavigationSubPageState createState() => _NavigationSubPageState();
}

class _NavigationSubPageState extends State<NavigationSubPage>
    with AutomaticKeepAliveClientMixin {
  Map<String, List<ProjectEntity>> datas;
  Map<String, GlobalKey> itemKeys;
  bool isLoading;
  ScrollController typeScrollController;
  ScrollController contentScrollController;
  GlobalKey rootKey;
  int currentTypeIndex;
  bool shouldReloadKeys = true;

  @override
  void initState() {
    super.initState();
    datas = {};
    itemKeys = {};
    currentTypeIndex = 0;
    rootKey = GlobalKey();
    typeScrollController = ScrollController();
    contentScrollController = ScrollController();

    contentScrollController.addListener(() {
      int newTypeIndex = getCurrentTypeIndex();
      if (newTypeIndex != currentTypeIndex) {
        currentTypeIndex = newTypeIndex;
        typeScrollController.animateTo(
            (math.max(0, currentTypeIndex - 3)) * pt(50),
            duration: Duration(milliseconds: 500),
            curve: Curves.decelerate);
        setState(() {});
      }
    });

    getDatas();
  }

  @override
  void dispose() {
    typeScrollController.dispose();
    contentScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (shouldReloadKeys) {
      itemKeys.clear();
    }
    Widget widget = getLoadingParent(
      key: rootKey,
      isLoading: isLoading,
      child: RefreshIndicator(
        onRefresh: () async {
          if (!isLoading) {
            getDatas();
          }
          //app有自己的加载框样式，不使用RefreshIndicator拉出来的圆球作为加载框。所以onRefresh立即返回，让圆球立即消失
          return;
        },

        ///为了实现listView滚动到指定位置，下面两个listView都指定了scrollController,因此与主页面的NestedScrollView的联动关系失效了。
        ///第一个listView因为所有item固定高度为pt(50),所以滚动到指定位置很简单；
        ///第二个listView的item高度不固定，因此要借助globalKey去获取每个item的位置，还是有点点耗性能的。
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Container(
                color: Colors.grey[200],
                child: ListView.builder(
                  physics: ClampingScrollPhysics(),
                  controller: typeScrollController,
                  itemBuilder: (c, i) {
                    String type = datas.keys.elementAt(i);
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (i == currentTypeIndex) {
                          return;
                        }
                        double scrollerOffset = getOffsetForTagetTypeIndex(
                            contentScrollController.offset, i);
                        if (scrollerOffset != 0) {
                          contentScrollController.animateTo(scrollerOffset,
                              duration: Duration(
                                  milliseconds: math.min(
                                      300, 50 * (i - currentTypeIndex).abs())),
                              //离得越远动画时间越久，最久300ms
                              curve: Curves.linear);
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        color: i == currentTypeIndex ? Colors.white : null,
                        padding: EdgeInsets.all(pt(5)),
                        child: Text(
                          type,
                          style: TextStyle(
                              color: i == currentTypeIndex
                                  ? WColors.theme_color_dark
                                  : Colors.black),
                        ),
                      ),
                    );
                  },
                  itemExtent: pt(50),
                  itemCount: datas.length,
                ),
              ),
            ),
            Expanded(
              flex: 10,
              //为了保存globalKey，所有item需一次性加载，这里不使用ListView
              //(实测发现，即使使用的是ListView无参构造，虽然item也是一次性全加载，但屏幕外的item的GlobalKey是获取不到context的
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                controller: contentScrollController,
                child: Column(
                  children: List.generate(datas.length, (i) {
                    if (shouldReloadKeys) {
                      GlobalKey itemKey = GlobalKey();
                      itemKeys[datas.keys.elementAt(i)] = itemKey;
                    }
                    return Padding(
                      key: itemKeys.values.elementAt(i),
                      padding: EdgeInsets.all(pt(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Offstage(
                            offstage: i != 0,
                            child: Text(
                              res.longPressToCopyUrl,
                              style: TextStyle(
                                  color: WColors.hint_color_dark, fontSize: 12),
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(top: pt(10), bottom: pt(5)),
                            child: Align(
                              alignment: Alignment.center,
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Divider(
                                      height: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: pt(10)),
                                    child: Text(
                                      datas.keys.elementAt(i),
                                      style: TextStyle(
                                          color: WColors.hint_color_dark),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Wrap(
                            children: List.generate(
                                datas.values.elementAt(i).length, (innerIndex) {
                              ProjectEntity item =
                                  datas.values.elementAt(i)[innerIndex];
                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, WebViewPage.ROUTER_NAME,
                                      arguments: {
                                        'title': item.title,
                                        'url': item.link
                                      });
                                },
                                onLongPress: () {
                                  Clipboard.setData(
                                    ClipboardData(text: item.link),
                                  );
                                  DisplayUtil.showMsg(context,
                                      text: res.hasCopied);
                                },
                                //可用chip代替
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: pt(5), vertical: pt(5)),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: pt(12), vertical: pt(6)),
                                  decoration: ShapeDecoration(
                                      shape: StadiumBorder(),
                                      color: getColors(innerIndex)),
                                  child: Text(
                                    item.title,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    shouldReloadKeys = false;
    return widget;
  }

  ///获取当前在列表上第一个可见的导航分类序号
  int getCurrentTypeIndex() {
    try {
      if (itemKeys.length != datas.length) {
        return 0;
      }
      RenderBox root = rootKey.currentContext.findRenderObject();
      if (root == null) {
        return 0;
      }
      double rootDy = root.localToGlobal(Offset.zero).dy;
      for (int i = 0; i < itemKeys.length; i++) {
        BuildContext context = itemKeys.values.elementAt(i).currentContext;
        if (context == null) {
          return 0;
        }
        RenderBox renderBox = context.findRenderObject();
        if (renderBox == null) {
          return 0;
        }
        if (i < itemKeys.length - 1) {
          BuildContext contextNext =
              itemKeys.values.elementAt(i + 1).currentContext;
          if (context == null) {
            return 0;
          }
          RenderBox renderBoxNext = contextNext.findRenderObject();
          if (renderBoxNext == null) {
            return 0;
          }
          if ((renderBox.localToGlobal(Offset.zero).dy - rootDy) <= 0 &&
              (renderBoxNext.localToGlobal(Offset.zero).dy - rootDy) > 0) {
            return i;
          }
        } else {
          if ((renderBox.localToGlobal(Offset.zero).dy - rootDy) <= 0) {
            return i;
          }
        }
      }
    } catch (e) {
      print(e);
    }

    return 0;
  }

  ///获取指定导航分类需要滚动到列表最上方所需的偏移量
  double getOffsetForTagetTypeIndex(double currentOffset, int typeIndex) {
    try {
      if (itemKeys.length != datas.length || typeIndex >= itemKeys.length) {
        return 0;
      }
      RenderBox root = rootKey.currentContext.findRenderObject();
      if (root == null) {
        return 0;
      }
      double rootDy = root.localToGlobal(Offset.zero).dy;
      BuildContext context =
          itemKeys.values.elementAt(typeIndex).currentContext;
      if (context == null) {
        return 0;
      }
      RenderBox renderBox = context.findRenderObject();
      if (renderBox == null) {
        return 0;
      }
      double offset = renderBox.localToGlobal(Offset.zero).dy - rootDy;
      return currentOffset + offset + 1;
    } catch (e) {
      print(e);
    }
    return 0;
  }

  Color getColors(int i) {
    List pool = [
      WColors.theme_color_dark,
      WColors.theme_color,
      WColors.theme_color_light,
      WColors.warning_red.withAlpha(0x99)
    ];
    return pool[i % (pool.length)];
  }

  Future getDatas() async {
    isLoading = true;
    setState(() {});

    try {
      Response response = await CommonApi.getNavigations();
      BaseEntity<List> baseEntity = BaseEntity.fromJson(response.data);

      ///data的json 结构为：
      ///     [
      ///        {
      ///            "articles":Array[23],
      ///            "cid":272,
      ///            "name":"常用网站"
      ///        },
      ///        ....
      ///     ]
      ///Array结构为ProjectEntity
      ///
      baseEntity.data.map(
        (e) {
          datas ??= {};
          datas[e['name']] = (e['articles'] as List)
              .map((e) => ProjectEntity.fromJson(e))
              .toList();
        },
      ).toList();
      shouldReloadKeys = true;
    } catch (e) {
      print(e);
      if (mounted) {
        DisplayUtil.showMsg(context, exception: e);
      }
    }

    isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  bool get wantKeepAlive => true;
}
