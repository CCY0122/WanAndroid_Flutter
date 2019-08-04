import 'package:data_plugin/bmob/bmob_query.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wanandroid_flutter/entity/bmob_update_entity.dart';
import 'package:wanandroid_flutter/main.dart';
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
            if (index == 2) {
              return DecoratedBox(
                decoration: BoxDecoration(color: Colors.white),
                child: ListTile(
                  title: Text('Blog'),
                  trailing: Icon(Icons.navigate_next),
                  onTap: (() {
                    Navigator.pushNamed(
                      context,
                      WebViewPage.ROUTER_NAME,
                      arguments: {
                        'title': 'Blog',
                        'url': 'https://blog.csdn.net/ccy0122'
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
                  if (!bmobEnable) {
                    DisplayUtil.showMsg(context, text: '仅官方正式版支持检测升级');
                    return;
                  }
                  checkUpdate(context);
                }),
              ),
            );
          },
          itemCount: 4,
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
    print('版本信息：$appName,$packageName,$version,$buildNumber');
    setState(() {});
  }

  Future checkUpdate(BuildContext context) async{
    try {
      DisplayUtil.showMsg(context,text: 'checking...',duration: Duration(seconds: 1));
      BmobQuery<BmobUpdateEntity> query = BmobQuery();
      dynamic result = await query.queryObject('ed22ca3838');
      BmobUpdateEntity entity = BmobUpdateEntity.fromJson(result);
      print('$entity');

      if (version != null) {
        int cur = int.parse(version.replaceAll('.', ''));
        int news = int.parse(entity.versionName.replaceAll('.', ''));
        if (cur < news) {
          if (mounted) {
            showDialog(
                context: context,
                builder: (c) {
                  return AlertDialog(
                    title: Text(entity.versionName),
                    content: Text(entity.updateMsg),
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () {
                          _launchURL(entity.downloadUrl);
                        },
                        child: Text(res.go),
                      ),
                    ],
                  );
                });
            return;
          }
        }
      }
    } catch (e) {
      print(e);
      if (mounted) {
        DisplayUtil.showMsg(context, text: 'check update failed');
        return;
      }
    }
    if (mounted) {
      DisplayUtil.showMsg(context, text: res.isNewestVersion);
    }
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
