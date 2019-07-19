import 'package:equatable/equatable.dart';

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
///所以主页到状态顺序应当类似这样：加载子页需要依赖的数据（如登录状态）-> 发送HomeLoaded -> 静默加载子页不依赖的数据（如检测升级）-> 发送类似如HomeBackgroundTaskLoaded的state。
///而不是这样：加载子页需要依赖的数据（如登录状态）同时加载子页不依赖的数据（如检测升级）-> 发送HomeLoaded
class HomeLoaded extends HomeState {
  bool isLogin;

  HomeLoaded(this.isLogin) : super([isLogin]);

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
