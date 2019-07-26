import 'package:equatable/equatable.dart';
import 'package:wanandroid_flutter/entity/article_type_entity.dart';
import 'package:wanandroid_flutter/entity/project_entity.dart';

abstract class WXArticleState extends Equatable {
  WXArticleState([List props = const []]) : super(props);
}

class WXArticleUnready extends WXArticleState {
  @override
  String toString() {
    return 'WXArticleUnready{}';
  }
}

class WXArticleLoading extends WXArticleState {
  @override
  String toString() {
    return 'WXArticleLoading{}';
  }
}

class WXArticleTypesloaded extends WXArticleState {
  List<ArticleTypeEntity> WXArticleTypes;

  WXArticleTypesloaded(this.WXArticleTypes) : super([WXArticleTypes]);

  @override
  String toString() {
    return 'WXArticleTypesloaded{WXArticleTypes: $WXArticleTypes}';
  }
}

class WXArticleDatasLoaded extends WXArticleState {
  List<ProjectEntity> datas;
  int curretnPage;
  int totalPage;

  WXArticleDatasLoaded(this.datas, this.curretnPage, this.totalPage)
      : super([datas, curretnPage, totalPage]);

  @override
  String toString() {
    return 'WXArticleDatasLoaded{datas: $datas, curretnPage: $curretnPage, totalPage: $totalPage}';
  }
}

///收藏状态变化
class WXArticleCollectChanged extends WXArticleState {
  int id;
  bool collect;

  WXArticleCollectChanged(this.id, this.collect);

  @override
  String toString() {
    return 'WXArticleCollectChanged{id: $id, collect: $collect}';
  }

}

class WXArticleLoaded extends WXArticleState {
  @override
  String toString() {
    return 'WXArticleLoaded{}';
  }
}

class WXArticleLoadError extends WXArticleState {
  Exception exception;

  WXArticleLoadError(this.exception) : super([exception]);

  @override
  String toString() {
    return 'WXArticleLoadError{exception: $exception}';
  }
}
