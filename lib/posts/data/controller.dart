import 'package:e305/client/data/client.dart';
import 'package:e305/client/models/post.dart';
import 'package:e305/interface/data/paging.dart';
import 'package:e305/tags/data/post.dart';
import 'package:e305/tags/data/suggestions.dart';
import 'package:flutter/material.dart';

class PostController extends DataController<Post>
    with SearchableDataMixin, HostableDataMixin, RefreshableDataMixin {
  final ValueNotifier<String> search;

  PostController({String? search}) : this.search = ValueNotifier(search ?? '');

  @override
  Future<List<Post>> provide(int page) {
    return client.posts(search.value, page);
  }
}

class RecommendationController extends PostController {
  final ValueNotifier<String> search;
  final ValueNotifier<List<SlimPost>?> favs;
  final bool sort;

  RecommendationController(
      {String? search, List<SlimPost>? favs, this.sort = false})
      : this.search = ValueNotifier(search ?? ''),
        this.favs = ValueNotifier(favs);

  @override
  List<ValueNotifier> getRefreshListeners() =>
      super.getRefreshListeners()..add(favs);

  @override
  Future<List<Post>> provide(int page) async {
    List<Post> posts = await client.posts(search.value, page);
    if (favs.value != null) {
      Map<Post, double> scores =
          await ratePosts(favs.value!, posts, sort: sort);
      List<Post> scored = scores.entries.map((e) {
        e.key.recommendationValue = e.value;
        return e.key;
      }).toList();
      return scored;
    } else {
      return posts;
    }
  }
}

class FavoriteController extends PostController {
  @override
  Future<List<Post>> provide(int page) {
    return client.favorites(page);
  }
}
