import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  static const ROUTER_NAME = '/SearchPage';

  String searchKey;

  @override
  Widget build(BuildContext context) {
    searchKey = ModalRoute.of(context).settings.arguments;
    return Container();
  }
}

