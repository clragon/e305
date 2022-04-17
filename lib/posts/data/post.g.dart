// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      file: FileClass.fromJson(json['file'] as Map<String, dynamic>),
      preview: Preview.fromJson(json['preview'] as Map<String, dynamic>),
      sample: Sample.fromJson(json['sample'] as Map<String, dynamic>),
      score: Score.fromJson(json['score'] as Map<String, dynamic>),
      tags: (json['tags'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
      lockedTags: (json['locked_tags'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      changeSeq: json['change_seq'] as int,
      flags: Flags.fromJson(json['flags'] as Map<String, dynamic>),
      rating: $enumDecode(_$RatingEnumMap, json['rating']),
      favCount: json['fav_count'] as int,
      sources:
          (json['sources'] as List<dynamic>).map((e) => e as String).toList(),
      pools: (json['pools'] as List<dynamic>).map((e) => e as int).toList(),
      relationships:
          Relationships.fromJson(json['relationships'] as Map<String, dynamic>),
      approverId: json['approver_id'] as int?,
      uploaderId: json['uploader_id'] as int,
      description: json['description'] as String,
      commentCount: json['comment_count'] as int,
      isFavorited: json['is_favorited'] as bool,
      hasNotes: json['has_notes'] as bool,
      duration: (json['duration'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'file': instance.file,
      'preview': instance.preview,
      'sample': instance.sample,
      'score': instance.score,
      'tags': instance.tags,
      'locked_tags': instance.lockedTags,
      'change_seq': instance.changeSeq,
      'flags': instance.flags,
      'rating': _$RatingEnumMap[instance.rating],
      'fav_count': instance.favCount,
      'sources': instance.sources,
      'pools': instance.pools,
      'relationships': instance.relationships,
      'approver_id': instance.approverId,
      'uploader_id': instance.uploaderId,
      'description': instance.description,
      'comment_count': instance.commentCount,
      'is_favorited': instance.isFavorited,
      'has_notes': instance.hasNotes,
      'duration': instance.duration,
    };

const _$RatingEnumMap = {
  Rating.E: 'e',
  Rating.Q: 'q',
  Rating.S: 's',
};

FileClass _$FileClassFromJson(Map<String, dynamic> json) => FileClass(
      width: json['width'] as int,
      height: json['height'] as int,
      ext: json['ext'] as String,
      size: json['size'] as int,
      md5: json['md5'] as String,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$FileClassToJson(FileClass instance) => <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'ext': instance.ext,
      'size': instance.size,
      'md5': instance.md5,
      'url': instance.url,
    };

Flags _$FlagsFromJson(Map<String, dynamic> json) => Flags(
      pending: json['pending'] as bool,
      flagged: json['flagged'] as bool,
      noteLocked: json['note_locked'] as bool,
      statusLocked: json['status_locked'] as bool,
      ratingLocked: json['rating_locked'] as bool,
      deleted: json['deleted'] as bool,
    );

Map<String, dynamic> _$FlagsToJson(Flags instance) => <String, dynamic>{
      'pending': instance.pending,
      'flagged': instance.flagged,
      'note_locked': instance.noteLocked,
      'status_locked': instance.statusLocked,
      'rating_locked': instance.ratingLocked,
      'deleted': instance.deleted,
    };

Preview _$PreviewFromJson(Map<String, dynamic> json) => Preview(
      width: json['width'] as int,
      height: json['height'] as int,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$PreviewToJson(Preview instance) => <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'url': instance.url,
    };

Relationships _$RelationshipsFromJson(Map<String, dynamic> json) =>
    Relationships(
      parentId: json['parent_id'] as int?,
      hasChildren: json['has_children'] as bool,
      hasActiveChildren: json['has_active_children'] as bool,
      children:
          (json['children'] as List<dynamic>).map((e) => e as int).toList(),
    );

Map<String, dynamic> _$RelationshipsToJson(Relationships instance) =>
    <String, dynamic>{
      'parent_id': instance.parentId,
      'has_children': instance.hasChildren,
      'has_active_children': instance.hasActiveChildren,
      'children': instance.children,
    };

Sample _$SampleFromJson(Map<String, dynamic> json) => Sample(
      has: json['has'] as bool,
      height: json['height'] as int,
      width: json['width'] as int,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$SampleToJson(Sample instance) => <String, dynamic>{
      'has': instance.has,
      'height': instance.height,
      'width': instance.width,
      'url': instance.url,
    };

Original _$OriginalFromJson(Map<String, dynamic> json) => Original(
      type: json['type'] as String,
      height: json['height'] as int,
      width: json['width'] as int,
      urls: (json['urls'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$OriginalToJson(Original instance) => <String, dynamic>{
      'type': instance.type,
      'height': instance.height,
      'width': instance.width,
      'urls': instance.urls,
    };

Score _$ScoreFromJson(Map<String, dynamic> json) => Score(
      up: json['up'] as int,
      down: json['down'] as int,
      total: json['total'] as int,
    );

Map<String, dynamic> _$ScoreToJson(Score instance) => <String, dynamic>{
      'up': instance.up,
      'down': instance.down,
      'total': instance.total,
    };
