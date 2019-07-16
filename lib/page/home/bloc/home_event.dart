import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  HomeEvent([List props = const []]) : super(props);
}


class LoadHome extends HomeEvent{
  @override
  String toString() {
    return 'LoadHome';
  }
}

class LogoutHome extends HomeEvent{
  @override
  String toString() {
    return 'LogoutHome';
  }
}
