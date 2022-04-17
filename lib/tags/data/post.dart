import 'dart:convert';

import 'package:e305/posts/data/post.dart';

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

extension Slims on List<Post> {
  List<SlimPost> toSlims() => map((e) => SlimPost.fromPost(e)).toList();
}
