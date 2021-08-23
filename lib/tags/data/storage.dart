import 'dart:convert';
import 'dart:io';

import 'package:e305/client/models/post.dart';

class TagDataBase {
  TagDataBase({
    required this.creation,
    required this.search,
    required this.tags,
  });

  DateTime creation;
  String search;
  List<SlimPost> tags;
  String? file;

  factory TagDataBase.fromJson(String str) =>
      TagDataBase.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory TagDataBase.fromMap(Map<String, dynamic> json) => TagDataBase(
        search: json["search"],
        tags: List<SlimPost>.from(json["tags"].map((x) => SlimPost.fromMap(x))),
        creation: DateTime.parse(json["creation"]),
      );

  Map<String, dynamic> toMap() => {
        "search": search,
        "tags": List<dynamic>.from(tags.map((x) => x.toMap())),
        "creation": creation.toIso8601String(),
      };

  factory TagDataBase.read(File data) {
    return TagDataBase.fromJson(data.readAsStringSync())..file = data.path;
  }

  Future<TagDataBase> create({
    String search = '',
    required Future<List<Post>> Function(String search, int page) provide,
    int limit = 6,
  }) async {
    List<SlimPost> slims = [];
    for (int i = 1; i <= limit; i++) {
      List<SlimPost> posts = (await provide(search, i)).toSlims();
      if (posts.isEmpty) {
        break;
      }
      slims.addAll(posts);
      await Future.delayed(Duration(milliseconds: 500));
    }
    return TagDataBase(creation: DateTime.now(), search: search, tags: slims);
  }

  void write() {
    if (file != null) {
      JsonEncoder encoder = JsonEncoder.withIndent(" " * 2);
      File(file!).writeAsStringSync(encoder.convert(toJson()));
    } else {
      throw StateError('database doesnt have file');
    }
  }

  void delete() {
    if (file != null) {
      File(file!).deleteSync();
    } else {
      throw StateError('database doesnt have file');
    }
  }
}

class SlimPost {
  SlimPost({
    required this.id,
    required this.tags,
  });

  int id;
  Map<String, List<String>> tags;

  factory SlimPost.fromPost(Post post) =>
      SlimPost(id: post.id, tags: post.tags);

  factory SlimPost.fromJson(String str) => SlimPost.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SlimPost.fromMap(Map json) => SlimPost(
        id: json['id'],
        tags: Map<String, dynamic>.from(json['tags']).map((key, value) =>
            MapEntry<String, List<String>>(key, List<String>.from(value))),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'tags': tags,
      };
}

extension slims on List<Post> {
  List<SlimPost> toSlims() => this.map((e) => SlimPost.fromPost(e)).toList();
}
