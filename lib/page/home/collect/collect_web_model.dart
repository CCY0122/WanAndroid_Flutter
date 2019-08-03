import 'package:flutter/foundation.dart';
import 'package:wanandroid_flutter/entity/base_entity.dart';
import 'package:wanandroid_flutter/entity/collect_web_entity.dart';
import 'package:wanandroid_flutter/http/index.dart';

///收藏网址提供者
class CollectWebModel extends ChangeNotifier {
  bool isFirst;
  bool isEditMode;
  bool isLoading;
  Function(Exception e) onError;
  List<CollectWebEntity> _datas;

  List<CollectWebEntity> get datas => _datas;

  CollectWebModel(this.onError) {
    isFirst = true;
    isEditMode = false;
    isLoading = false;
    _datas = [];
  }

  //收藏网址的增删改查方法：

  getDatas() async {
    isLoading = true;
    notifyListeners();

    try {
      Response response = await CollectWebApi.getCollectWebList();
      BaseEntity<List> baseEntity = BaseEntity.fromJson(response.data);
      _datas =
          baseEntity.data.map((e) => CollectWebEntity.fromJson(e)).toList();
    } catch (e) {
      print(e);
      onError(e);
    }

    isFirst = false;
    isLoading = false;
    notifyListeners();
  }

  addWeb(
      {String name,
      String link,
      VoidCallback onAddSuccess}) async {
    isLoading = true;
    notifyListeners();

    try {
      Response response =
          await CollectWebApi.collectWeb(name: name, link: link);
      CollectWebEntity entity =
          CollectWebEntity.fromJson(response.data['data']);
      _datas.add(entity);
      onAddSuccess?.call();
    } catch (e) {
      print(e);
      onError(e);
    }

    isLoading = false;
    notifyListeners();
  }

  deleteWeb(int id, {VoidCallback onDeleteSuccess}) async {
    isLoading = true;
    notifyListeners();

    try {
      await CollectWebApi.deleteWeb(id);
      datas.removeWhere((e) => e.id == id);
      onDeleteSuccess?.call();
    } catch (e) {
      print(e);
      onError(e);
    }

    isLoading = false;
    notifyListeners();
  }

  toggleEdit() {
    isEditMode = !isEditMode;
    notifyListeners();
  }
}
