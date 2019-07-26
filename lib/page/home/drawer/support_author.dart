import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wanandroid_flutter/page/home/web_view.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/utils/index.dart';

class SupportAuthorPage extends StatefulWidget {
  static const ROUTER_NAME = '/SupportAuthorPage';

  @override
  _SupportAuthorPageState createState() => _SupportAuthorPageState();
}

class _SupportAuthorPageState extends State<SupportAuthorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(res.supportAuthor),
      ),
      body: Builder(
        builder: (context) {
          return Column(
            children: <Widget>[
              Image.asset('images/ccy_pay_qr.jpeg'),
              RaisedButton(
                onPressed: () {
                  _launchURL();
                },
                color: WColors.theme_color,
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Text(
                  '去网页版打赏作者',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '微信：ccy01220122',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    RaisedButton(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: 'ccy01220122'),
                        );
                        DisplayUtil.showMsg(context, text: '已复制微信号');
                      },
                      color: WColors.theme_color_dark,
                      padding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: Text(
                        '点击复制',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
              Image.asset(
                'images/nice_xiongdei.jpeg',
                width: 150,
                height: 150,
              ),
            ],
          );
        },
      ),
    );
  }

  _launchURL() async {
    var url = 'https://github.com/CCY0122/FocusLayoutManager/blob/master/pic/341561604648_.pic.jpg';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
