import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wanandroid_flutter/entity/base_entity.dart';
import 'package:wanandroid_flutter/entity/base_list_entity.dart';
import 'package:wanandroid_flutter/entity/project_entity.dart';
import 'package:wanandroid_flutter/http/index.dart';
import 'package:wanandroid_flutter/page/account/login_wanandroid_page.dart';
import 'package:wanandroid_flutter/page/home/web_view.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/utils/index.dart';
import 'package:wanandroid_flutter/utils/string_decode.dart';
import 'package:wanandroid_flutter/views/load_more_footer.dart';
import 'package:wanandroid_flutter/views/loading_view.dart';

///项目细分页
class ProjectDetailPage extends StatefulWidget {
  static const ROUTER_NAME = '/ProjectDetailPage';

  @override
  _ProjectDetailPageState createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage>
    with TickerProviderStateMixin {
  int typeId;
  String typeName;
  List<ProjectEntity> datas;
  int currentPage;
  int totalPage;
  bool isloading;
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    currentPage = 1;
    totalPage = 1;
    isloading = false;
    datas = [];
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    if (typeId == null || typeName == null) {
      Map args = ModalRoute.of(context).settings.arguments;
      typeId = args['id'];
      typeName = args['name'];
      getProjects(id: typeId);

      _scrollController.addListener(() {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent) {
          if (currentPage < totalPage && !isloading) {
            getProjects(page: currentPage + 1, id: typeId);
          }
        }
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(typeName),
      ),
      backgroundColor: WColors.gray_background,
      body: Builder(
        builder: (context) {
          return getLoadingParent(
            ListView.builder(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                if (index < datas.length) {
                  return Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: pt(16), vertical: pt(6)),
                    height: pt(180),
                    child: ProjectItem(datas[index], isloading),
                  );
                } else {
                  return getLoadMoreFooter(currentPage < totalPage);
                }
              },
              itemCount: datas.length + 1,
              controller: _scrollController,
            ),
            isLoading: isloading,
          );
        },
      ),
    );
  }

  Future getProjects({int page = 1, @required int id}) async {
    isloading = true;
    setState(() {});
    try {
      Response response = await ProjectApi.getProjectList(page, id);
      BaseEntity<Map<String, dynamic>> baseEntity =
          BaseEntity.fromJson(response.data);
      BaseListEntity<List> baseListEntity =
          BaseListEntity.fromJson(baseEntity.data);
      currentPage = baseListEntity.curPage;
      totalPage = baseListEntity.pageCount;
      if (datas == null || datas.length == 0) {
        datas =
            baseListEntity.datas.map((e) => ProjectEntity.fromJson(e)).toList();
      } else {
        datas.addAll(baseListEntity.datas
            .map((e) => ProjectEntity.fromJson(e))
            .toList());
      }
    } catch (e) {
      DisplayUtil.showMsg(context, exception: e);
    }

    isloading = false;
    setState(() {});
  }
}

class ProjectItem extends StatefulWidget {
  ProjectEntity data;
  bool isLoading;

  ProjectItem(this.data, this.isLoading);

  @override
  _ProjectItemState createState() => _ProjectItemState();
}

class _ProjectItemState extends State<ProjectItem>
    with SingleTickerProviderStateMixin {
  bool lastCollectState;
  AnimationController _collectController;
  Animation _collectAnim;

  @override
  void initState() {
    super.initState();
    _collectController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    CurvedAnimation curvedAnimation =
        CurvedAnimation(parent: _collectController, curve: Curves.easeOut);
    _collectAnim = Tween<double>(begin: 1, end: 1.8).animate(curvedAnimation);
  }

  @override
  void dispose() {
    _collectController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (lastCollectState == false && lastCollectState != widget.data.collect) {
      _collectController.forward(from: 0).then((_) {
        _collectController.reverse();
      });
    }
    lastCollectState = widget.data.collect;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(pt(6))),
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            WebViewPage.ROUTER_NAME,
            arguments: {
              'title': widget.data.title,
              'url': widget.data.link,
            },
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: widget.data.envelopePic,
              height: double.infinity,
              width: pt(100),
              alignment: Alignment(0.0, -0.95),
              fit: BoxFit.cover,
              placeholder: (BuildContext context, String url) {
                return Container(
                  color: Colors.grey[300],
                );
              },
              errorWidget: (BuildContext context, String url, Object error) {
                return Container(
                  color: Colors.grey[300],
                );
              },
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: pt(4), horizontal: pt(4)),
                    child: Text(
                      decodeString(widget.data.title),
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: pt(2), horizontal: pt(4)),
                      child: Text(
                        decodeString(widget.data.desc),
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                            fontSize: 13, color: WColors.hint_color_dark),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(pt(4), pt(4), pt(8), pt(4)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${widget.data.niceDate}  ${widget.data.author}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: WColors.hint_color_dark),
                          ),
                        ),
                        GestureDetector(
                          child: ScaleTransition(
                            scale: _collectAnim,
                            child: Icon(
                              widget.data.collect
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: widget.data.collect
                                  ? WColors.warning_red
                                  : Colors.grey,
                              size: 22,
                            ),
                          ),
                          onTap: () {
                            if (widget.isLoading) {
                              return;
                            }
                            SPUtil.isLogin().then(
                              (isLogin) {
                                if (isLogin) {
                                  collect(widget.data.id, !widget.data.collect);
                                } else {
                                  Navigator.pushNamed(
                                      context, LoginWanandroidPage.ROUTER_NAME);
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future collect(int id, bool collect) async {
    try {
      if (collect) {
        await CollectApi.collect(id);
      } else {
        await CollectApi.unCollect(id);
      }
      widget.data.collect = collect;
    } catch (e) {
      print(e);
      DisplayUtil.showMsg(context, exception: e);
    }
    setState(() {});
  }
}
