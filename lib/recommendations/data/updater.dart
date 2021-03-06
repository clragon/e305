import 'dart:io';

import 'package:e305/client/data/client.dart';
import 'package:e305/interface/data/updater.dart';
import 'package:e305/recommendations/data/storage.dart';
import 'package:e305/settings/data/settings.dart';
import 'package:e305/tags/data/post.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

final Recommendations recommendations = Recommendations();

class Recommendations extends DatabaseUpdater {
  final int required = 200;

  @override
  Duration? get stale => const Duration(days: 14);

  Future<void> updateCredentials() async {
    delete();
    return refresh();
  }

  Future<void> updateHost() async {
    database.value = null;
    return refresh();
  }

  Recommendations() : super(name: 'favorites', limit: 1200) {
    settings.credentials.addListener(updateCredentials);
    settings.safe.addListener(updateHost);
  }

  @override
  void dispose() {
    settings.credentials.removeListener(updateCredentials);
    settings.safe.removeListener(updateHost);
    super.dispose();
  }

  @override
  Future<String> get path async {
    bool safe = client.isSafe;
    return [
      (await getApplicationSupportDirectory()).path,
      'favs_${safe ? 'e9' : 'e6'}.json'
    ].join('/');
  }

  @override
  PostProvider get provide => (page) async {
        try {
          return await client.favorites(page, limit: 200);
        } on DioError {
          return [];
        }
      };

  @override
  List<ValueNotifier> getRefreshListeners() =>
      super.getRefreshListeners()..add(settings.credentials);

  Future<List<SlimPost>?> getFavorites() async => (await getDatabase())?.posts;
}

abstract class DatabaseUpdater extends DataUpdater<TagDataBase?> {
  static const Duration defaultStale = Duration(days: 7);

  final int limit;
  final String name;

  final ValueNotifier<TagDataBase?> database = ValueNotifier(null);

  @override
  Duration? get stale => defaultStale;
  Future<String> get path;
  PostProvider get provide;

  DatabaseUpdater({
    this.limit = 1200,
    this.name = 'database',
  });

  Future<TagDataBase?> getDatabase() async {
    await update();
    return database.value;
  }

  Future<TagDataBase> create(List<SlimPost> slims) async {
    return TagDataBase.create(
        name: name, tags: slims, path: await path, limit: limit);
  }

  Future<TagDataBase?> recreate() async {
    delete();
    return getDatabase();
  }

  void delete() {
    database.value?.delete();
    database.value = null;
  }

  @override
  Future<TagDataBase?> read() async {
    if (await path == '') {
      throw StateError('no database path provided');
    }

    bool outdated(TagDataBase database) =>
        stale != null && database.creation.difference(DateTime.now()) > stale!;

    TagDataBase? database = this.database.value;
    if (database != null && outdated(database)) {
      delete();
      return null;
    }

    if (database == null) {
      File file = File(await path);
      if (file.existsSync()) {
        TagDataBase database = TagDataBase.read(await path);
        if (stale != null && outdated(database)) {
          database.delete();
          return null;
        }
        return database;
      }
    }
    return database;
  }

  @override
  Future<void> write(TagDataBase? data) async {
    data?.write();
    database.value = data;
  }

  @override
  Future<TagDataBase?> run(
      TagDataBase? data, StepCallback step, bool force) async {
    if (data == null) {
      List<SlimPost> slims = [];
      for (int i = 1; true; i++) {
        List<SlimPost> posts;
        try {
          posts = (await provide(i)).toSlims();
          if (posts.isEmpty) {
            break;
          }
          slims.addAll(posts);
          if (slims.length >= limit) {
            break;
          }
          if (!step(slims.length)) {
            return null;
          }
          await Future.delayed(const Duration(milliseconds: 500));
        } catch (_) {
          if (kDebugMode) {
            rethrow;
          }
          fail();
          return null;
        }
      }
      data = await create(slims);
    }
    return data;
  }
}
