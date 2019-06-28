import 'package:flutter/material.dart';

///Created by ccy(17022) on ${DATE} ${TIME}
///角标与布局的相对位置
enum BadgeAlignment {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

enum BadgeLocation {
  ///角标在布局内部，offsetX、offsetY会让角标向布局内偏移。
  inside,

  ///角标可以超出布局，offsetX、offsetY会让角标向布局外偏移。
  outside,
}

///角标控件
class Badge extends StatefulWidget {
  final BadgeAlignment badgeAlignment;
  final BadgeLocation badgeLocation;

  ///角标背景颜色
  final Color color;

  ///角标内偏移。
  ///ps:当[badge]为null，[shape]为圆形时，该值即圆点角标的半径
  final EdgeInsetsGeometry padding;

  ///角标相对位置偏移量。受[BadgeLocation]影响
  double offsetX;

  ///角标相对位置偏移量。受[BadgeLocation]影响
  double offsetY;

  ///角标形状。一般都是圆形或者圆角矩形。默认圆形
  final ShapeBorder shape;

  ///角标z轴值
  final double elevation;

  ///角标内容。可以为null
  Widget badge;

  ///布局
  final Widget child;

  ///角标是否可见
  final bool visible;

  Badge({
    Key key,
    this.badgeAlignment = BadgeAlignment.topRight,
    this.badgeLocation = BadgeLocation.outside,
    this.color = const Color(0xFFE84E40),
    this.padding = const EdgeInsets.all(5),
    this.offsetX,
    this.offsetY,
    this.shape = const CircleBorder(),
    this.elevation = 0.0,
    this.badge,
    this.child,
    this.visible = true,
  }) : super(key: key) {
    //当没有设置offsetX、Y时，若是圆点角标且位置可以超出布局，那么默认超出的偏移量为圆点半径。
    //这样效果正好圆心在布局矩形的角上
    bool isCircleAndOutSide = (badge == null &&
        shape is CircleBorder &&
        badgeLocation == BadgeLocation.outside &&
        padding is EdgeInsets);

    offsetX ??= (isCircleAndOutSide
        ? (padding as EdgeInsets).left
        : getSuitableDefaultOffset(true));
    offsetY ??= (isCircleAndOutSide
        ? (padding as EdgeInsets).left
        : getSuitableDefaultOffset(false));
  }

  double getSuitableDefaultOffset(bool isOffsetX) {
    //经测试，如果是text且形状为圆形，圆形上下空间会有一定padding。为了视觉上更好，Y偏移量要比X少一点
    if (badge != null && badge is Text && shape is CircleBorder) {
      if (isOffsetX) {
        return badgeLocation == BadgeLocation.inside ? 3 : 8;
      } else {
        return badgeLocation == BadgeLocation.inside ? 0 : 11; //比X少偏移3
      }
    } else {
      //其他正常情况。
      return badgeLocation == BadgeLocation.inside ? 3 : 8;
    }
  }

  @override
  _BadgeState createState() => _BadgeState();
}

class _BadgeState extends State<Badge> {
  @override
  Widget build(BuildContext context) {
    double left, top, right, bottom;
    switch (widget.badgeAlignment) {
      case BadgeAlignment.topLeft:
        left = widget.badgeLocation == BadgeLocation.inside
            ? widget.offsetX
            : -widget.offsetX;
        top = widget.badgeLocation == BadgeLocation.inside
            ? widget.offsetY
            : -widget.offsetY;
        break;
      case BadgeAlignment.topRight:
        right = widget.badgeLocation == BadgeLocation.inside
            ? widget.offsetX
            : -widget.offsetX;
        top = widget.badgeLocation == BadgeLocation.inside
            ? widget.offsetY
            : -widget.offsetY;
        break;
      case BadgeAlignment.bottomLeft:
        left = widget.badgeLocation == BadgeLocation.inside
            ? widget.offsetX
            : -widget.offsetX;
        bottom = widget.badgeLocation == BadgeLocation.inside
            ? widget.offsetY
            : -widget.offsetY;
        break;
      case BadgeAlignment.bottomRight:
        right = widget.badgeLocation == BadgeLocation.inside
            ? widget.offsetX
            : -widget.offsetX;
        bottom = widget.badgeLocation == BadgeLocation.inside
            ? widget.offsetY
            : -widget.offsetY;
        break;
    }
    if (widget.child == null) {
      return Offstage(
        offstage: !widget.visible,
        child: createBadgeView(),
      );
    } else {
      return Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          widget.child,
          Positioned(
            child: Offstage(
              offstage: !widget.visible,
              child: createBadgeView(),
            ),
            left: left,
            top: top,
            right: right,
            bottom: bottom,
          )
        ],
      );
    }
  }

  Widget createBadgeView() {
    return Material(
      type: MaterialType.canvas,
      elevation: widget.elevation,
      shape: widget.shape,
      color: widget.color,
      child: Padding(
        padding: widget.padding,
        child: widget.badge,
      ),
    );
  }
}
