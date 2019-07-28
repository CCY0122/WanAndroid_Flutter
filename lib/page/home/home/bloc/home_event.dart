import 'package:equatable/equatable.dart';
import 'package:wanandroid_flutter/entity/bmob_user_entity.dart';

abstract class HomeEvent extends Equatable {
  HomeEvent([List props = const []]) : super(props);
}

///加载主页数据
class LoadHome extends HomeEvent {
  @override
  String toString() {
    return 'LoadHome';
  }
}

class LogoutHome extends HomeEvent {
  @override
  String toString() {
    return 'LogoutHome';
  }
}

class StartSearchEvent extends HomeEvent {
  bool isSearchWXArticle;
  String searchKey;

  StartSearchEvent(this.isSearchWXArticle, this.searchKey)
      : super([isSearchWXArticle, searchKey]);

  @override
  String toString() {
    return 'StartSearchEvent{isSearchWXArticle: $isSearchWXArticle, searchKey: $searchKey}';
  }
}

///加载bmob用户信息
class LoadBmobInfo extends HomeEvent {
  String userName;

  LoadBmobInfo(this.userName) : super([userName]);

  @override
  String toString() {
    return 'LoadBmobInfo{userName: $userName}';
  }
}

class UpdateBmobInfo extends HomeEvent{
  BmobUserEntity bmobUserEntity;

  UpdateBmobInfo(this.bmobUserEntity) : super([bmobUserEntity]);

  @override
  String toString() {
    return 'UpdateBmobInfo{bmobUserEntity: $bmobUserEntity}';
  }
}
