import 'package:flutter/foundation.dart';
import 'package:wanandroid_flutter/entity/base_entity.dart';
import 'package:wanandroid_flutter/entity/base_list_entity.dart';
import 'package:wanandroid_flutter/entity/project_entity.dart';
import 'package:wanandroid_flutter/http/index.dart';

///收藏提供者
class CollectListModel extends ChangeNotifier {
  bool isFirst;
  bool isEditMode;
  bool isLoading;
  Function(Exception e) onError;
  int currentPage;
  int totalPage;
  List<ProjectEntity> _datas;

  List<ProjectEntity> get datas => _datas;

  CollectListModel(this.onError)
      : isFirst = true,
        isEditMode = false,
        isLoading = false,
        currentPage = 1,
        totalPage = 1,
        _datas = [] {}

  //收藏的增删改查方法：

  getDatas(int page, {bool clearData = false, VoidCallback onSuccess}) async {
    isLoading = true;
    notifyListeners();

    try {
      Response response = await CollectApi.getCollectList(page);
      BaseEntity<Map<String, dynamic>> baseEntity =
          BaseEntity.fromJson(response.data);
      BaseListEntity<List> baseListEntity =
          BaseListEntity.fromJson(baseEntity.data);
      currentPage = baseListEntity.curPage;
      totalPage = baseListEntity.pageCount;
      if (clearData) {
        _datas.clear();
      }
      if (_datas == null || _datas.length == 0) {
        _datas =
            baseListEntity.datas.map((e) => ProjectEntity.fromJson(e)).toList();
      } else {
        _datas.addAll(baseListEntity.datas
            .map((e) => ProjectEntity.fromJson(e))
            .toList());
      }
      onSuccess?.call();
    } catch (e) {
      print(e);
      onError(e);
      _datas = [];
    }

    isFirst = false;
    isLoading = false;
    notifyListeners();
  }

  addCollect(
      {String title,
      String author,
      String link,
      VoidCallback onAddSuccess}) async {
    isLoading = true;
    notifyListeners();

    try {
      Response response = await CollectApi.collectOutter(
          title: title, author: author, link: link);
      ProjectEntity entity = ProjectEntity.fromJson(response.data['data']);
      _datas.insert(0, entity);
      onAddSuccess?.call();
    } catch (e) {
      print(e);
      onError(e);
    }

    isLoading = false;
    notifyListeners();
  }

  unCollect(int id, {int originId, VoidCallback onUncollectSuccess}) async {
    isLoading = true;
    notifyListeners();

    try {
      //感觉有bug，明明取消收藏了，在其他地方获取的数据collect仍为true
      await CollectApi.unCollectWithOriginId(id, originId: originId);
      datas.removeWhere((e) => e.id == id);
      onUncollectSuccess?.call();
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

  bool hasMore() {
    return currentPage < totalPage;
  }
}
