import 'package:json_annotation/json_annotation.dart';

part 'comment.g.dart';

@JsonSerializable()
class Comment {
  final int id;
  final DateTime createdAt;
  final int postId;
  final int creatorId;
  final String body;
  final int score;
  final DateTime updatedAt;
  final int updaterId;
  final bool doNotBumpPost;
  final bool isHidden;
  final bool isSticky;
  final String creatorName;
  final String updaterName;

  Comment({
    required this.id,
    required this.createdAt,
    required this.postId,
    required this.creatorId,
    required this.body,
    required this.score,
    required this.updatedAt,
    required this.updaterId,
    required this.doNotBumpPost,
    required this.isHidden,
    required this.isSticky,
    required this.creatorName,
    required this.updaterName,
  });

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);

  Map<String, dynamic> toJson() => _$CommentToJson(this);
}
