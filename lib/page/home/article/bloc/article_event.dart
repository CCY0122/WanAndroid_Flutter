import 'package:equatable/equatable.dart';
import 'package:wanandroid_flutter/entity/project_entity.dart';

abstract class ArticleEvent extends Equatable {
  ArticleEvent([List props = const []]) : super(props);
}

///加载全部
class LoadArticle extends ArticleEvent {
  ///如果为-1，则加载最新博文，否则加载对应id类型的博文
  int id;

  LoadArticle(this.id) : super([id]);

  @override
  String toString() {
    return 'LoadArticle{id: $id}';
  }
}

///加载更多博文
class LoadMoreArticleDatas extends ArticleEvent {
  List<ProjectEntity> originDatas;
  int id;
  int page;

  LoadMoreArticleDatas({this.originDatas, this.id, this.page})
      : super([originDatas, id, page]);

  @override
  String toString() {
    return 'LoadMoreArticleDatas{originDatas: $originDatas, id: $id, page: $page}';
  }
}
