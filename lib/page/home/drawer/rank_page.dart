import 'package:data_plugin/bmob/bmob_query.dart';
import 'package:flutter/material.dart';
import 'package:wanandroid_flutter/entity/bmob_user_entity.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/utils/index.dart';
import 'package:wanandroid_flutter/views/level_view.dart';

class RankPage extends StatefulWidget {
  static const ROUTER_NAME = '/RankPage';

  @override
  _RankPageState createState() => _RankPageState();
}

class _RankPageState extends State<RankPage> {
  List<BmobUserEntity> datas;

  @override
  void initState() {
    super.initState();
    _getDatas();
  }

  @override
  Widget build(BuildContext context) {
    if (datas == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(res.levelRank),
        ),
        body: Center(
          child: Text(res.isLoading),
        ),
      );
    }
    if (datas.length == 0) {
      return Scaffold(
        appBar: AppBar(
          title: Text(res.levelRank),
        ),
        body: Center(
          child: Text(res.allEmpty),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(res.levelRank),
      ),
      body: ListView.builder(
        itemBuilder: (c, i) {
          return _item(datas[i], i);
        },
        itemCount: datas.length,
      ),
    );
  }

  Widget _item(BmobUserEntity entity, int index) {
    Color color;
    Widget rank;
    TextStyle style;
    if (index == 0) {
      color = Colors.red;
      rank = Image.asset(
        'images/no1.png',
        width: pt(22),
        height: pt(22),
        color: color,
      );
      style = TextStyle(fontWeight: FontWeight.w700, color: color);
    } else if (index == 1) {
      color = Colors.orange;
      rank = Image.asset(
        'images/no2.png',
        width: pt(22),
        height: pt(22),
        color: color,
      );
      style = TextStyle(fontWeight: FontWeight.w600, color: color);
    } else if (index == 2) {
      color = Colors.purple;
      rank = Image.asset(
        'images/no3.png',
        width: pt(22),
        height: pt(22),
        color: color,
      );
      style = TextStyle(fontWeight: FontWeight.w500, color: color);
    } else {
      color = Colors.black;
      rank = Container(
        decoration: ShapeDecoration(
            shape: CircleBorder(side: BorderSide(color: Colors.red))),
        padding: EdgeInsets.all(pt(2.5)),
        child: Text(
          '${index + 1}',
          style: TextStyle(color: Colors.red, fontSize: 12),
        ),
      );
      style = TextStyle(fontWeight: FontWeight.normal, color: color);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: pt(16), vertical: pt(10)),
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: pt(8)),
              child: rank,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    entity.userName ?? 'unknow',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: style.fontWeight,
                        color: style.color),
                  ),
                  Text(
                    entity.signature ?? '',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: style.fontWeight,
                        color: style.color),
                  ),
                ],
              ),
            ),
            getLevelWidgets(entity.level),
          ],
        ),
      ),
    );
  }

  Future _getDatas() async {
    try {
      BmobQuery<BmobUserEntity> query = BmobQuery();
      query.setOrder('-level');
      List<dynamic> results = await query.queryObjects();
      datas = results.map((e) => BmobUserEntity.fromJson(e)).toList();

      setState(() {});
    } catch (e) {
      print(e);
    }
  }
}
