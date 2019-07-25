import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/views/loading_view.dart';

class WebViewPage extends StatefulWidget {
  static const ROUTER_NAME = '/WebViewPage';

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  String title;
  String url;
  FlutterWebviewPlugin flutterWebviewPlugin;

  @override
  void initState() {
    super.initState();
    flutterWebviewPlugin = FlutterWebviewPlugin();
  }

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context).settings.arguments;
    if (args is Map) {
      title = args['title'];
      url = args['url'];
    }
    return WebviewScaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Container(
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: EdgeInsets.only(left: 10, right: 8),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
              onTap: () {
                flutterWebviewPlugin.goBack();
              },
            ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.open_in_browser,
              color: Colors.white,
            ),
            tooltip: res.openBrowser,
            onPressed: () {
              _launchURL();
            },
          )
        ],
      ),
      url: url,
      hidden: true,
      initialChild: getLoading(),
      withZoom: true,
      withLocalStorage: true,
    );
  }

  _launchURL() async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
