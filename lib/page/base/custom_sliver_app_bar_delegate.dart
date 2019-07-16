import 'dart:math' as math;

import 'package:flutter/material.dart';

///放在NestedScrollView中配合SliverPersistentHeader使用
///当[SliverAppBar]不满足使用时（比如希望自定义内容视图），就用这个。
///SliverPersistentHeader的pinned为true前提下，maxExtent即最大展开高度，minExtent即收缩到最小时留存的高度。
///（floating属性没做实现，失效了）
class CustomSliverAppBarDelegate extends SliverPersistentHeaderDelegate {

  CustomSliverAppBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => math.max(minHeight, maxHeight);

  @override
  double get minExtent => minHeight;

//  @override
//  FloatingHeaderSnapConfiguration get snapConfiguration => _snapConfiguration;

  @override
  bool shouldRebuild(CustomSliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
