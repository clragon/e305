import 'package:e305/recommendations/data/score.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

@JsonSerializable()
class Post {
  final int id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final FileClass file;
  final Preview preview;
  final Sample sample;
  final Score score;
  final Map<String, List<String>> tags;
  final List<String> lockedTags;
  final int changeSeq;
  final Flags flags;
  final Rating rating;
  final int favCount;
  final List<String> sources;
  final List<int> pools;
  final Relationships relationships;
  final int? approverId;
  final int uploaderId;
  final String description;
  final int commentCount;
  bool isFavorited;
  final bool hasNotes;
  final double? duration;

  @JsonKey(ignore: true)
  bool? isBlacklisted;
  @JsonKey(ignore: true)
  double? recommendationValue;
  @JsonKey(ignore: true)
  List<ScoredTag>? recommendedTags;

  Post({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.file,
    required this.preview,
    required this.sample,
    required this.score,
    required this.tags,
    required this.lockedTags,
    required this.changeSeq,
    required this.flags,
    required this.rating,
    required this.favCount,
    required this.sources,
    required this.pools,
    required this.relationships,
    this.approverId,
    required this.uploaderId,
    required this.description,
    required this.commentCount,
    required this.isFavorited,
    required this.hasNotes,
    this.duration,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

  Map<String, dynamic> toJson() => _$PostToJson(this);
}

@JsonSerializable()
class FileClass {
  final int width;
  final int height;
  final String ext;
  final int size;
  final String md5;
  final String? url;

  FileClass({
    required this.width,
    required this.height,
    required this.ext,
    required this.size,
    required this.md5,
    this.url,
  });

  factory FileClass.fromJson(Map<String, dynamic> json) =>
      _$FileClassFromJson(json);

  Map<String, dynamic> toJson() => _$FileClassToJson(this);
}

@JsonSerializable()
class Flags {
  final bool pending;
  final bool flagged;
  final bool noteLocked;
  final bool statusLocked;
  final bool ratingLocked;
  final bool deleted;

  Flags({
    required this.pending,
    required this.flagged,
    required this.noteLocked,
    required this.statusLocked,
    required this.ratingLocked,
    required this.deleted,
  });

  factory Flags.fromJson(Map<String, dynamic> json) => _$FlagsFromJson(json);

  Map<String, dynamic> toJson() => _$FlagsToJson(this);
}

@JsonSerializable()
class Preview {
  int width;
  int height;
  String? url;

  Preview({
    required this.width,
    required this.height,
    required this.url,
  });

  factory Preview.fromJson(Map<String, dynamic> json) =>
      _$PreviewFromJson(json);

  Map<String, dynamic> toJson() => _$PreviewToJson(this);
}

enum Rating {
  @JsonValue('e')
  E,
  @JsonValue('q')
  Q,
  @JsonValue('s')
  S,
}

@JsonSerializable()
class Relationships {
  final int? parentId;
  final bool hasChildren;
  final bool hasActiveChildren;
  final List<int> children;

  Relationships({
    this.parentId,
    required this.hasChildren,
    required this.hasActiveChildren,
    required this.children,
  });

  factory Relationships.fromJson(Map<String, dynamic> json) =>
      _$RelationshipsFromJson(json);

  Map<String, dynamic> toJson() => _$RelationshipsToJson(this);
}

@JsonSerializable()
class Sample {
  final bool has;
  final int height;
  final int width;
  final String? url;

  Sample({
    required this.has,
    required this.height,
    required this.width,
    required this.url,
  });

  factory Sample.fromJson(Map<String, dynamic> json) => _$SampleFromJson(json);

  Map<String, dynamic> toJson() => _$SampleToJson(this);
}

@JsonSerializable()
class Original {
  final String type;
  final int height;
  final int width;
  final List<String> urls;

  Original({
    required this.type,
    required this.height,
    required this.width,
    required this.urls,
  });

  factory Original.fromJson(Map<String, dynamic> json) =>
      _$OriginalFromJson(json);

  Map<String, dynamic> toJson() => _$OriginalToJson(this);
}

@JsonSerializable()
class Score {
  final int up;
  final int down;
  final int total;

  Score({
    required this.up,
    required this.down,
    required this.total,
  });

  factory Score.fromJson(Map<String, dynamic> json) => _$ScoreFromJson(json);

  Map<String, dynamic> toJson() => _$ScoreToJson(this);
}
