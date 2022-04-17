import 'dart:math';

import 'package:e305/client/data/client.dart';
import 'package:e305/posts/data/post.dart';
import 'package:e305/interface/data/controller.dart';
import 'package:e305/recommendations/data/suggestions.dart';
import 'package:e305/tags/data/post.dart';
import 'package:flutter/material.dart';

class PostController extends DataController<Post>
    with
        SearchableDataMixin,
        HostableDataMixin,
        RefreshableDataMixin,
        DeniableDataMixin {
  @override
  final ValueNotifier<String> search;

  PostController({String? search}) : search = ValueNotifier(search ?? '');

  @override
  Future<List<Post>> provide(int page) {
    return client.posts(search.value, page);
  }
}

class RecommendationController extends PostController {
  @override
  final ValueNotifier<String> search;
  final ValueNotifier<List<SlimPost>?> favs;
  final bool sort;

  RecommendationController(
      {String? search, List<SlimPost>? favs, this.sort = false})
      : search = ValueNotifier(search ?? ''),
        favs = ValueNotifier(favs);

  @override
  List<ValueNotifier> getRefreshListeners() =>
      super.getRefreshListeners()..add(favs);

  @override
  Future<List<Post>> provide(int page) async {
    List<Post> posts = await client.posts(search.value, page);
    if (favs.value != null) {
      await ratePosts(favs.value!, posts);
      if (sort) {
        posts.sort(
          (a, b) => b.recommendationValue!.compareTo(a.recommendationValue!),
        );
      }
    }
    return posts;
  }
}

extension Scores on RecommendationController {
  double maxScore() {
    double maxScore = 0;
    if (itemList != null) {
      for (Post post in itemList!) {
        maxScore = max(post.recommendationValue!, maxScore);
      }
    }
    return maxScore;
  }
}

class FavoriteController extends PostController {
  @override
  Future<List<Post>> provide(int page) {
    return client.favorites(page);
  }
}
