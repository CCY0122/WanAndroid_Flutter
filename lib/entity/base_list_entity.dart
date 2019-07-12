class BaseListEntity<T> {
  int curPage;
  T datas;
  int offset;
  bool over;
  int pageCount;
  int size;
  int total;

  BaseListEntity(
      {this.curPage,
      this.datas,
      this.offset,
      this.over,
      this.pageCount,
      this.size,
      this.total});

  BaseListEntity.fromJson(Map<String, dynamic> json) {
    curPage = json['curPage'];
    if (json['datas'] != null) {
      datas = json['datas'];
    }
    offset = json['offset'];
    over = json['over'];
    pageCount = json['pageCount'];
    size = json['size'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['curPage'] = this.curPage;
    //泛型成员手动put进去
//    if (this.datas != null) {
//      data['datas'] = this.datas.map((v) => v.toJson()).toList();
//    }
    data['offset'] = this.offset;
    data['over'] = this.over;
    data['pageCount'] = this.pageCount;
    data['size'] = this.size;
    data['total'] = this.total;
    return data;
  }

  @override
  String toString() {
    return 'BaseListEntity{curPage: $curPage, datas: $datas, offset: $offset, over: $over, pageCount: $pageCount, size: $size, total: $total}';
  }


}
