import 'package:flutter/material.dart';
import 'package:wanandroid_flutter/utils/index.dart';

class SearchBar extends StatefulWidget {
  double height;
  double width;
  Widget child;
  Color color;
  Color iconColor;

  SearchBar({this.height, this.width, this.child, this.color, this.iconColor});

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        borderRadius: widget.height != null
            ? BorderRadius.circular(widget.height / 2)
            : null,
        color: widget.color,
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: pt(5),
            ),
            child: Icon(
              Icons.search,
              color: widget.iconColor,
            ),
          ),
          Expanded(
            child: widget.child ?? Container(),
          )
        ],
      ),
    );
  }
}
