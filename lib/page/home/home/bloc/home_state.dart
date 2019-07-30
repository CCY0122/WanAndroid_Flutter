import 'package:equatable/equatable.dart';
import 'package:wanandroid_flutter/entity/bmob_user_entity.dart';

abstract class HomeState extends Equatable {
  HomeState([List props = const []]) : super(props);
}

class HomeLoading extends HomeState {
  @override
  String toString() {
    return 'HomeLoading';
  }
}

///主页基础数据已加载完成的state，主页内的所有子页需等待主页基础数据完成后再加载各自的数据，即有依赖关系。
///如果后面还想做如"检测升级"等逻辑，由于子页面没必要依赖"检测升级"，
///所以主页到时候的状态顺序应当类似这样：加载子页需要依赖的数据（如登录状态）-> 发送HomeLoaded -> 静默加载子页不依赖的数据（如检测升级）-> 发送类似如HomeBackgroundTaskLoaded的state。
///而不应该是这样：加载子页需要依赖的数据（如登录状态）同时加载子页不依赖的数据（如检测升级）-> 发送HomeLoaded
class HomeLoaded extends HomeState {
  bool isLogin;
  String userName;

  HomeLoaded(this.isLogin, {this.userName}) : super([isLogin, userName]);

  @override
  String toString() {
    return 'HomeLoaded';
  }
}

class HomeLoadError extends HomeState {
  Exception exception;

  HomeLoadError(this.exception) : super([exception]);

  @override
  String toString() {
    return 'HomeLoadError';
  }
}

class HomeSearchStarted extends HomeState {
  bool isSearchWXArticle;
  String searchKey;

  HomeSearchStarted(this.isSearchWXArticle, this.searchKey)
      : super([isSearchWXArticle, searchKey,new Object()/*每次都实例一个新obj，这样可以被认为每次都是新的state即使内容都一样。*/]);

  @override
  String toString() {
    return 'HomeSearchStarted{isSearchWXArticle: $isSearchWXArticle, searchKey: $searchKey}';
  }
}

///bmob用户信息获取
class HomeBmobLoaded extends HomeState {
  BmobUserEntity bmobUserEntity;

  HomeBmobLoaded(this.bmobUserEntity) : super([bmobUserEntity]);

  @override
  String toString() {
    return 'HomeBmobLoaded{bmobUserEntity: $bmobUserEntity}';
  }
}
