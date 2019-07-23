
import 'package:flutter/material.dart';

class NestedTestPage extends StatelessWidget {
  List<String> _tabs = ['1','22','333','4444','55555'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                child: SliverAppBar(
                  title: const Text('Books'),
                  pinned: true,
                  expandedHeight: 150.0,

                  forceElevated: innerBoxIsScrolled,
                  bottom: TabBar(
                    tabs: _tabs.map((String name) => Tab(text: name)).toList(),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: _tabs.map((String name) {
              return TestSubPage(name);
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class TestSubPage extends StatefulWidget {
  String name;

  TestSubPage(this.name);

  @override
  _TestSubPageState createState() => _TestSubPageState();
}

class _TestSubPageState extends State<TestSubPage> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      top: false,
      bottom: false,
      child: Builder(
        builder: (BuildContext context) {
          return CustomScrollView(
            key: PageStorageKey<String>(widget.name),
            slivers: <Widget>[
              SliverOverlapInjector(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(8.0),
                sliver: SliverFixedExtentList(
                  itemExtent: 48.0,
                  delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      return ListTile(
                        title: Text('Item $index'),
                      );
                    },
                    childCount: 30,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

