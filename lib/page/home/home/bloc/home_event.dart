import 'package:equatable/equatable.dart';

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
