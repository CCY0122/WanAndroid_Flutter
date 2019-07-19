import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:wanandroid_flutter/page/home/bloc/home_index.dart';

import 'project_index.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  HomeBloc homeBloc;
  StreamSubscription subscription;

  ProjectBloc(this.homeBloc) {
    print('project bloc constra');

    ///等主页的基础数据加载完了后，子页再开始加载数据
    ///因为state使用的是BehaviorSubject，即粘性广播，所以即使ProjectBloc在HomeBloc发送了HomeLoaded之后才被实例，listen依然能接收到该事件。这也是为什么不用blocListener的原因(它会skip(1))
    subscription = homeBloc.state.listen((state) {
      print('in constar listen state = $state');
      if (state is HomeLoaded) {}
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  ProjectState get initialState => null;

  @override
  Stream<ProjectState> mapEventToState(ProjectEvent event) {
    return null;
  }
}
