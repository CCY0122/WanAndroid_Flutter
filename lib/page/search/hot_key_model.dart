import 'package:flutter/material.dart';
import 'package:wanandroid_flutter/entity/base_entity.dart';
import 'package:wanandroid_flutter/entity/hot_key_entity.dart';
import 'package:wanandroid_flutter/http/index.dart';
import 'dart:math' as math;

///热搜词提供者
class HotKeyModel with ChangeNotifier {
  bool isLoading = false;
  List<HotKeyEntity> _datas = [];

  List<HotKeyEntity> get datas => _datas;

  ///更新
  updateHotkeys() async {
    try {
      isLoading = true;
      notifyListeners();

      Response response = await CommonApi.getHotKey();
      BaseEntity<List> baseEntity = BaseEntity.fromJson(response.data);
      _datas = baseEntity.data.map((e) => HotKeyEntity.fromJson(e)).toList();

      //随机排序一下，以此证明刷新成功
      _datas.sort((a,b){
        return  - 1 + math.Random().nextInt(3); //返回随机的-1、0、1值随机排序。
      },);
    } catch (e) {
      print(e);
      _datas = [];
    }

    isLoading = false;
    notifyListeners();
  }
}
