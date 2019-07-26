import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:wanandroid_flutter/entity/article_type_entity.dart';
import 'package:wanandroid_flutter/entity/base_entity.dart';
import 'package:wanandroid_flutter/entity/base_list_entity.dart';
import 'package:wanandroid_flutter/entity/project_entity.dart';
import 'package:wanandroid_flutter/http/index.dart';
import 'package:wanandroid_flutter/page/home/home/bloc/home_index.dart';

import 'WXArticle_index.dart';

class WXArticleBloc extends Bloc<WXArticleEvent, WXArticleState> {
  HomeBloc homeBloc;
  StreamSubscription subscription;

  WXArticleBloc(this.homeBloc) {
    print('WXArticle bloc constra');

    ///等主页的基础数据加载完了后，子页再开始加载数据
    subscription = homeBloc.state.listen((state) {
      if (state is HomeLoaded) {
        print('微信公众号子页：主页加载完成，开始加载子页');
        dispatch(LoadWXArticle(408)); //408是'鸿洋'公众号分类id
      }
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  WXArticleState get initialState => WXArticleUnready();

  @override
  Stream<WXArticleState> mapEventToState(WXArticleEvent event) async* {
    if (event is LoadWXArticle) {
      yield* _mapLoadWXArticleToState(event.id, event.searchKey);
    } else if (event is LoadMoreWXArticleDatas) {
      yield* _mapLoadMoreWXArticleDatasToState(
          datas: event.originDatas,
          id: event.id,
          page: event.page,
          searchKey: event.searchKey);
    } else if (event is CollectWXArticle) {
      yield* _mapCollectWXArticleToState(event.id, event.collect);
    }
  }

  Stream<WXArticleState> _mapLoadWXArticleToState(
      int id, String searchKey) async* {
    try {
      yield WXArticleLoading();
      List<ArticleTypeEntity> types = await _getTypes();
      yield WXArticleTypesloaded(types);
      WXArticleDatasLoaded datasState = await _getWXArticleDatasState(
        datas: [],
        id: id,
        page: 1,
        searchKey: searchKey,
      );
      yield datasState;
      yield WXArticleLoaded();
    } catch (e) {
      yield WXArticleLoadError(e);
    }
  }

  Stream<WXArticleState> _mapLoadMoreWXArticleDatasToState(
      {List<ProjectEntity> datas, int id, int page, String searchKey}) async* {
    try {
      yield WXArticleLoading();
      WXArticleDatasLoaded datasState = await _getWXArticleDatasState(
        datas: datas,
        id: id,
        page: page,
        searchKey: searchKey,
      );
      yield datasState;
      yield WXArticleLoaded();
    } catch (e) {
      print(e);
      yield WXArticleLoadError(e);
    }
  }

  Stream<WXArticleState> _mapCollectWXArticleToState(
      int id, bool collect) async* {
    try {
      yield WXArticleLoading();
      if (collect) {
        await CollectApi.collect(id);
      } else {
        await CollectApi.unCollect(id);
      }
      yield WXArticleCollectChanged(id, collect);
      yield WXArticleLoaded();
    } catch (e) {
      yield WXArticleLoadError(e);
    }
  }

  Future<List<ArticleTypeEntity>> _getTypes() async {
    Response response = await WXArticleApi.getWXArticleTypes();
    BaseEntity<List> baseEntity = BaseEntity.fromJson(response.data);
    List<ArticleTypeEntity> parentTypes =
        baseEntity.data.map((e) => ArticleTypeEntity.fromJson(e)).toList();
//    parentTypes.map((parent) {
//      parent.children =
//          parent.children.map((e) => ArticleTypeEntity.fromJson(e)).toList();
//    }).toList();
    return parentTypes;
  }

  //页码从1开始
  Future<WXArticleDatasLoaded> _getWXArticleDatasState({
    List<ProjectEntity> datas,
    int id,
    int page,
    String searchKey,
  }) async {
    Response response;
    response = await WXArticleApi.getWXArticleList(
      page,
      id,
      searchKey: searchKey,
    );

    BaseEntity<Map<String, dynamic>> baseEntity =
        BaseEntity.fromJson(response.data);
    BaseListEntity<List> baseListEntity =
        BaseListEntity.fromJson(baseEntity.data);
    if (datas == null || datas.length == 0) {
      datas =
          baseListEntity.datas.map((e) => ProjectEntity.fromJson(e)).toList();
    } else {
      datas.addAll(
          baseListEntity.datas.map((e) => ProjectEntity.fromJson(e)).toList());
    }
    return WXArticleDatasLoaded(
        datas, baseListEntity.curPage, baseListEntity.pageCount);
  }
}
