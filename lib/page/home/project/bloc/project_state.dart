import 'package:equatable/equatable.dart';
import 'package:wanandroid_flutter/entity/banner_entity.dart';
import 'package:wanandroid_flutter/entity/project_entity.dart';
import 'package:wanandroid_flutter/entity/project_type_entity.dart';

abstract class ProjectState extends Equatable {
  ProjectState([List props = const []]) : super(props);
}

class ProjectInit extends ProjectState {
  @override
  String toString() {
    return 'ProjectInit{}';
  }
}

class ProjectLoading extends ProjectState {
  @override
  String toString() {
    return 'ProjectLoading{}';
  }
}

class ProjectBannerLoaded extends ProjectState {
  List<BannerEntity> banners;

  ProjectBannerLoaded(this.banners) : super([banners]);

  @override
  String toString() {
    return 'ProjectBannerLoaded{banners: $banners}';
  }
}

class ProjectTypesLoaded extends ProjectState {
  List<ProjectTypeEntity> types;

  ProjectTypesLoaded(this.types) : super([types]);

  @override
  String toString() {
    return 'ProjectTypesLoaded{types: $types}';
  }
}

class ProjectDatasLoaded extends ProjectState {
  List<ProjectEntity> datas;

  ProjectDatasLoaded(this.datas) : super([datas]);

  @override
  String toString() {
    return 'ProjectDatasLoaded{datas: $datas}';
  }
}

class ProjectLoaded extends ProjectState {
  @override
  String toString() {
    return 'ProjectLoaded{}';
  }
}
