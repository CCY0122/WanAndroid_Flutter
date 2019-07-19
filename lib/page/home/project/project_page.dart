import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:wanandroid_flutter/entity/banner_entity.dart';
import 'package:wanandroid_flutter/entity/project_entity.dart';
import 'package:wanandroid_flutter/entity/project_type_entity.dart';
import 'package:wanandroid_flutter/page/home/bloc/home_index.dart';
import 'package:wanandroid_flutter/page/home/project/bloc/project_index.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/utils/index.dart';
import 'package:wanandroid_flutter/views/flat_pagination.dart';

///项目主页，也是主页的第一个tab页
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
    projectTypes ??= [];
    projectDatas ??= [];
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
            return DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(pt(10)),
                  topRight: Radius.circular(pt(10)),
                ),
              ),
              child: CustomScrollView(
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
                    child: typesGridView(),
                  ),
                ],
              ),
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
    datas = [
      ProjectTypesModel(null, 'asd1', Icon(Icons.ac_unit,size: pt(35),)),
      ProjectTypesModel(null, 'asd2', Icon(Icons.ac_unit,size: pt(35),)),
      ProjectTypesModel(null, 'asd3', Icon(Icons.ac_unit,size: pt(35),)),
      ProjectTypesModel(null, 'asd4', Icon(Icons.ac_unit,size: pt(35),)),
      ProjectTypesModel(null, 'asd5', Icon(Icons.ac_unit,size: pt(35),)),
      ProjectTypesModel(null, 'asd6', Icon(Icons.ac_unit,size: pt(35),)),
      ProjectTypesModel(null, 'asd7', Icon(Icons.ac_unit,size: pt(35),)),
      ProjectTypesModel(null, 'asd8', Icon(Icons.ac_unit,size: pt(35),)),
      ProjectTypesModel(null, 'asd9', Icon(Icons.ac_unit,size: pt(35),)),
      ProjectTypesModel(null, 'asd10', Icon(Icons.ac_unit,size: pt(35),)),
      ProjectTypesModel(null, 'asd11', Icon(Icons.ac_unit,size: pt(35),)),
    ];

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
                    Text(data.title,style: TextStyle(color: WColors.hint_color_dark),),
                  ],
                ),
              );
            }).toList(),
          ),
          datas.length == 1
              ? Container()
              : Row(
                  children: Iterable.generate(datas.length - maxOneRowCount, (index) {
                    ProjectTypesModel data = datas[index + maxOneRowCount];
                    return Container(
                      alignment: Alignment.center,
                      width: itemWidth,
                      height: pt(75),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          data.icon,
                          Text(data.title,style: TextStyle(color: WColors.hint_color_dark),),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  ///项目item
  Widget projectItem(ProjectModel data){

  }

  @override
  bool get wantKeepAlive => true;
}

///--------一个开发习惯：json Bean（即XXXEntity）和UI Bean（即XXXModel）分离，UI层不直接拿json Bean来展示数据--------------

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

class ProjectModel{

}
