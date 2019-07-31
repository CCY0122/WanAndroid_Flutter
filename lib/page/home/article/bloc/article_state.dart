import 'package:equatable/equatable.dart';
import 'package:wanandroid_flutter/entity/article_type_entity.dart';
import 'package:wanandroid_flutter/entity/project_entity.dart';

abstract class ArticleState extends Equatable {
  ArticleState([List props = const []]) : super(props);
}

class ArticleUnready extends ArticleState {
  @override
  String toString() {
    return 'ArticleUnready{}';
  }
}

class ArticleLoading extends ArticleState {
  @override
  String toString() {
    return 'ArticleLoading{}';
  }
}

class ArticleTypesloaded extends ArticleState {
  List<ArticleTypeEntity> articleTypes;

  ArticleTypesloaded(this.articleTypes) : super([articleTypes]);

  @override
  String toString() {
    return 'ArticleTypesloaded{articleTypes: ${articleTypes?.length}';
  }
}

class ArticleDatasLoaded extends ArticleState {
  List<ProjectEntity> datas;
  int curretnPage;
  int totalPage;

  ArticleDatasLoaded(this.datas, this.curretnPage, this.totalPage)
      : super([datas, curretnPage, totalPage]);

  @override
  String toString() {
    return 'ArticleDatasLoaded{datas: ${datas?.length}, curretnPage: $curretnPage, totalPage: $totalPage}';
  }
}

///收藏状态变化
class ArticleCollectChanged extends ArticleState {
  int id;
  bool collect;

  ArticleCollectChanged(this.id, this.collect);

  @override
  String toString() {
    return 'ArticleCollectChanged{id: $id, collect: $collect}';
  }

}

class ArticleLoaded extends ArticleState {
  @override
  String toString() {
    return 'ArticleLoaded{}';
  }
}

class ArticleLoadError extends ArticleState {
  Exception exception;

  ArticleLoadError(this.exception) : super([exception]);

  @override
  String toString() {
    return 'ArticleLoadError{exception: $exception}';
  }
}
