import 'package:flutter/material.dart';
import 'package:wanandroid_flutter/entity/base_entity.dart';
import 'package:wanandroid_flutter/entity/base_list_entity.dart';
import 'package:wanandroid_flutter/entity/project_entity.dart';
import 'package:wanandroid_flutter/http/index.dart';

///搜索结果提供者
class SearchResultsModel with ChangeNotifier {
  bool isLoading = false;
  int currentPage = 1;
  int totalPage = 1;
  String searchKey;
  List<ProjectEntity> _datas = [];
  Function(Exception e) onError;

  List<ProjectEntity> get datas => _datas;

  SearchResultsModel(this.searchKey, this.onError);

  ///获取搜索结果
  getResults(String searchKey, {int page = 1}) async {
    if (searchKey == null || searchKey.length == 0) {
      return;
    }
    try {
      isLoading = true;
      if (this.searchKey != searchKey) {
        this.searchKey = searchKey;
        _datas = [];
      }
      notifyListeners();

      Response response =
          await CommonApi.searchArticles(page, searchKey);
      BaseEntity<Map<String, dynamic>> baseEntity =
          BaseEntity.fromJson(response.data);
      BaseListEntity<List> baseListEntity =
          BaseListEntity.fromJson(baseEntity.data);
      currentPage = baseListEntity.curPage;
      totalPage = baseListEntity.pageCount;
      if (_datas == null || _datas.length == 0) {
        _datas =
            baseListEntity.datas.map((e) => ProjectEntity.fromJson(e)).toList();
      } else {
        _datas.addAll(baseListEntity.datas
            .map((e) => ProjectEntity.fromJson(e))
            .toList());
      }
    } catch (e) {
      print(e);
      onError(e);
      _datas = [];
    }

    isLoading = false;
    notifyListeners();
  }

  ///收藏、取消收藏
  collect(int id, bool collect) async {
    try {
      isLoading = true;
      notifyListeners();
      if (collect) {
        await CollectApi.collect(id);
      } else {
        await CollectApi.unCollect(id);
      }
      datas.where((e) => e.id == id).map((e) => e.collect = collect).toList();
    } catch (e) {
      print(e);
      onError(e);
    }

    isLoading = false;
    notifyListeners();
  }

  bool hasMore() {
    return currentPage < totalPage;
  }
}
