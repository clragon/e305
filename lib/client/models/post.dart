import 'dart:convert';

import 'package:e305/recommendations/data/score.dart';

class Post {
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

  int id;
  DateTime createdAt;
  DateTime? updatedAt;
  FileClass file;
  Preview preview;
  Sample sample;
  Score score;
  Map<String, List<String>> tags;
  List<String> lockedTags;
  int changeSeq;
  Flags flags;
  Rating rating;
  int favCount;
  List<String> sources;
  List<int> pools;
  Relationships relationships;
  int? approverId;
  int uploaderId;
  String description;
  int commentCount;
  bool isFavorited;
  bool hasNotes;
  double? duration;

  double? recommendationValue;
  List<ScoredTag>? recommendedTags;

  factory Post.fromJson(String str) => Post.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Post.fromMap(Map json) => Post(
        id: json["id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        file: FileClass.fromMap(json["file"]),
        preview: Preview.fromMap(json["preview"]),
        sample: Sample.fromMap(json["sample"]),
        score: Score.fromMap(json["score"]),
        tags: Map<String, dynamic>.from(json['tags']).map((key, value) =>
            MapEntry<String, List<String>>(key, List<String>.from(value))),
        lockedTags: List<String>.from(json["locked_tags"].map((x) => x)),
        changeSeq: json["change_seq"],
        flags: Flags.fromMap(json["flags"]),
        rating: ratingValues.map[json["rating"]]!,
        favCount: json["fav_count"],
        sources: List<String>.from(json["sources"].map((x) => x)),
        pools: List<int>.from(json["pools"].map((x) => x)),
        relationships: Relationships.fromMap(json["relationships"]),
        approverId: json["approver_id"] == null ? null : json["approver_id"],
        uploaderId: json["uploader_id"],
        description: json["description"],
        commentCount: json["comment_count"],
        isFavorited: json["is_favorited"],
        hasNotes: json["has_notes"],
        duration: json["duration"] == null ? null : json["duration"].toDouble(),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "file": file.toMap(),
        "preview": preview.toMap(),
        "sample": sample.toMap(),
        "score": score.toMap(),
        "tags": tags,
        "locked_tags": List<dynamic>.from(lockedTags.map((x) => x)),
        "change_seq": changeSeq,
        "flags": flags.toMap(),
        "rating": ratingValues.reverse![rating],
        "fav_count": favCount,
        "sources": List<dynamic>.from(sources.map((x) => x)),
        "pools": List<dynamic>.from(pools.map((x) => x)),
        "relationships": relationships.toMap(),
        "approver_id": approverId,
        "uploader_id": uploaderId,
        "description": description,
        "comment_count": commentCount,
        "is_favorited": isFavorited,
        "has_notes": hasNotes,
        "duration": duration,
      };
}

class FileClass {
  FileClass({
    required this.width,
    required this.height,
    required this.ext,
    required this.size,
    required this.md5,
    this.url,
  });

  int width;
  int height;
  String ext;
  int size;
  String md5;
  String? url;

  factory FileClass.fromJson(String str) => FileClass.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory FileClass.fromMap(Map<String, dynamic> json) => FileClass(
        width: json["width"],
        height: json["height"],
        ext: json["ext"],
        size: json["size"],
        md5: json["md5"],
        url: json["url"],
      );

  Map<String, dynamic> toMap() => {
        "width": width,
        "height": height,
        "ext": ext,
        "size": size,
        "md5": md5,
        "url": url,
      };
}

class Flags {
  Flags({
    required this.pending,
    required this.flagged,
    required this.noteLocked,
    required this.statusLocked,
    required this.ratingLocked,
    required this.deleted,
  });

  bool pending;
  bool flagged;
  bool noteLocked;
  bool statusLocked;
  bool ratingLocked;
  bool deleted;

  factory Flags.fromJson(String str) => Flags.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Flags.fromMap(Map<String, dynamic> json) => Flags(
        pending: json["pending"],
        flagged: json["flagged"],
        noteLocked: json["note_locked"],
        statusLocked: json["status_locked"],
        ratingLocked: json["rating_locked"],
        deleted: json["deleted"],
      );

  Map<String, dynamic> toMap() => {
        "pending": pending,
        "flagged": flagged,
        "note_locked": noteLocked,
        "status_locked": statusLocked,
        "rating_locked": ratingLocked,
        "deleted": deleted,
      };
}

class Preview {
  Preview({
    required this.width,
    required this.height,
    required this.url,
  });

  int width;
  int height;
  String? url;

  factory Preview.fromJson(String str) => Preview.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Preview.fromMap(Map<String, dynamic> json) => Preview(
        width: json["width"],
        height: json["height"],
        url: json["url"],
      );

  Map<String, dynamic> toMap() => {
        "width": width,
        "height": height,
        "url": url,
      };
}

enum Rating { E, S, Q }

final ratingValues = EnumValues({"e": Rating.E, "q": Rating.Q, "s": Rating.S});

class Relationships {
  Relationships({
    this.parentId,
    required this.hasChildren,
    required this.hasActiveChildren,
    required this.children,
  });

  int? parentId;
  bool hasChildren;
  bool hasActiveChildren;
  List<int> children;

  factory Relationships.fromJson(String str) =>
      Relationships.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Relationships.fromMap(Map<String, dynamic> json) => Relationships(
        parentId: json["parent_id"] == null ? null : json["parent_id"],
        hasChildren: json["has_children"],
        hasActiveChildren: json["has_active_children"],
        children: List<int>.from(json["children"].map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "parent_id": parentId == null ? null : parentId,
        "has_children": hasChildren,
        "has_active_children": hasActiveChildren,
        "children": List<dynamic>.from(children.map((x) => x)),
      };
}

class Sample {
  Sample({
    required this.has,
    required this.height,
    required this.width,
    required this.url,
  });

  bool has;
  int height;
  int width;
  String? url;

  factory Sample.fromJson(String str) => Sample.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Sample.fromMap(Map<String, dynamic> json) => Sample(
        has: json["has"],
        height: json["height"],
        width: json["width"],
        url: json["url"],
      );

  Map<String, dynamic> toMap() => {
        "has": has,
        "height": height,
        "width": width,
        "url": url,
      };
}

class Original {
  Original({
    required this.type,
    required this.height,
    required this.width,
    required this.urls,
  });

  String type;
  int height;
  int width;
  List<String> urls;

  factory Original.fromJson(String str) => Original.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Original.fromMap(Map<String, dynamic> json) => Original(
        type: json["type"],
        height: json["height"],
        width: json["width"],
        urls: List<String>.from(json["urls"].map((x) => x == null ? null : x)),
      );

  Map<String, dynamic> toMap() => {
        "type": type,
        "height": height,
        "width": width,
        "urls": List<String>.from(urls.map((x) => x)),
      };
}

class Score {
  Score({
    required this.up,
    required this.down,
    required this.total,
  });

  int up;
  int down;
  int total;

  factory Score.fromJson(String str) => Score.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Score.fromMap(Map<String, dynamic> json) => Score(
        up: json["up"],
        down: json["down"],
        total: json["total"],
      );

  Map<String, dynamic> toMap() => {
        "up": up,
        "down": down,
        "total": total,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String>? reverseMap;

  EnumValues(this.map);

  Map<T, String>? get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
