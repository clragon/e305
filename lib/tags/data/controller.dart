import 'dart:io';

import 'package:e305/client/data/client.dart';
import 'package:e305/client/models/post.dart';
import 'package:e305/settings/data/settings.dart';
import 'package:e305/tags/data/post.dart';
import 'package:e305/tags/data/storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

final FavoriteDatabase favoriteDatabase = FavoriteDatabase();

class FavoriteDatabase extends DatabaseController {
  FavoriteDatabase() : super(name: 'favorites') {
    settings.credentials.addListener(reinitialize);
    settings.safe.addListener(reinitialize);
  }

  @override
  void dispose() {
    settings.credentials.removeListener(reinitialize);
    settings.safe.removeListener(reinitialize);
    super.dispose();
  }

  Future<void> reinitialize() async {
    database = null;
    await initialize();
    notifyListeners();
  }

  Future<void> initialize() async {
    if (super.path == null) {
      bool safe = await client.safe;
      super.path = [
        (await getApplicationSupportDirectory()).path,
        'favs_${safe ? 'e9' : 'e6'}.json'
      ].join('/');
    }
  }

  Future<List<Post>> provider(page) => client.favorites(page, limit: 200);

  Future<List<SlimPost>?> getFavorites() async {
    await initialize();
    try {
      if (await client.hasLogin) {
        await getDatabase(
          provide: provider,
        );
        if (database != null) {
          return database!.posts;
        }
      }
    } on DioError {
      return null;
    }
  }

  Future<List<SlimPost>?> refreshFavorites() async {
    await initialize();
    try {
      if (await client.hasLogin) {
        await recreate(provider);
        if (database != null) {
          return database!.posts;
        }
      }
    } on DioError {
      return null;
    }
  }
}

class DatabaseController with ChangeNotifier {
  static const Duration defaultStale = Duration(days: 7);

  final Duration? stale;
  final int limit;
  final String name;

  String? path;

  TagDataBase? database;

  DatabaseController({
    this.limit = 1200,
    this.stale = defaultStale,
    this.name = 'database',
    this.path,
  });

  Future<TagDataBase?> getDatabase(
      {String? path, PostProvider? provide}) async {
    if (database != null) {
      return database;
    }

    if (path != null) {
      this.path = path;
    }
    if (this.path == null) {
      throw StateError('no database path provided');
    }

    database = await load(this.path!);
    if (database != null) {
      return database;
    }

    if (provide != null) {
      database = await create(provide);
    }
    if (database != null) {
      return database;
    }
  }

  Future<TagDataBase?> load(String path) async {
    TagDataBase database;
    File file = File(path);
    if (file.existsSync()) {
      database = TagDataBase.read(path);
      if (stale == null ||
          database.creation.difference(DateTime.now()) < stale!) {
        notifyListeners();
        return database;
      } else {
        database.delete();
        notifyListeners();
      }
    }
  }

  Future<TagDataBase?> create(PostProvider provide) async {
    TagDataBase database = await TagDataBase.create(
        name: name, provide: provide, path: path, limit: limit);
    database.write();
    notifyListeners();
    return database;
  }

  Future<TagDataBase?> recreate(PostProvider provide) async {
    if (database != null) {
      database!.delete();
      database = null;
      notifyListeners();
    }
    return create(provide);
  }
}
