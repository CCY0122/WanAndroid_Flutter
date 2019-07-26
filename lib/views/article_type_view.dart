import 'package:flutter/material.dart';
import 'package:wanandroid_flutter/entity/article_type_entity.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/utils/index.dart';

class ArticleTypeView {
  ///折叠时的type view
  static Widget collaspTypesView({
    @required Key key,
    @required List<ArticleTypeEntity> types,
    @required int selectId,
    @required VoidCallback onExpanded,
    @required ValueChanged<int> onSelected,
    ScrollController collaspTypeScrollController,
  }) {
    return Row(
      key: key,
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            controller: collaspTypeScrollController,
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                types.length,
                (index) {
                  return typeItem(
                    id: types[index].id,
                    name: types[index].name,
                    selected: types[index].id == selectId,
                    onSelected: onSelected,
                  );
                },
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            onExpanded();
          },
          child: Container(
            width: pt(30),
            height: pt(30),
            child: Icon(
              Icons.keyboard_arrow_down,
              size: pt(30),
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  ///展开时的type view
  static Widget expandedTypesView({
    @required List<ArticleTypeEntity> types,
    @required int selectId,
    @required VoidCallback onExpanded,
    @required ValueChanged<int> onSelected,
  }) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
        colors: [
          WColors.theme_color,
          WColors.theme_color_light,
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      )),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Wrap(
              children: List.generate(
                types.length,
                (index) {
                  return typeItem(
                    id: types[index].id,
                    name: types[index].name,
                    selected: types[index].id == selectId,
                    onSelected: onSelected,
                  );
                },
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              onExpanded();
            },
            child: Container(
              width: pt(30),
              height: pt(30),
              child: Icon(
                Icons.keyboard_arrow_up,
                size: pt(30),
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///type 单元
  static Widget typeItem({
    @required int id,
    @required String name,
    @required bool selected,
    @required ValueChanged<int> onSelected,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: pt(8), horizontal: pt(2)),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          //只可选中，不可取消
          if (!selected) {
            onSelected(id);
          }
        },
        child: Container(
          height: pt(28),
          padding: EdgeInsets.symmetric(horizontal: pt(4)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: selected ? Border.all(color: Colors.white) : null,
          ),
          // 这里为什么用stack呢？因为我想让child居中。
          // 那居中为什么不直接给父container设置alignment呢？因为这会使Container约束变尽可能大，
          // 导致width占满剩余空间（height已经固定给了pt(28)，而width我不希望给固定值，它应当根据文字长度自动调整），
          // 最终导致expandedTypesView中的wrap是一行一个typeItem。所以换用stack来实现文字居中。
          // 如果你还不理解，去掉stack，给Container加上Alignment.center，运行看效果。
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                name,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
