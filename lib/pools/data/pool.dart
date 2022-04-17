import 'package:json_annotation/json_annotation.dart';

part 'pool.g.dart';

@JsonSerializable()
class Pool {
  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int creatorId;
  final String description;
  final bool isActive;
  final bool isDeleted;
  final List<int> postIds;
  final String creatorName;
  final int postCount;

  Pool({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.creatorId,
    required this.description,
    required this.isActive,
    required this.isDeleted,
    required this.postIds,
    required this.creatorName,
    required this.postCount,
  });

  factory Pool.fromJson(Map<String, dynamic> json) => _$PoolFromJson(json);

  Map<String, dynamic> toJson() => _$PoolToJson(this);
}
