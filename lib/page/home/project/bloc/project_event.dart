import 'package:equatable/equatable.dart';

abstract class ProjectEvent extends Equatable {
  ProjectEvent([List props = const []]) : super(props);
}


class LoadProject extends ProjectEvent{

  @override
  String toString() {
    return 'LoadProject{}';
  }
}

