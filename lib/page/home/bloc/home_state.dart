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
