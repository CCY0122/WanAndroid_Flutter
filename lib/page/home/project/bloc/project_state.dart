import 'package:equatable/equatable.dart';
import 'package:wanandroid_flutter/entity/banner_entity.dart';
import 'package:wanandroid_flutter/entity/project_entity.dart';
import 'package:wanandroid_flutter/entity/project_type_entity.dart';
import 'package:wanandroid_flutter/entity/todo_entity.dart';

abstract class ProjectState extends Equatable {
  ProjectState([List props = const []]) : super(props);
}

class ProjectUnready extends ProjectState {
  @override
  String toString() {
    return 'ProjectUnready{}';
  }
}

class ProjectLoading extends ProjectState {
  @override
  String toString() {
    return 'ProjectLoading{}';
  }
}

///banner数据加载完成
class ProjectBannerLoaded extends ProjectState {
  List<BannerEntity> banners;

  ProjectBannerLoaded(this.banners) : super([banners]);

  @override
  String toString() {
    return 'ProjectBannerLoaded{banners: ${banners?.length}}';
  }
}

///项目分类加载完成
class ProjectTypesLoaded extends ProjectState {
  List<ProjectTypeEntity> types;

  ProjectTypesLoaded(this.types) : super([types]);

  @override
  String toString() {
    return 'ProjectTypesLoaded{types: ${types?.length}}';
  }
}

///to-do数据加载完成
class ProjectTodoLoaded extends ProjectState {
  List<TodoEntity> todos;

  ProjectTodoLoaded(this.todos) : super([todos]);

  @override
  String toString() {
    return 'ProjectTodoLoaded{todos: ${todos?.length}';
  }
}

///最新项目加载完成
class ProjectDatasLoaded extends ProjectState {
  List<ProjectEntity> datas;
  int curretnPage;
  int totalPage;

  ProjectDatasLoaded(this.datas, this.curretnPage, this.totalPage)
      : super([datas, curretnPage, totalPage]);

  @override
  String toString() {
    return 'ProjectDatasLoaded{datas: ${datas?.length}, curretnPage: $curretnPage, totalPage: $totalPage}';
  }
}

///收藏状态变化
class ProjectCollectChanged extends ProjectState {
  int id;
  bool collect;

  ProjectCollectChanged(this.id, this.collect);

  @override
  String toString() {
    return 'ProjectCollectChanged{id: $id, collect: $collect}';
  }

}

///页面加载完成
class ProjectLoaded extends ProjectState {
  @override
  String toString() {
    return 'ProjectLoaded{}';
  }
}

class ProjectLoadError extends ProjectState {
  Exception exception;

  ProjectLoadError(this.exception) : super([exception]);
}
