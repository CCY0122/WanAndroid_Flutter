import 'package:data_plugin/bmob/table/bmob_object.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bmob_user_entity.g.dart';

@JsonSerializable()
class BmobUserEntity extends BmobObject {
  String userName; //用户名
  String signature; //个性签名
  int level; //等级

  //预留
  String strWhat;
  double numWhat;

  BmobUserEntity(this.userName, this.signature, this.level, this.strWhat,
      this.numWhat);

  BmobUserEntity.empty();

  BmobUserEntity copyWith({userName, signature, level, strWhat, numWhat}) {
    BmobUserEntity copy = BmobUserEntity(userName ?? this.userName, signature ?? this.signature,
      level ?? this.level, strWhat ?? this.strWhat, numWhat ?? this.numWhat,);
    copy.objectId = this.objectId;
    copy.updatedAt = this.updatedAt;
    copy.createdAt = this.createdAt;
    copy.ACL = this.ACL;
    return copy;
  }

  factory BmobUserEntity.fromJson(Map<String, dynamic> json) =>
      _$BmobUserEntityFromJson(json);

  Map<String, dynamic> toJson() => _$BmobUserEntityToJson(this);

  @override
  Map getParams() {
    return toJson();
  }
}
