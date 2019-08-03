import 'package:json_annotation/json_annotation.dart';

part 'collect_web_entity.g.dart';


@JsonSerializable()
class CollectWebEntity extends Object {

  @JsonKey(name: 'desc')
  String desc;

  @JsonKey(name: 'icon')
  String icon;

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'link')
  String link;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'order')
  int order;

  @JsonKey(name: 'userId')
  int userId;

  @JsonKey(name: 'visible')
  int visible;

  CollectWebEntity(this.desc,this.icon,this.id,this.link,this.name,this.order,this.userId,this.visible,);

  factory CollectWebEntity.fromJson(Map<String, dynamic> srcJson) => _$CollectWebEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$CollectWebEntityToJson(this);

}


