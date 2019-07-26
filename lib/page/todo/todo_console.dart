import 'package:flutter/material.dart';
import 'package:wanandroid_flutter/page/notifications.dart';
import 'package:wanandroid_flutter/page/todo/todo_create.dart';
import 'package:wanandroid_flutter/page/todo/todo_main.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/utils/index.dart';

typedef OnSelect<T> = void Function(T item);

///to-do控制台
class TodoConsole extends StatefulWidget {
  @override
  _TodoConsoleState createState() => _TodoConsoleState();
}

class _TodoConsoleState extends State<TodoConsole> {
  List<FilterEntry> types = [
    FilterEntry(0, res.all),
    FilterEntry(1, res.work),
    FilterEntry(2, res.life),
    FilterEntry(3, res.play),
  ];
  FilterEntry currentType;

  List<FilterEntry> prioritys = [
    FilterEntry(0, res.all),
    FilterEntry(1, res.important),
    FilterEntry(2, res.normal),
    FilterEntry(3, res.relaxed),
  ];
  FilterEntry currentPriority;

  //排序接口有bug，没有正常排序：https://github.com/hongyangAndroid/wanandroid/issues/138
  List<FilterEntry> orders = [
    FilterEntry(4, res.orderByCreateTime),
    FilterEntry(2, res.orderByFinishTime),
  ];
  FilterEntry currentOrder;

  @override
  void initState() {
    super.initState();
    currentType = types[0];
    currentPriority = prioritys[0];
    currentOrder = orders[0];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: pt(150),
        margin: EdgeInsets.symmetric(horizontal: pt(16)),
        padding: EdgeInsets.only(left: pt(8)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            DisplayUtil.supreLightElevation(),
          ],
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  filterTypesWidget(),
                  filterPriorityWidget(),
                  filterOrderWidget(),
                ],
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.pushNamed(context, TodoCreatePage.ROUTER_NAME).then(
                  (needUpdate) {
                    if (needUpdate ?? false) {
                      //告诉_TodoPageState要让_TodoListPageState重新获取列表
                      UpdateNotification(true).dispatch(context);
                    }
                  },
                );
//              Navigator.push(context, PopupRoute())
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: pt(8)),
                child: Center(
                  child: Container(
                      decoration: BoxDecoration(border: Border()),
                      child: Image.asset(
                        'images/add.png',
                        color: Colors.grey[350],
                        width: pt(55),
                        height: pt(55),
                      )),
                ),
              ),
            ),
          ],
        ));
  }

  Widget filterTypesWidget() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
      child: Row(
        children: types.map((entry) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: pt(3)),
            child: myFilterChip(
                entry,
                currentType == null
                    ? types.indexOf(entry) == 0
                    : currentType == entry, (f) {
              setState(() {
                currentType = f;
                TodoFilterNotification(
                  currentType?.value,
                  currentPriority?.value,
                  currentOrder?.value,
                ).dispatch(context);
              });
            }),
          );
        }).toList(),
      ),
    );
  }

  Widget filterPriorityWidget() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
      child: Row(
        children: prioritys.map((entry) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: pt(3)),
            child: myFilterChip(
                entry,
                currentPriority == null
                    ? prioritys.indexOf(entry) == 0
                    : currentPriority == entry, (f) {
              setState(() {
                currentPriority = f;
                TodoFilterNotification(
                  currentType?.value,
                  currentPriority?.value,
                  currentOrder?.value,
                ).dispatch(context);
              });
            }),
          );
        }).toList(),
      ),
    );
  }

  Widget filterOrderWidget() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
      child: Row(
        children: orders.map((entry) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: pt(3)),
            child: myFilterChip(
                entry,
                currentOrder == null
                    ? orders.indexOf(entry) == 0
                    : currentOrder == entry, (f) {
              setState(() {
                currentOrder = f;
                TodoFilterNotification(
                  currentType?.value,
                  currentPriority?.value,
                  currentOrder?.value,
                ).dispatch(context);
              });
            }),
          );
        }).toList(),
      ),
    );
  }

  Widget myFilterChip(
      FilterEntry data, bool isSelect, OnSelect<FilterEntry> onSelect) {
    return Container(
      child: FilterChip(
//        backgroundColor: Colors.white,
        selectedColor: WColors.theme_color,
        shape: isSelect
            ? null
            : StadiumBorder(side: BorderSide(color: WColors.hint_color)),
        label: Text(
          data.text,
          style: TextStyle(fontSize: 12),
        ),
        selected: isSelect,
        onSelected: (bool value) {
          if (value) {
            onSelect(data);
          } else {
            onSelect(null);
          }
        },
      ),
    );
  }
}

class FilterEntry {
  int value;
  String text;

  FilterEntry(this.value, this.text);

  @override
  bool operator ==(other) {
    if (other is! FilterEntry) {
      return false;
    }
    return this.value == (other as FilterEntry).value;
  }
}
