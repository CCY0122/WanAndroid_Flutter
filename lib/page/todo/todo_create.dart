import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanandroid_flutter/entity/todo_entity.dart';
import 'package:wanandroid_flutter/http/index.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/utils/index.dart';

typedef OnSelect<T> = void Function(T item);

class TodoCreateNotification extends Notification {
  int type;
  int priority;
  int template;

  TodoCreateNotification(this.type, this.priority, this.template);
}

///to-do创建页
class TodoCreatePage extends StatefulWidget {
  static const String ROUTER_NAME = "/TodoCreatePage";

  TodoCreatePage() {}

  @override
  _TodoCreatePageState createState() => _TodoCreatePageState();
}

class _TodoCreatePageState extends State<TodoCreatePage> {
  bool isFirst = true;
  TodoEntity data;
  DateTime planFinishDate;
  int type;
  int priority;
  int template;
  TextEditingController titleController;
  TextEditingController detailController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isFirst) {
      isFirst = false;
      data = ModalRoute.of(context).settings.arguments;
      planFinishDate = data?.completeDate != null
          ? DateTime.fromMillisecondsSinceEpoch(data.completeDate)
          : DateTime.now();
      titleController ??= TextEditingController(text: data?.title);
      detailController ??= TextEditingController(text: data?.content);
      if (data != null) {
        type = data.type;
        priority = data.priority;
      }
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: WColors.theme_color_dark,
        elevation: 0,
        title: Text(
          data == null ? res.create : res.editor,
        ),
        centerTitle: true,
      ),
      //下面接口调用必须使用这个属于Scaffold中的子widget的context，这样才能弹snackbar
      body: Builder(builder: (context) {
        return NotificationListener<TodoCreateNotification>(
          onNotification: (TodoCreateNotification notification) {
            this.type = notification.type;
            this.priority = notification.priority;
            if (this.template != notification.template) {
              this.template = notification.template;
              changeTextByTemplate();
            }
          },
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  WColors.theme_color_dark,
                  WColors.theme_color,
                  WColors.theme_color_light,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(children: <Widget>[
                TodoConsole(
                  callback: () {
                    addOrUpdateTodo(context);
                  },
                  isLoading: isLoading,
                ),
                Container(
                  height: pt(50),
                  width: double.infinity,
                  alignment: Alignment.center,
                  margin:
                      EdgeInsets.only(left: pt(16), right: pt(16), top: pt(16)),
                  padding: EdgeInsets.only(left: pt(8), right: pt(8)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      DisplayUtil.supreLightElevation(),
                    ],
                  ),
                  child: TextField(
                    controller: titleController,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      hintText: res.title,
                      hintStyle: TextStyle(color: WColors.hint_color),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Container(
                  height: pt(250),
                  width: double.infinity,
                  margin: EdgeInsets.only(
                      left: pt(16), right: pt(16), top: pt(16), bottom: pt(16)),
                  padding: EdgeInsets.only(
                      left: pt(8), right: pt(8), top: pt(8), bottom: pt(8)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      DisplayUtil.lightElevation(),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            res.planFinishTime,
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(
                            width: pt(10),
                          ),
                          GestureDetector(
                            child: Text(
                              TodoApi.dateFormat(
                                planFinishDate,
                              ),
                              style: TextStyle(
                                color: WColors.theme_color,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            onTap: () {
                              showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2019),
                                lastDate: DateTime(2035),
                              ).then((DateTime date) {
                                if (date != null && mounted) {
                                  setState(() {
                                    planFinishDate = date;
                                  });
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      Expanded(
                        child: TextField(
                          controller: detailController,
                          maxLines: null,
                          style: TextStyle(fontSize: 18),
                          decoration: InputDecoration(
                            hintText: res.detail,
                            hintStyle: TextStyle(color: WColors.hint_color),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        );
      }),
    );
  }

  void changeTextByTemplate() {
    if (template == null || template == 0) {
      titleController.text = '';
      detailController.text = '';
    } else if (template == 1) {
      titleController.value = detailController.value = TextEditingValue(
        text: res.getExpressDetail,
        selection: TextSelection(baseOffset: 6, extentOffset: 8),
      );
    } else if (template == 2) {
      titleController.value = detailController.value = TextEditingValue(
        text: res.repayDetail,
        selection: TextSelection(baseOffset: 0, extentOffset: 1),
      );
    }
  }

  Future addOrUpdateTodo(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    try {
      if (data == null) {
        await TodoApi.addTodo(
          titleController.text,
          detailController.text,
          completeDate: TodoApi.dateFormat(planFinishDate),
          type: type,
          priority: priority,
        );
        print('_TodoCreatePageState : add todo success');
        Navigator.pop(context, true);
      } else {
        await TodoApi.updateTodo(
          data.id,
          titleController.text,
          detailController.text,
          data.dateStr,
          completeDate: TodoApi.dateFormat(planFinishDate),
          status: data.status,
          type: type,
          priority: priority,
        );
        print('_TodoCreatePageState : update todo success');
        Navigator.pop(context, true);
      }
    } catch (e) {
      DisplayUtil.showMsg(context, exception: e);
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}

///to-do控制台
class TodoConsole extends StatefulWidget {
  Function callback;
  bool isLoading;

  TodoConsole({this.callback, this.isLoading});

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

  List<FilterEntry> templates = [
    FilterEntry(0, res.noTemplate),
    FilterEntry(1, res.getExpress),
    FilterEntry(2, res.repay),
//    FilterEntry(3, res.readbook),
  ];
  FilterEntry currentTemplate;

  @override
  void initState() {
    super.initState();
    currentType ??= types[0];
    currentPriority ??= prioritys[0];
    currentTemplate ??= templates[0];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: pt(150),
        margin: EdgeInsets.only(
          left: pt(16),
          right: pt(16),
          top: pt(8),
        ),
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
                  filterTemplateWidget(),
                ],
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (widget.isLoading) {
                  return;
                }
                widget.callback?.call();
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: pt(8)),
                child: Center(
                  child: Container(
                    alignment: Alignment.center,
                    child: widget.isLoading
                        ? CupertinoActivityIndicator()
                        : Image.asset(
                            'images/finish.png',
                            color: WColors.theme_color,
                            width: pt(55),
                            height: pt(55),
                          ),
                  ),
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
                TodoCreateNotification(
                  currentType?.value,
                  currentPriority?.value,
                  currentTemplate?.value,
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
                TodoCreateNotification(
                  currentType?.value,
                  currentPriority?.value,
                  currentTemplate?.value,
                ).dispatch(context);
              });
            }),
          );
        }).toList(),
      ),
    );
  }

  Widget filterTemplateWidget() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
      child: Row(
        children: templates.map((entry) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: pt(3)),
            child: myFilterChip(
                entry,
                currentTemplate == null
                    ? templates.indexOf(entry) == 0
                    : currentTemplate == entry, (f) {
              setState(() {
                currentTemplate = f;
                TodoCreateNotification(
                  currentType?.value,
                  currentPriority?.value,
                  currentTemplate?.value,
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

  @override
  String toString() {
    return 'value = $value ,text = $text';
  }
}
