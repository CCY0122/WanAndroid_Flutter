import 'package:flutter/material.dart';
import 'package:wanandroid_flutter/entity/project_entity.dart';
import 'package:wanandroid_flutter/entity/project_type_entity.dart';
import 'package:wanandroid_flutter/res/index.dart';

///项目细分页
/// todo 考虑用provide模式
class ProjectDetailPage extends StatefulWidget {
  static const ROUTER_NAME = '/ProjectDetailPage';

  @override
  _ProjectDetailPageState createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  List<ProjectTypeEntity> types;
  List<ProjectEntity> datas;

  @override
  void initState() {
    super.initState();
//    ModalRoute.of(context).settings.arguments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: res.project,
        bottom: TabBar(tabs: null),
      ),
      body: Builder(builder: (context) {

      }),
    );
  }
}
