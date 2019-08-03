import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:wanandroid_flutter/entity/project_entity.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/utils/index.dart';
import 'package:wanandroid_flutter/utils/string_decode.dart';
import 'package:wanandroid_flutter/views/load_more_footer.dart';
import 'package:wanandroid_flutter/views/loading_view.dart';

import '../web_view.dart';
import 'collect_list_model.dart';

typedef OnCollect = void Function(String title, String author, String link);

///收藏列表
///Provider模式
///为了List增减有动画，使用了AnimatedList，注意写法区别
class CollectListView extends StatefulWidget {
  @override
  _CollectListViewState createState() => _CollectListViewState();
}

class _CollectListViewState extends State<CollectListView> {
  GlobalKey<AnimatedListState> animListKey;

  @override
  Widget build(BuildContext context) {
    animListKey = GlobalKey();
    return ChangeNotifierProvider(
      builder: (_) => CollectListModel((Exception e) {
        DisplayUtil.showMsg(context, exception: e);
      })
        ..getDatas(1),
      child: Consumer<CollectListModel>(
        builder: (context, value, _) {
          if (value.isFirst && value.datas.length == 0) {
            //加这段代码是因为列表使用的是AnimatedList，如果当datas为空时就构建它，那么后面datas获取后就得一个一个的调用animListKey.currentState.insertItem来添加
            return getLoadingParent(
              child: Container(),
              isLoading: value.isLoading,
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              value.getDatas(1, clearData: true, onSuccess: () {
                //AnimatedList根普通listview不一样，它的item需要自己手动insert进去，但是对于刷新来说是全部item都变了，所以直接重建根布局
                setState(() {});
              });
              return;
            },
            child: getLoadingParent(
                child: NotificationListener(
                  onNotification: (notification) {
                    if (notification is ScrollUpdateNotification) {
                      if (notification.metrics.axis == Axis.vertical) {
                        //确定是否到达了底部
                        if (notification.metrics.pixels >=
                            notification.metrics.maxScrollExtent) {
                          //确定当前允许加载更多
                          if (!value.isLoading && value.hasMore()) {
                            value.getDatas(value.currentPage + 1,
                                onSuccess: () {
                              setState(() {});
                            });
                          }
                          return false;
                        }
                      }
                    }
                    return false;
                  },
                  child: AnimatedList(
                    key: animListKey,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index, animation) {
                      if (index == 0) {
                        return Padding(
                          padding:
                              EdgeInsets.fromLTRB(pt(16), pt(8), pt(16), pt(8)),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  res.collectArticle,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  FlatButton(
                                    padding: EdgeInsets.all(0),
                                    onPressed: () {
                                      if (value.isLoading) {
                                        return;
                                      }
                                      showAddCollectDialog(context,
                                          onCollect: (title, author, link) {
                                        value.addCollect(
                                            title: title,
                                            author: author,
                                            link: link,
                                            onAddSuccess: () {
                                              //构建list添加动画
                                              animListKey.currentState
                                                  .insertItem(1);
                                            });
                                      });
                                    },
                                    child: Text(
                                      res.add,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  FlatButton(
                                    padding: EdgeInsets.all(0),
                                    onPressed: () {
                                      value.toggleEdit();
                                    },
                                    child: Text(
                                      value.isEditMode
                                          ? res.finish
                                          : res.editor,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      } else if (index == value.datas.length + 1) {
                        return getLoadMoreFooter(value.hasMore(),
                            color: Colors.white);
                      } else {
                        if (value.datas.length == 0) {
                          return null;
                        }
                        ProjectEntity entity = value.datas[index - 1];
                        return item(
                            animation: animation,
                            data: entity,
                            isEditMode: value.isEditMode,
                            onTap: () {
                              Navigator.pushNamed(
                                  context, WebViewPage.ROUTER_NAME,
                                  arguments: {
                                    'title': entity.title,
                                    'url': entity.link,
                                  });
                            },
                            onDelete: () {
                              if (value.isLoading) {
                                return;
                              }
                              value.unCollect(
                                entity.id,
                                onUncollectSuccess: () {
                                  //构建list的删除动画
                                  animListKey.currentState.removeItem(
                                    index,
                                    (context, animation) {
                                      return item(
                                        animation: animation,
                                        data: entity,
                                        isEditMode: true,
                                      );
                                    },
                                  );
                                },
                              );
                            });
                      }
                    },
                    initialItemCount: value.datas.length + 2,
                  ),
                ),
                isLoading: value.isLoading),
          );
        },
      ),
    );
  }

  Widget item({
    Key key,
    @required Animation<double> animation,
    VoidCallback onTap,
    bool isEditMode = false,
    VoidCallback onDelete,
    @required ProjectEntity data,
  }) {
    return SizeTransition(
      sizeFactor: animation,
      child: Column(
        children: <Widget>[
          ListTile(
            onTap: isEditMode ? null : onTap,
            dense: true,
            contentPadding: EdgeInsets.only(right: pt(16), left: pt(16)),
            title: Text(
              decodeString(data.title),
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            subtitle: Row(
              children: [
                Expanded(
                  child: Text(
                      '${res.author}：${data.author ?? '-'}  ${res.type}：${data.chapterName ?? '-'}  ${res.time}:${data.niceDate ?? '-'}'),
                ),
              ],
            ),
            trailing: isEditMode
                ? GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onDelete,
                    child: Icon(
                      Icons.cancel,
                      color: WColors.warning_red,
                    ),
                  )
                : null,
          ),
          Divider(
            height: 10,
          ),
        ],
      ),
    );
  }

  void showAddCollectDialog(BuildContext context, {OnCollect onCollect}) {
    TextEditingController nameC = TextEditingController();
    TextEditingController authorC = TextEditingController();
    TextEditingController linkC = TextEditingController();
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            elevation: 1,
            content: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        size: 20,
                      ),
                    ),
                  ),
                  TextField(
                    controller: nameC,
                    decoration: InputDecoration(hintText: res.enterTitle),
                    autofocus: true,
                  ),
                  SizedBox(
                    height: pt(20),
                  ),
                  TextField(
                    controller: authorC,
                    decoration: InputDecoration(hintText: res.enterAuthor),
                    autofocus: true,
                  ),
                  SizedBox(
                    height: pt(20),
                  ),
                  TextField(
                    controller: linkC,
                    decoration: InputDecoration(hintText: res.enterLink),
                  ),
                ],
              ),
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    onCollect?.call(
                        nameC.text.isEmpty ? 'ccy is best!' : nameC.text,
                        authorC.text.isEmpty ? 'ccy' : authorC.text,
                        linkC.text.isEmpty
                            ? 'https://github.com/CCY0122/WanAndroid_Flutter'
                            : linkC.text);
                    Navigator.pop(context);
                  },
                  child: Text(res.add))
            ],
          );
        });
  }
}
