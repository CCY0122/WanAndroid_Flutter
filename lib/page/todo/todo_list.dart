import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanandroid_flutter/entity/base_entity.dart';
import 'package:wanandroid_flutter/entity/base_list_entity.dart';
import 'package:wanandroid_flutter/entity/todo_entity.dart';
import 'package:wanandroid_flutter/http/index.dart';
import 'package:wanandroid_flutter/page/notifications.dart';
import 'package:wanandroid_flutter/page/todo/todo_create.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/utils/index.dart';

class DataChangeNotification extends Notification {
  TodoEntity data;
  bool removed;

  DataChangeNotification(this.data, {this.removed = false});
}

///to-do 列表页
class TodoListPage extends StatefulWidget {
  int type;
  int priority;
  int order;
  bool forceUpdate;

  TodoListPage(
    this.type,
    this.priority,
    this.order, {
    this.forceUpdate = false,
  }) {
    if (type == 0) {
      type = null;
    }
    if (priority == 0) {
      priority = null;
    }
    if (order == 0) {
      order = null;
    }
  }

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<TodoEntity> datas;
  int currentPage;
  int totalPage;
  ScrollController _scrollController;
  bool isLoading;
  bool isFirst = true;
  bool _isGetTodoListError = false;

  @override
  void initState() {
    super.initState();
    isLoading = false;
    currentPage ??= 1;
    totalPage ??= 1;
    _getTodoList(currentPage);
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      // 如果下拉的当前位置到scroll的最下面
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (currentPage < totalPage && !isLoading) {
          _getTodoList(currentPage + 1);
        }
      }
    });
  }

  @override
  void didUpdateWidget(TodoListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.priority != widget.priority ||
        oldWidget.type != widget.type ||
        oldWidget.order != widget.order ||
        widget.forceUpdate) {
      _refreshAuto();
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      onNotification: (Notification notification) {
        switch (notification.runtimeType) {
          case UpdateNotification:
            if ((notification as UpdateNotification).update) {
              _refreshAuto();
            }
            return true; //没必要继续冒泡到todo_main
          case DataChangeNotification:
            if ((notification as DataChangeNotification).removed) {
              _deleteTodo((notification as DataChangeNotification).data);
            }
            return true;
        }
        return false;
      },
      child: RefreshIndicator(
          color: WColors.theme_color,
          child: ListView.builder(
            controller: _scrollController,
            physics:
                AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            shrinkWrap: false,
            itemBuilder: (BuildContext context, int index) {
              if (datas == null || datas.length == 0 || _isGetTodoListError) {
                return Container(
                  height: pt(400),
                  alignment: Alignment.center,
                  child: _isGetTodoListError
                      ? Text(
                          res.pullToRetry,
                          style: TextStyle(fontSize: 18),
                        )
                      : datas == null
                          ? CupertinoActivityIndicator()
                          : Text(
                              res.allEmpty,
                              style: TextStyle(fontSize: 18),
                            ),
                );
              } else {
                if (index != datas.length) {
                  return TodoItem(
                    index,
                    datas[index],
                  );
                } else {
                  return Container(
                    width: double.infinity,
                    height: pt(45),
                    alignment: Alignment.center,
                    child: (currentPage < totalPage)
                        ? CupertinoActivityIndicator()
                        : Text(
                            res.isBottomst,
                            style: TextStyle(color: WColors.hint_color),
                          ),
                  );
                }
              }
            },
            itemCount:
                (datas == null || datas.length == 0 || _isGetTodoListError)
                    ? 1
                    : datas.length + 1,
          ),
          onRefresh: _refreshAuto),
    );
  }

  Future<void> _refreshAuto() async {
    datas = null;
    currentPage = 1;
    totalPage = 1;
    await _getTodoList(currentPage);
  }

  ///获取todo列表
  Future _getTodoList(int page) async {
    isLoading = true;
    try {
      Response response = await TodoApi.getTodoList(
        page,
        type: widget.type,
        priority: widget.priority,
        orderby: widget.order,
      );
      BaseEntity<Map<String, dynamic>> baseEntity = BaseEntity.fromJson(response.data);
      BaseListEntity<List> baseListEntity = BaseListEntity.fromJson(baseEntity.data);
      List<TodoEntity> newDatas = baseListEntity.datas.map((json){
        return TodoEntity.fromJson(json);
      }).toList();
      if (datas == null) {
        datas = newDatas;
      } else {
        datas.addAll(newDatas);
      }
      currentPage = baseListEntity.curPage;
      totalPage = baseListEntity.pageCount;
      print('_TodoListPageState : 获取todo列表成功');
      if (isFirst) {
        isFirst = false;
        DisplayUtil.showMsg(context,
            text: res.todoTips, duration: Duration(seconds: 4));
      }
      _isGetTodoListError = false;
    } catch (e) {
      _isGetTodoListError = true;
      DisplayUtil.showMsg(context, exception: e);
    }
    if (mounted) {
      setState(() {});
    }
    isLoading = false;
  }

  Future _deleteTodo(TodoEntity data) async {
    isLoading = true;
    try {
      await TodoApi.deleteTodo(data.id);
      datas.remove(data);
      print('_TodoListPageState : 删除todo成功');
    } catch (e) {
      DisplayUtil.showMsg(context, exception: e);
    }
    if (mounted) {
      setState(() {});
    }
    isLoading = false;
  }
}

