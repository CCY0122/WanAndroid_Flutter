import 'package:equatable/equatable.dart';
import 'package:wanandroid_flutter/entity/project_entity.dart';

abstract class ProjectEvent extends Equatable {
  ProjectEvent([List props = const []]) : super(props);
}

class LoadProject extends ProjectEvent {
  @override
  String toString() {
    return 'LoadProject{}';
  }
}

class LoadMoreProjectDatas extends ProjectEvent {
  List<ProjectEntity> originDatas;
  int page;

  LoadMoreProjectDatas(this.originDatas, this.page) :super([originDatas, page]);

  @override
  String toString() {
    return 'LoadMoreProjectDatas{originDatas: $originDatas, page: $page}';
  }
}
