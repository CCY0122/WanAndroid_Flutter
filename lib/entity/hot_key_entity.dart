import 'package:json_annotation/json_annotation.dart';

part 'hot_key_entity.g.dart';


@JsonSerializable()
class HotKeyEntity extends Object {

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'link')
  String link;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'order')
  int order;

  @JsonKey(name: 'visible')
  int visible;

  HotKeyEntity(this.id,this.link,this.name,this.order,this.visible,);

  factory HotKeyEntity.fromJson(Map<String, dynamic> srcJson) => _$HotKeyEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$HotKeyEntityToJson(this);

}


