import 'package:bloc/bloc.dart';
import 'package:wanandroid_flutter/http/index.dart';
import 'package:wanandroid_flutter/utils/index.dart';

import 'home_index.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  @override
  HomeState get initialState => HomeLoading();

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    if (event is LoadHome) {
      yield* _mapLoadHomeToState();
    } else if (event is LogoutHome) {
      yield* _mapLogoutHomeToState();
    }
  }

  Stream<HomeState> _mapLoadHomeToState() async* {
    try {
      yield HomeLoading();
      bool isLogin = await SPUtil.isLogin();
      yield HomeLoaded(isLogin);
    } catch (e) {
      yield HomeLoadError(e);
    }
  }

  Stream<HomeState> _mapLogoutHomeToState() async* {
    try {
      yield HomeLoading();
      await AccountApi.logout();
      await SPUtil.setLogin(false);
      yield HomeLoaded(false);
    } catch (e) {
      yield HomeLoadError(e);
    }
  }
}
