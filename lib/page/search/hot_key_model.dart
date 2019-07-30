import 'package:flutter/material.dart';
import 'package:wanandroid_flutter/entity/base_entity.dart';
import 'package:wanandroid_flutter/entity/hot_key_entity.dart';
import 'package:wanandroid_flutter/http/index.dart';

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

    } catch (e) {
      print(e);
      _datas = [];
    }

    isLoading = false;
    notifyListeners();
  }
}
