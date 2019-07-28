import 'package:flutter/material.dart';

Widget getLevelWidgets(int level) {
  if (level < 1) {
    level = 1;
  }
  int crown = level ~/ (4 * 4 * 4);
  level %= (4 * 4 * 4);
  int sun = level ~/ (4 * 4);
  level %= (4 * 4);
  int moon = level ~/ (4);
  level %= (4);
  int star = level;
//  print('level.$crown,$sun,$moon,$star');
  List<Widget> icons = List<Widget>();
  icons.addAll(List.generate(crown, (index) {
    return Image.asset(
      'images/lv_crown.png',
      width: 20,
      height: 20,
      color: Colors.orangeAccent,
    );
  }).toList());
  icons.addAll(List.generate(sun, (index) {
    return Image.asset(
      'images/lv_sun.png',
      width: 20,
      height: 20,
      color: Colors.orangeAccent,
    );
  }).toList());
  icons.addAll(List.generate(moon, (index) {
    return Image.asset(
      'images/lv_moon.png',
      width: 20,
      height: 20,
      color: Colors.orangeAccent,
    );
  }).toList());
  icons.addAll(List.generate(star, (index) {
    return Image.asset(
      'images/lv_star.png',
      width: 20,
      height: 20,
      color: Colors.orangeAccent,
    );
  }).toList());
  return Row(
    children: icons,
  );
}
