import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:wanandroid_flutter/entity/banner_entity.dart';
import 'package:wanandroid_flutter/entity/base_entity.dart';
import 'package:wanandroid_flutter/entity/base_list_entity.dart';
import 'package:wanandroid_flutter/entity/project_entity.dart';
import 'package:wanandroid_flutter/entity/project_type_entity.dart';
import 'package:wanandroid_flutter/http/index.dart';
import 'package:wanandroid_flutter/page/home/bloc/home_index.dart';
import 'package:wanandroid_flutter/page/home/project/bloc/project_index.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/utils/index.dart';
import 'package:wanandroid_flutter/views/flat_pagination.dart';
import 'dart:convert';

///项目主页，也是主页的第一个tab页
///todo 加载更多、下啦刷新
class ProjectSubPage extends StatefulWidget {
  @override
  _ProjectSubPageState createState() => _ProjectSubPageState();
}

class _ProjectSubPageState extends State<ProjectSubPage>
    with AutomaticKeepAliveClientMixin {
  ProjectBloc projectBloc;
  List<BannerEntity> banners;
  List<ProjectTypeEntity> projectTypes;
  List<ProjectEntity> projectDatas;

  @override
  void initState() {
    super.initState();
    projectBloc = ProjectBloc(BlocProvider.of<HomeBloc>(context));
    banners ??= [];
    projectTypes ??= [
      ProjectTypeEntity.t(1, '全部'),
      ProjectTypeEntity.t(1, '啊开发阿萨德模式'),
      ProjectTypeEntity.t(1, '1开发模式'),
      ProjectTypeEntity.t(1, '开发模式'),
      ProjectTypeEntity.t(1, '开发模式'),
      ProjectTypeEntity.t(1, '1'),
      ProjectTypeEntity.t(1, '开发模式'),
      ProjectTypeEntity.t(1, '1'),
      ProjectTypeEntity.t(1, '1'),
      ProjectTypeEntity.t(1, '开发模式'),
      ProjectTypeEntity.t(1, '1'),
      ProjectTypeEntity.t(1, '全部'),
      ProjectTypeEntity.t(1, '开发模式'),
      ProjectTypeEntity.t(1, '1开发模式'),
      ProjectTypeEntity.t(1, '全部'),
      ProjectTypeEntity.t(1, '开发模式'),
      ProjectTypeEntity.t(1, '1开发模式'),
      ProjectTypeEntity.t(1, '全部'),
      ProjectTypeEntity.t(1, '开发模式'),
      ProjectTypeEntity.t(1, '1开发模式'),
      ProjectTypeEntity.t(1, '全部'),
      ProjectTypeEntity.t(1, '开发模式'),
      ProjectTypeEntity.t(1, '1开发模式'),
      ProjectTypeEntity.t(1, '全部'),
      ProjectTypeEntity.t(1, '开发模式'),
      ProjectTypeEntity.t(1, '1开发模式'),
      ProjectTypeEntity.t(1, '全部'),
      ProjectTypeEntity.t(1, '开发模式'),
      ProjectTypeEntity.t(1, '1开发模式'),
      ProjectTypeEntity.t(1, '全部'),
      ProjectTypeEntity.t(1, '开发模式'),
      ProjectTypeEntity.t(1, '1开发模式'),
      ProjectTypeEntity.t(1, '全部'),
      ProjectTypeEntity.t(1, '开发模式'),
      ProjectTypeEntity.t(1, '1开发模式'),
      ProjectTypeEntity.t(1, '全部'),
      ProjectTypeEntity.t(1, '开发模式'),
      ProjectTypeEntity.t(1, '1开发模式'),
      ProjectTypeEntity.t(1, '全部'),
      ProjectTypeEntity.t(1, '开发模式'),
      ProjectTypeEntity.t(1, '1开发模式'),
      ProjectTypeEntity.t(1, '全部'),
      ProjectTypeEntity.t(1, '开发模式'),
      ProjectTypeEntity.t(1, '1开发模式'),
    ];
    projectDatas ??= [];
    t();
  }

  Future t() async {
    await Future.delayed(Duration(seconds: 2));
    Response res =
        await dio.get('https://www.wanandroid.com/article/listproject/0/json');
        await dio.get('https://www.wanandroid.com/lg/collect/list/0/json');
    BaseEntity baseEntity = BaseEntity.fromJson(res.data);
    BaseListEntity<List> baseListEntity =
        BaseListEntity.fromJson(baseEntity.data);
    projectDatas = baseListEntity.datas.map((json) {
      return ProjectEntity.fromJson(json);
    }).toList();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProviderTree(
      blocProviders: [
        BlocProvider(builder: (context) => projectBloc),
      ],
      child: BlocListenerTree(
        blocListeners: [
          BlocListener<ProjectEvent, ProjectState>(
            bloc: projectBloc,
            listener: (context, state) {
              if (state is ProjectBannerLoaded) {
                banners = state.banners;
              } else if (state is ProjectTypesLoaded) {
                projectTypes = state.types;
              } else if (state is ProjectDatasLoaded) {
                projectDatas = state.datas;
              }
            },
          ),
        ],
        child: BlocBuilder<ProjectEvent, ProjectState>(
          bloc: projectBloc,
          builder: (context, state) {
            return CustomScrollView(
              physics: AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: bannerView(
                      datas: banners.map((entity) {
                    return BannerModel(
                      entity.title ?? '',
                      entity.imagePath ?? '',
                      entity.url ?? '',
                    );
                  }).toList()),
                ),
                SliverToBoxAdapter(
                  child: typesGridView(
                    datas: projectTypes
                        .asMap()
                        .map<int, ProjectTypesModel>((index, entity) {
                          return MapEntry(
                            index,
                            ProjectTypesModel(
                              entity.id,
                              entity.name,
                              Image.asset(
                                MyImage.animals[index % MyImage.animals.length],
                                width: pt(40),
                                height: pt(40),
                              ),
                            ),
                          );
                        })
                        .values
                        .toList(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    color: WColors.gray_background,
                    padding: EdgeInsets.only(left: pt(16), top: pt(8)),
                    child: Row(
                      children: <Widget>[
                        Image.asset(
                          'images/new.png',
                          width: pt(30),
                          height: pt(30),
                        ),
                        SizedBox(
                          width: pt(10),
                        ),
                        Text(
                          res.newestProject,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
                projectGrid(datas: projectDatas),
              ],
            );
          },
        ),
      ),
    );
  }

  ///banner
  Widget bannerView({List<BannerModel> datas = const []}) {
    datas = [
      BannerModel(
          '',
          'https://wanandroid.com/blogimgs/0b712568-6203-4a03-b475-ff55e68d89e8.jpeg',
          ''),
      BannerModel(
          '',
          'https://wanandroid.com/blogimgs/0b712568-6203-4a03-b475-ff55e68d89e8.jpeg',
          ''),
      BannerModel(
          '',
          'https://wanandroid.com/blogimgs/0b712568-6203-4a03-b475-ff55e68d89e8.jpeg',
          ''),
      BannerModel(
          '',
          'https://wanandroid.com/blogimgs/0b712568-6203-4a03-b475-ff55e68d89e8.jpeg',
          ''),
      BannerModel(
          '',
          'https://wanandroid.com/blogimgs/0b712568-6203-4a03-b475-ff55e68d89e8.jpeg',
          ''),
    ];
    return Container(
      height: pt(140 + 16 * 2.0),
      padding: EdgeInsets.all(pt(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(pt(6)),
        child: Swiper(
          itemCount: datas.length,
          itemBuilder: (context, index) {
            BannerModel data = datas[index];
            return CachedNetworkImage(
              imageUrl: data.imagePath,
              fit: BoxFit.cover,
              placeholder: (context, url) {
                return DecoratedBox(
                  decoration: BoxDecoration(color: Colors.grey[300]),
                );
              },
            );
          },
          autoplay: true,
          pagination: SwiperPagination(
            builder: FlatDotSwiperPaginationBuilder(
              color: Colors.grey[300],
              activeColor: WColors.theme_color,
              size: 5,
              activeSize: 5,
              space: 2.5,
            ),
            alignment: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  ///项目分类网格布局，固定两行
  Widget typesGridView({List<ProjectTypesModel> datas = const []}) {
    //为了练习代码，就不做成上面bannerView这种可直接用Swiper实现的滑动效果了
//    datas = [
//      ProjectTypesModel(
//          null,
//          'asd1',
//          Icon(
//            Icons.ac_unit,
//            size: pt(35),
//          )),
//      ProjectTypesModel(
//          null,
//          'asd2',
//          Icon(
//            Icons.ac_unit,
//            size: pt(35),
//          )),
//      ProjectTypesModel(
//          null,
//          'asd3',
//          Icon(
//            Icons.ac_unit,
//            size: pt(35),
//          )),
//      ProjectTypesModel(
//          null,
//          'asd4',
//          Icon(
//            Icons.ac_unit,
//            size: pt(35),
//          )),
//      ProjectTypesModel(
//          null,
//          'asd5',
//          Icon(
//            Icons.ac_unit,
//            size: pt(35),
//          )),
//      ProjectTypesModel(
//          null,
//          'asd6',
//          Icon(
//            Icons.ac_unit,
//            size: pt(35),
//          )),
//      ProjectTypesModel(
//          null,
//          'asd7',
//          Icon(
//            Icons.ac_unit,
//            size: pt(35),
//          )),
//      ProjectTypesModel(
//          null,
//          'asd8',
//          Icon(
//            Icons.ac_unit,
//            size: pt(35),
//          )),
//      ProjectTypesModel(
//          null,
//          'asd9',
//          Icon(
//            Icons.ac_unit,
//            size: pt(35),
//          )),
//      ProjectTypesModel(
//          null,
//          'asd10',
//          Icon(
//            Icons.ac_unit,
//            size: pt(35),
//          )),
//      ProjectTypesModel(
//          null,
//          'asd11',
//          Icon(
//            Icons.ac_unit,
//            size: pt(35),
//          )),
//    ];

    //一行最多item
    int maxOneRowCount = (datas.length / 2).ceil();
    if (datas.length == 1) {
      maxOneRowCount = 1;
    }
    //一行的一屏内最多可显示item
    int maxOnScreenCount = 5;
    double itemWidth;
    if (maxOneRowCount <= maxOnScreenCount) {
      //一屏放得下，均分屏幕宽
      itemWidth = pt(375) / maxOneRowCount;
    } else {
      //一屏放不下，可横向滚动，末尾露出一半item让用户好发现这是可以横向滚动的
      itemWidth = pt(375) / (maxOnScreenCount + 0.5);
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: Iterable.generate(maxOneRowCount, (index) {
              ProjectTypesModel data = datas[index];
              return Container(
                alignment: Alignment.center,
                width: itemWidth,
                height: pt(75),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    data.icon,
                    Text(
                      data.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: WColors.hint_color_dark, fontSize: 12),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          datas.length == 1
              ? Container()
              : Row(
                  children:
                      Iterable.generate(datas.length - maxOneRowCount, (index) {
                    ProjectTypesModel data = datas[index + maxOneRowCount];
                    return Container(
                      alignment: Alignment.center,
                      width: itemWidth,
                      height: pt(75),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          data.icon,
                          Text(
                            data.title,
                            style: TextStyle(
                                color: WColors.hint_color_dark, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget projectGrid({List<ProjectEntity> datas = const []}) {
    return SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            //问题：没有类似SliverDecoration这种控件，那么怎么独立设置sliver的背景颜色呢？暂时通过改变每个item的颜色来实现吧
            return Container(
              color: WColors.gray_background,
              padding: index % 2 == 0
                  ? EdgeInsets.only(
                      left: pt(12), right: pt(6), top: pt(6), bottom: pt(6))
                  : EdgeInsets.only(
                      left: pt(6), right: pt(12), top: pt(6), bottom: pt(6)),
              child: projectItem(datas[index]),
            );
          },
          childCount: datas.length,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.9,
        ));
  }

  ///项目item
  Widget projectItem(ProjectEntity data) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(pt(6))),
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        onTap: (){
          print('click item');
          t();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Stack(
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl: data.envelopePic,
                    width: double.infinity,
                    alignment: Alignment(0.0, -0.95),
                    fit: BoxFit.cover,
                    placeholder: (BuildContext context, String url) {
                      return Container(
                        color: Colors.grey[300],
                      );
                    },
                    errorWidget:
                        (BuildContext context, String url, Object error) {
                      return Container(
                        color: Colors.grey[300],
                      );
                    },
                  ),
                  Positioned(
                    bottom: pt(4),
                    left: pt(4),
                    child: Text(
                      data.author,
                      style: TextStyle(color: Colors.white, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: pt(4), horizontal: pt(4)),
              child: Text(
                data.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: (){
                print('click type ${data.chapterName}');
              },
              child: Padding(
                padding: EdgeInsets.only(bottom: pt(6), left: pt(4), right: pt(4)),
                child: Row(
                  children: <Widget>[
                    Text(
                      data.chapterName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: WColors.hint_color_dark,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: WColors.hint_color_dark,
                      size: pt(10),
                    ),
                    Expanded(
                        child: Align(
                      alignment: Alignment(0.9, 0),
                      child: GestureDetector(
                        child: Icon(
                          data.collect ? Icons.favorite : Icons.favorite_border,
                          color: data.collect
                              ? WColors.warning_red
                              : WColors.hint_color_dark,
                          size: pt(15),
                        ),
                        onTap: (){
                          print('click fav ${data.collect}');
                        },
                      ),
                    ))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class BannerModel {
  BannerModel(
    this.title,
    this.imagePath,
    this.url,
  );

  String title;
  String imagePath;
  String url;
}

class ProjectTypesModel {
  int id;
  String title;
  Widget icon;

  ProjectTypesModel(this.id, this.title, this.icon);
}
