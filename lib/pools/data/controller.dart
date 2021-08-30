import 'package:e305/client/data/client.dart';
import 'package:e305/client/models/pool.dart';
import 'package:e305/client/models/post.dart';
import 'package:e305/interface/data/controller.dart';
import 'package:e305/posts/data/controller.dart';
import 'package:flutter/material.dart';

class PoolController extends DataController<Pool>
    with SearchableDataMixin, HostableDataMixin, RefreshableDataMixin {
  final ValueNotifier<String> search;

  PoolController({String? search}) : this.search = ValueNotifier(search ?? '');

  @override
  Future<List<Pool>> provide(int page) => client.pools(
        page,
        search: search.value,
      );
}

class PoolPostController extends PostController {
  final Pool pool;

  PoolPostController({required this.pool});

  @override
  Future<List<Post>> provide(int page) => client.poolPosts(pool, page);
}
