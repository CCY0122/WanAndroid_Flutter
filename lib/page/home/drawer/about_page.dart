import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:wanandroid_flutter/page/home/web_view.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/utils/index.dart';

class AboutPage extends StatefulWidget {
  static const ROUTER_NAME = '/AboutPage';

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String appName;
  String packageName;
  String version;
  String buildNumber;

  @override
  void initState() {
    super.initState();
    getPackageInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(res.about),
      ),
      body: Container(
        color: WColors.gray_background,
        child: ListView.builder(
          itemBuilder: (context, index) {
            if (index == 0) return _logo();
            if (index == 1) {
              return DecoratedBox(
                decoration: BoxDecoration(color: Colors.white),
                child: ListTile(
                  title: Text('GitHub'),
                  trailing: Icon(Icons.navigate_next),
                  onTap: (() {
                    Navigator.pushNamed(
                      context,
                      WebViewPage.ROUTER_NAME,
                      arguments: {
                        'title': 'GitHub',
                        'url': 'https://github.com/CCY0122/WanAndroid_Flutter'
                      },
                    );
                  }),
                ),
              );
            }
            return DecoratedBox(
              decoration: BoxDecoration(color: Colors.white),
              child: ListTile(
                title: Text(res.checkUpdate),
                trailing: Icon(Icons.navigate_next),
                onTap: (() {
                  DisplayUtil.showMsg(context, text: '检测升级');
                }),
              ),
            );
          },
          itemCount: 3,
        ),
      ),
    );
  }

  Widget _logo() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            top: pt(70),
            bottom: pt(20),
          ),
          child: Image.asset(
            'images/ic_launcher.png',
            color: WColors.theme_color,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: pt(30)),
          child: Text('v.$version'),
        ),
      ],
    );
  }

  Future getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
    setState(() {});
  }
}
