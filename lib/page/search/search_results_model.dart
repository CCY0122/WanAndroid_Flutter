

import 'package:flutter/material.dart';
import 'package:wanandroid_flutter/entity/base_entity.dart';
import 'package:wanandroid_flutter/entity/base_list_entity.dart';
import 'package:wanandroid_flutter/entity/project_entity.dart';
import 'package:wanandroid_flutter/http/index.dart';

///搜索结果提供者
class SearchResultsModel with ChangeNotifier{
  bool isLoading = false;
  int currentPage = 1;
  int totalPage = 1;
  String searchKey;
  List<ProjectEntity> _datas = [];
  List<ProjectEntity> get datas => _datas;


  getResults(String searchKey)async{
    if(searchKey == null || searchKey.length == 0){
      return;
    }

    try {
      isLoading = true;
      notifyListeners();

      this.searchKey = searchKey;
      Response response = await CommonApi.searchArticles(currentPage, searchKey);
      BaseEntity<Map<String, dynamic>> baseEntity = BaseEntity.fromJson(response.data);
      BaseListEntity<List> baseListEntity = BaseListEntity.fromJson(baseEntity.data);
      currentPage = baseListEntity.curPage;
      totalPage = baseListEntity.pageCount;

      if (_datas == null || _datas.length == 0) {
        _datas =
            baseListEntity.datas.map((e) => ProjectEntity.fromJson(e)).toList();
      } else {
        _datas.addAll(
            baseListEntity.datas.map((e) => ProjectEntity.fromJson(e)).toList());
      }
    } catch (e) {
      print(e);
      _datas = [];
    }

    isLoading = false;
    notifyListeners();
  }


  bool hasMore(){
    return currentPage < totalPage;
  }
}