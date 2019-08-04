import 'package:data_plugin/bmob/table/bmob_object.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bmob_update_entity.g.dart';

@JsonSerializable()
class BmobUpdateEntity extends BmobObject {
  int deviceType; //1:android
  String versionName;
  String updateMsg;
  String downloadUrl;

  BmobUpdateEntity(
      this.deviceType, this.versionName, this.updateMsg, this.downloadUrl);

  BmobUpdateEntity.empty();

  factory BmobUpdateEntity.fromJson(Map<String, dynamic> json) =>
      _$BmobUpdateEntityFromJson(json);

  Map<String, dynamic> toJson() => _$BmobUpdateEntityToJson(this);

  @override
  Map getParams() {
    return toJson();
  }

  @override
  String toString() {
    return 'BmobUpdateEntity{deviceType: $deviceType, versionName: $versionName, updateMsg: $updateMsg, downloadUrl: $downloadUrl}';
  }


}
