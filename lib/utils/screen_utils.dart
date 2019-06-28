import 'dart:ui' as ui;

import 'package:flutter/material.dart';

//系统默认的appBar等高度
//位于Dart Packages/flutter/src/material/constans.dart

///默认设计稿尺寸
double _designW = 375.0;
double _designH = 667.0;

/**
 * 配置设计稿尺寸
 * w 宽
 * h 高
 */

/// 配置设计稿尺寸 屏幕 宽，高
void setDesignWHD(double w, double h) {
  _designW = w;
  _designH = h;
}

///--------------屏幕适配。按【宽】适配。------------------

/// Screen Util.
class ScreenUtils {
  double _screenWidth = 0.0;
  double _screenHeight = 0.0;
  double _screenDensity = 0.0;
  double _statusBarHeight = 0.0;
  double _bottomBarHeight = 0.0;
  double _appBarHeight = 0.0;
  MediaQueryData _mediaQueryData;

  static final ScreenUtils _singleton = ScreenUtils._internal();

  ScreenUtils._internal();

  static ScreenUtils getInstance() {
    _singleton._init();
    return _singleton;
  }

  ///类似屏幕旋转等窗口变化时，需重新init以获取新的MediaQueryData
  _init() {
    MediaQueryData mediaQuery = MediaQueryData.fromWindow(ui.window);
    if (mediaQuery == null) {
      throw Exception("获取MediaQueryData失败");
    }
    if (_mediaQueryData != mediaQuery) {
      _mediaQueryData = mediaQuery;
      _screenWidth = mediaQuery.size.width;
      _screenHeight = mediaQuery.size.height;
      _screenDensity = mediaQuery.devicePixelRatio;
      _statusBarHeight = mediaQuery.padding.top;
      _bottomBarHeight = mediaQuery.padding.bottom;
      _appBarHeight = kToolbarHeight;
    }
  }

  _initByMedia(MediaQueryData mediaQuery) {
    if (_mediaQueryData != mediaQuery) {
      _mediaQueryData = mediaQuery;
      _screenWidth = mediaQuery.size.width;
      _screenHeight = mediaQuery.size.height;
      _screenDensity = mediaQuery.devicePixelRatio;
      _statusBarHeight = mediaQuery.padding.top;
      _bottomBarHeight = mediaQuery.padding.bottom;
      _appBarHeight = kToolbarHeight;
    }
  }

  /// 屏幕 宽
  double get screenWidth => _screenWidth;

  /// 屏幕 高
  double get screenHeight => _screenHeight;

  /// appBar(标题栏） 默认高
  double get appBarHeight => _appBarHeight;

  /// 屏幕 像素密度
  double get screenDensity => _screenDensity;

  /// 状态栏高度
  double get statusBarHeight => _statusBarHeight;

  /// 底部栏高度（如android底部虚拟按键区域）
  double get bottomBarHeight => _bottomBarHeight;

  /// media Query Data
  MediaQueryData get mediaQueryData => _mediaQueryData;

  /// 按宽度适配时。
  /// 返回适配后尺寸
  /// size 即设计稿上使用的单位
  double getWidth(double size) {
    //屏幕实际总宽度 ： 设计稿总宽度 = 适配宽度 ： 传入的size
    return _screenWidth == 0.0 ? size : (size * _screenWidth / _designW);
  }

  /// 按高度适配时。
  /// 返回适配后尺寸
  /// size 即设计稿上使用的单位
  double getHeight(double size) {
    return _screenHeight == 0.0 ? size : (size * _screenHeight / _designH);
  }

  /// 返回根据屏幕宽适配后字体尺寸
  /// fontSize 字体尺寸
  double getSp(double fontSize) {
    if (_screenDensity == 0.0) return fontSize;
    return getWidth(fontSize);
  }

  ///-------------快捷方法---------------

  double pt(double size) {
    return getWidth(size);
  }
}

///-------------快捷静态方法。-----------------
 double pt(double size) {
//  MediaQueryData mediaQuery = MediaQuery.of(context);
  MediaQueryData mediaQuery = MediaQueryData.fromWindow(ui.window);
  double _screenWidth = mediaQuery.size.width;
  return _screenWidth == 0.0 ? size : (size * _screenWidth / _designW);
}