class TodoItem extends StatefulWidget {
  int index;
  TodoEntity data;

  TodoItem(this.index, this.data);

  @override
  _TodoItemState createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> with TickerProviderStateMixin {
  ItemDragData _dragData;
  AnimationController _finishDragController;
  BuildContext contentContext;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _dragData = ItemDragData();
    _dragData.initPosition = -pt(45 / 2.0 + 70); //一个圆角半径+日期widget所占长度
    _dragData.totalDragLength = pt(375); //屏幕宽
    _dragData.alreadyDragLength = 0;
  }

  @override
  void dispose() {
    _finishDragController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, TodoCreatePage.ROUTER_NAME,
                arguments: widget.data)
            .then((needUpdate) {
          if (needUpdate ?? false) {
            //告诉_TodoListPageState要刷新列表
            UpdateNotification(true).dispatch(context);
          }
        });
      },
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(res.ensureDelete),
              actions: <Widget>[
                FlatButton(
                  child: Text(res.cancel),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                FlatButton(
                  child: Text(res.confirm),
                  onPressed: () {
                    DataChangeNotification(widget.data, removed: true)
                        .dispatch(this.context);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (isLoading) {
          return;
        }
        setState(() {
          _dragData.alreadyDragLength += details.primaryDelta;
        });
      },
      onHorizontalDragCancel: () {
        if (isLoading) {
          return;
        }
        onFinishDrag();
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (isLoading) {
          return;
        }
        onFinishDrag(velocity: details.primaryVelocity);
      },
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: pt(65),
        margin: EdgeInsets.only(top: widget.index == 0 ? pt(30) : 0),
        child: Stack(
          overflow: Overflow.visible,
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              left: widget.data.status == 1
                  ? null
                  : _dragData.initPosition + _dragData.alreadyDragLength,
//              一个圆角半径+日期widget所占长度
              right: widget.data.status == 1
                  ? _dragData.initPosition - _dragData.alreadyDragLength
                  : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: pt(60),
                    alignment: Alignment.centerRight,
                    margin: EdgeInsets.only(right: pt(10)),
                    child: Text(
                      widget.data.completeDateStr,
                      maxLines: 1,
                      style: TextStyle(fontSize: 10, color: WColors.hint_color),
                    ),
                  ),
                  Builder(builder: (context) {
                    contentContext = context;
                    return Container(
                      //一个疑问：一旦给contatiner加上alignment后，它的宽就固定为maxWidth了，这不是我想要的，所以目前只好给他的child再套上一个stack来实现内容垂直居中
                      constraints: BoxConstraints(
                        maxWidth: pt(375 - 70.0), //屏幕宽 - 日期widget长度
                        minWidth: pt(375 / 2.0 + 45 / 2.0), //一半屏幕宽 + 一个圆角半径
                        maxHeight: pt(45),
                        minHeight: pt(45),
                      ),
                      decoration: ShapeDecoration(
                        color: widget.data.status == 1
                            ? WColors.theme_color_light
                            : WColors.theme_color_dark,
                        shadows: <BoxShadow>[
                          DisplayUtil.supreLightElevation(
                            baseColor: widget.data.status == 1
                                ? WColors.theme_color_light.withAlpha(0xaa)
                                : WColors.theme_color_dark.withAlpha(0xaa),
                          ),
                        ],
                        shape: StadiumBorder(),
                      ),
                      child: Stack(
                        alignment: widget.data.status == 1
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: pt(45 / 2.0 + 5),
                            ),
                            child: Text(
                              widget.data.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            child: isLoading
                                ? CupertinoActivityIndicator()
                                : RotatedBox(
                                    child: Image.asset(
                                      'images/pull.png',
                                      width: pt(20),
                                      height: pt(20),
                                      color: Colors.white30,
                                    ),
                                    quarterTurns: 3,
                                  ),
                          ),
                          Positioned(
                            left: 0,
                            child: isLoading
                                ? CupertinoActivityIndicator()
                                : RotatedBox(
                                    child: Image.asset(
                                      'images/pull.png',
                                      width: pt(20),
                                      height: pt(20),
                                      color: Colors.white30,
                                    ),
                                    quarterTurns: 1,
                                  ),
                          ),
                        ],
                      ),
                    );
                  }),
                  Container(
                    width: pt(60),
                    margin: EdgeInsets.only(left: pt(10)),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.data.completeDateStr,
                      maxLines: 1,
                      style: TextStyle(fontSize: 10, color: WColors.hint_color),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///拖动结束，触发位置互换或恢复位置动画
  void onFinishDrag({double velocity = 0}) {
    if (_finishDragController != null && _finishDragController.isAnimating) {
      return;
    }
    if (contentContext == null ||
        contentContext.findRenderObject() is! RenderBox) {
      return;
    }
    //内容item宽度
    double itemWidth =
        (contentContext.findRenderObject() as RenderBox).size.width;
    //是否是初始位置在右侧的item（即已完成的todo）
    bool isRightItem = (widget.data.status == 1);
    //是否最终拖动方向是向右
    bool isDragToRight = _dragData.alreadyDragLength > 0;
    //是否达到了互换左右侧item的阈值(拖动超过一半item距离或者滑动速度够大）
    bool isReachedThreshold =
        (_dragData.alreadyDragLength.abs() >= itemWidth / 2.0) ||
            velocity.abs() > 60;
    _finishDragController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));

    Animation animation;

    bool leftChangeToRight =
        !isRightItem && isDragToRight && isReachedThreshold;
    bool rightChangeToLeft =
        isRightItem && !isDragToRight && isReachedThreshold;
    if (leftChangeToRight || rightChangeToLeft) {
      //交换位置
      animation = Tween<double>(
        begin: _dragData.alreadyDragLength,
        end: (leftChangeToRight ? 1 : -1) *
            (pt(375) - itemWidth + pt(70 - 45 / 2.0)), //画图计算出来的
      ).animate(CurvedAnimation(
          parent: _finishDragController, curve: Curves.easeOutBack));
      animation.addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          changeTodoStatus(widget.data);
        }
      });
      animation.addListener(() {
        setState(() {
          _dragData.alreadyDragLength = animation.value;
        });
      });

      _finishDragController.forward();
    } else {
      //恢复原始位置
      animation = Tween<double>(
        begin: _dragData.alreadyDragLength,
        end: 0,
      ).animate(CurvedAnimation(
          parent: _finishDragController, curve: Curves.easeOutBack));
      animation.addListener(() {
        setState(() {
          _dragData.alreadyDragLength = animation.value;
        });
      });
      _finishDragController.forward();
    }
  }

  Future changeTodoStatus(TodoEntity data, {int status}) async {
    setState(() {
      isLoading = true;
    });
    try {
      await TodoApi.updateTodoStatus(
          data.id, status ?? (data.status == 1 ? 0 : 1));
      data.status = status ?? (data.status == 1 ? 0 : 1);
    } catch (e) {
      DisplayUtil.showMsg(context, exception: e);
    }

    if (mounted) {
      setState(() {});
      _dragData.alreadyDragLength = 0;
      isLoading = false;
    }
  }
}

class ItemDragData {
  ///item初始位置
  double initPosition;

  ///总可拖动长度
  double totalDragLength;

  ///item当前已拖动长度
  double alreadyDragLength;
}
