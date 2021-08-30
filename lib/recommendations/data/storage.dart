import 'dart:convert';
import 'dart:io';

import 'package:e305/client/models/post.dart';
import 'package:e305/tags/data/post.dart';

typedef PostProvider = Future<List<Post>> Function(int page);

class TagDataBase {
  TagDataBase({
    required this.creation,
    required this.name,
    required this.posts,
    this.path,
  });

  String name;
  DateTime creation;
  List<SlimPost> posts;
  String? path;

  factory TagDataBase.fromJson(String str) =>
      TagDataBase.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory TagDataBase.fromMap(Map<String, dynamic> json) => TagDataBase(
        name: json["name"],
        posts:
            List<SlimPost>.from(json["tags"].map((x) => SlimPost.fromMap(x))),
        creation: DateTime.parse(json["creation"]),
      );

  Map<String, dynamic> toMap() => {
        "name": name,
        "tags": List<dynamic>.from(posts.map((x) => x.toMap())),
        "creation": creation.toIso8601String(),
      };

  factory TagDataBase.read(String path) {
    return TagDataBase.fromJson(File(path).readAsStringSync())..path = path;
  }

  factory TagDataBase.create({
    String name = '',
    required List<SlimPost> tags,
    String? path,
    int limit = 1200,
  }) =>
      TagDataBase(
          creation: DateTime.now(), name: name, posts: tags, path: path);

  void write() {
    if (path != null) {
      JsonEncoder encoder = JsonEncoder.withIndent(" " * 2);
      File(path!).writeAsStringSync(encoder.convert(toMap()));
    } else {
      throw StateError('no database file path specified');
    }
  }

  void delete() {
    if (path != null) {
      File(path!).deleteSync();
    } else {
      throw StateError('no database file path specified');
    }
  }
}
