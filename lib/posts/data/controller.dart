import 'package:e305/client/data/client.dart';
import 'package:e305/client/models/post.dart';
import 'package:e305/interface/data/paging.dart';
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

class FavoriteController extends PostController {
  @override
  Future<List<Post>> provide(int page) {
    return client.favorites(page);
  }
}
