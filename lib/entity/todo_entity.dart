import 'package:json_annotation/json_annotation.dart';

part 'todo_entity.g.dart';

//生成命令：flutter packages pub run build_runner build
//        flutter packages pub run build_runner build --delete-conflicting-outputs

@JsonSerializable()
class TodoEntity extends Object {
  @JsonKey(name: 'completeDate')
  int completeDate;

  @JsonKey(name: 'completeDateStr')
  String completeDateStr;

  @JsonKey(name: 'content')
  String content;

  @JsonKey(name: 'date')
  int date;

  @JsonKey(name: 'dateStr')
  String dateStr;

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'priority')
  int priority;

  @JsonKey(name: 'status')
  int status;

  @JsonKey(name: 'title')
  String title;

  @JsonKey(name: 'type')
  int type;

  @JsonKey(name: 'userId')
  int userId;

  TodoEntity(
    this.completeDate,
    this.completeDateStr,
    this.content,
    this.date,
    this.dateStr,
    this.id,
    this.priority,
    this.status,
    this.title,
    this.type,
    this.userId,
  );

  factory TodoEntity.fromJson(Map<String, dynamic> srcJson) =>
      _$TodoEntityFromJson(srcJson);

  Map<String, dynamic> toJson() => _$TodoEntityToJson(this);

  @override
  String toString() {
    return 'TodoEntity{completeDate: $completeDate, completeDateStr: $completeDateStr, content: $content, date: $date, dateStr: $dateStr, id: $id, priority: $priority, status: $status, title: $title, type: $type, userId: $userId}';
  }
}
