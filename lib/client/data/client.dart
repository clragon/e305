import 'dart:async' show Future;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e305/comments/data/comment.dart';
import 'package:e305/pools/data/pool.dart';
import 'package:e305/posts/data/post.dart';
import 'package:e305/posts/data/blacklist.dart';
import 'package:e305/settings/data/info.dart';
import 'package:e305/settings/data/settings.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'credentials.dart';

export 'package:dio/dio.dart' show DioError;
export 'package:e305/client/data/credentials.dart';

final Client client = Client();

class Client {
  late Dio dio;

  late Future<bool> initialized;

  Client() {
    settings.credentials.addListener(initialize);
    settings.safe.addListener(initialize);
    initialize();
  }

  bool get isSafe => settings.safe.value;
  String get host => isSafe ? 'e926.net' : 'e621.net';

  Future<bool> initialize() async {
    return await (initialized = Future(
      () async {
        _avatar = null;
        Credentials? credentials = settings.credentials.value;
        dio = Dio(
          BaseOptions(
            baseUrl: 'https://$host/',
            sendTimeout: 30000,
            connectTimeout: 30000,
            headers: {
              HttpHeaders.userAgentHeader:
                  '$appName/${(await PackageInfo.fromPlatform()).version} ($developer)',
            },
          ),
        );
        if (credentials != null) {
          dio.options.headers[HttpHeaders.authorizationHeader] =
              credentials.toAuth();
          try {
            await tryLogin(credentials);
          } on DioError catch (e) {
            if (e.type != DioErrorType.other) {
              logout();
            }
          }
          return true;
        } else {
          return false;
        }
      },
    ));
  }

  Future<void> tryLogin(Credentials credentials) async {
    await dio.get(
      'favorites.json',
      options: Options(headers: {
        HttpHeaders.authorizationHeader: credentials.toAuth(),
      }),
    );
  }

  Future<bool> saveLogin(Credentials credentials) async {
    if (await validateCall(() => tryLogin(credentials))) {
      settings.credentials.value = credentials;
      return true;
    } else {
      return false;
    }
  }

  Future<bool> get hasLogin async {
    await initialized;
    return settings.credentials.value != null;
  }

  Future<void> logout() async {
    settings.credentials.value = null;
  }

  String? _avatar;

  Future<String?> get avatar async {
    if (_avatar == null) {
      if (settings.credentials.value == null) {
        return null;
      }
      int postId = (await client
          .user(settings.credentials.value!.username))['avatar_id'];
      Post post = await client.post(postId);
      _avatar = post.sample.url;
    }
    return _avatar;
  }

  Future<List<Post>?> postsFromJson(List json) async {
    List<String> blacklist = settings.blacklist.value;
    bool blacklisting = settings.blacklisting.value;
    List<Post> posts = [];
    bool hasPosts = false;
    for (Map<String, dynamic> raw in json) {
      hasPosts = true;
      Post post = Post.fromJson(raw);
      if (post.file.url == null && !post.flags.deleted) {
        continue;
      }
      if (['webm', 'mp4', 'swf'].contains(post.file.ext)) {
        continue;
      }
      if (blacklisting) {
        post.isBlacklisted = isBlacklisted(blacklist, post);
      }
      posts.add(post);
    }
    if (hasPosts && posts.isEmpty) {
      return null;
    }
    return posts;
  }

  Future<List<Post>> posts(String tags, int page, {int? limit}) async {
    await initialized;
    Map body = await dio.get(
      'posts.json',
      queryParameters: {
        'tags': tags,
        'page': page,
        'limit': limit,
      },
    ).then((response) => response.data);

    List<Post>? posts = await postsFromJson(body['posts']);
    posts?.removeWhere((post) => post.isBlacklisted ?? false);
    return posts ?? [];
  }

  Future<Post> post(int postID, {bool unsafe = false}) async {
    await initialized;
    Map body = await dio
        .get('https://${client.host}/posts/${postID.toString()}.json',
            options: Options())
        .then((response) => response.data);

    Post post = Post.fromJson(body['post']);
    return post;
  }

  Future<List<Post>> favorites(int page, {int? limit}) async {
    await initialized;

    Map body = await dio.get(
      'favorites.json',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    ).then((response) => response.data);

    return (await postsFromJson(body['posts'])) ?? [];
  }

  Future<bool> addFavorite(int post) async {
    if (!await hasLogin) {
      return false;
    }
    return validateCall(
      () => dio.post('favorites.json', queryParameters: {
        'post_id': post,
      }),
    );
  }

  Future<bool> removeFavorite(int post) async {
    if (!await hasLogin) {
      return false;
    }

    return validateCall(
      () => dio.delete('favorites/${post.toString()}.json'),
    );
  }

  Future<bool> votePost(int post, bool upvote, bool replace) async {
    if (!await hasLogin) {
      return false;
    }

    return validateCall(
      () => dio.post('posts/${post.toString()}/votes.json', queryParameters: {
        'score': upvote ? 1 : -1,
        'no_unvote': replace,
      }),
    );
  }

  Future<Map<String, dynamic>> user(String name) async {
    await initialized;
    Map<String, dynamic> body =
        await dio.get('users/$name.json').then((response) => response.data);

    return body;
  }

  Future<List<Comment>> comments(int postID, String page) async {
    dynamic body = await dio.get('comments.json', queryParameters: {
      'group_by': 'comment',
      'search[post_id]': '$postID',
      'page': page,
    }).then((response) => response.data);

    List<Comment> comments = [];
    if (body is List<dynamic>) {
      for (Map<String, dynamic> raw in body) {
        comments.add(Comment.fromJson(raw));
      }
    }

    return comments;
  }

  Future<List<Pool>> pools(int page, {String? search}) async {
    List<dynamic> body = await dio.get('pools.json', queryParameters: {
      'search[name_matches]': search,
      'page': page,
    }).then((response) => response.data);

    List<Pool> pools = [];
    for (final raw in body) {
      Pool pool = Pool.fromJson(raw);
      pools.add(pool);
    }

    return pools;
  }

  Future<Pool> pool(int poolId) async {
    Map<String, dynamic> body =
        await dio.get('pools/$poolId.json').then((response) => response.data);

    return Pool.fromJson(body);
  }

  Future<List<Post>> poolPosts(Pool pool, int page) async {
    int limit = 80;
    int lower = ((page - 1) * limit);
    int upper = lower + limit;

    if (pool.postIds.length < lower) {
      return [];
    }
    if (pool.postIds.length < upper) {
      upper = pool.postIds.length;
    }

    List<int> ids = pool.postIds.sublist(lower, upper);
    String filter = 'id:${ids.join(',')}';

    List<Post> posts = await client.posts(filter, 1);
    Map<int, Post> table = {for (final e in posts) e.id: e};
    posts = ids.fold<List<Post>>(
      [],
      (previousValue, element) => table[element] != null
          ? (previousValue..add(table[element]!))
          : previousValue,
    );
    return posts;
  }
}

Future<bool> validateCall(Future<void> Function() call) async {
  try {
    await call();
    return true;
  } on DioError {
    return false;
  }
}
