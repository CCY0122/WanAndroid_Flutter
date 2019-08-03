import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:wanandroid_flutter/entity/collect_web_entity.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/utils/index.dart';
import 'package:wanandroid_flutter/views/badge_view.dart';

import '../web_view.dart';
import 'collect_web_model.dart';

typedef OnAddWeb = void Function(String name, String link);

///网址收藏栏
///Provider模式
///为了List增减有动画，使用了AnimatedList，注意写法区别
class CollectWebView extends StatelessWidget {
  GlobalKey<AnimatedListState> animListKey;

  @override
  Widget build(BuildContext context) {
    animListKey = GlobalKey();
    return ChangeNotifierProvider(
      builder: (_) => CollectWebModel((Exception e) {
        DisplayUtil.showMsg(context, exception: e);
      })
        ..getDatas(),
      child: Consumer<CollectWebModel>(
        builder: (context, value, _) {
          if (value.isFirst && value.datas.length == 0) {
            //加这段代码是因为列表使用的是AnimatedList，如果当datas为空时就构建它，那么后面datas获取后就得一个一个的调用animListKey.currentState.insertItem来添加
            return CupertinoActivityIndicator();
          }
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  WColors.theme_color,
                  WColors.theme_color_light,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            height: pt(100),
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding:
                          EdgeInsets.fromLTRB(pt(16), pt(16), pt(16), pt(0)),
                      child: Row(
                        children: [
                          Text(
                            res.collectWeb,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  value.toggleEdit();
                                },
                                child: Text(
                                  value.isEditMode ? res.confirm : res.editor,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: AnimatedList(
                        key: animListKey,
                        itemBuilder: (context, index, animation) {
                          if (index < value.datas.length) {
                            //网址收藏item
                            CollectWebEntity entity = value.datas[index];
                            return Container(
                              child: item(
                                animation: animation,
                                isEditMode: value.isEditMode,
                                title: entity.name,
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, WebViewPage.ROUTER_NAME,
                                      arguments: {
                                        'title': entity.name,
                                        'url': entity.link,
                                      });
                                },
                                onDelete: () {
                                  if (value.isLoading) {
                                    return;
                                  }
                                  value.deleteWeb(
                                    entity.id,
                                    onDeleteSuccess: () {
                                      //构建list的删除动画
                                      animListKey.currentState.removeItem(
                                        index,
                                        (context, animation) {
                                          return item(
                                              animation: animation,
                                              title: entity.name,
                                              isEditMode: true);
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            );
                          } else {
                            //添加网址收藏按钮
                            return item(
                                animation: animation,
                                title: '+',
                                isEditMode: false,
                                onTap: () {
                                  if (value.isLoading) {
                                    return;
                                  }
                                  showAddWebDialog(context,
                                      onAddWeb: (name, link) {
                                    value.addWeb(
                                        name: name,
                                        link: link,
                                        onAddSuccess: (entity) {
                                          //构建list添加动画
                                          animListKey.currentState.insertItem(
                                            value.datas.length - 1,
                                          );
                                        });
                                  });
                                });
                          }
                        },
                        initialItemCount: value.datas.length + 1,
                        scrollDirection: Axis.horizontal,
                      ),
                    ),
                  ],
                ),
                Offstage(
                  offstage: !value.isLoading,
                  child: CupertinoActivityIndicator(),
                ),
              ],
            ),
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
    @required String title,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isEditMode ? null : onTap, //编辑模式下暂屏蔽点击
      child: ScaleTransition(
        scale: animation,
        child: Padding(
          padding: EdgeInsets.only(top: pt(10)),
          child: Badge(
            visible: isEditMode,
            badge: GestureDetector(
              onTap: onDelete,
              child: Icon(
                Icons.cancel,
                color: WColors.warning_red,
                size: 20,
              ),
            ),
            offsetX: 6,
            offsetY: 6,
            color: Colors.transparent,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: pt(8), vertical: pt(8)),
              padding:
                  EdgeInsets.symmetric(horizontal: pt(12), vertical: pt(6)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.white),
              ),
              child: Text(
                title,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showAddWebDialog(BuildContext context, {OnAddWeb onAddWeb}) {
    TextEditingController nameC = TextEditingController();
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
                    decoration: InputDecoration(hintText: res.enterWebName),
                    autofocus: true,
                  ),
                  SizedBox(
                    height: pt(20),
                  ),
                  TextField(
                    controller: linkC,
                    decoration: InputDecoration(hintText: res.enterWebLink),
                  ),
                ],
              ),
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    onAddWeb?.call(
                        nameC.text.isEmpty ? 'ccy' : nameC.text,
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
