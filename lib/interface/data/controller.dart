import 'package:e305/client/data/client.dart';
import 'package:e305/settings/data/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mutex/mutex.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

abstract class DataController<T> extends PagingController<int, T> {
  @override
  final int firstPageKey;
  final Mutex requestLock = Mutex();
  bool isRefreshing = false;

  DataController({
    this.firstPageKey = 1,
  }) : super(firstPageKey: firstPageKey) {
    super.addPageRequestListener(requestPage);
    getRefreshListeners().forEach((element) => element.addListener(refresh));
  }

  @override
  void dispose() {
    super.removePageRequestListener(requestPage);
    getRefreshListeners().forEach((element) => element.removeListener(refresh));
    super.dispose();
  }

  @mustCallSuper
  void failure(Exception error) {
    this.error = error;
  }

  @mustCallSuper
  void success() {}

  Future<List<T>?> catchError(Future<List<T>> Function() provider) async {
    try {
      return await provider();
    } on DioError catch (error) {
      failure(error);
      return null;
    }
  }

  @mustCallSuper
  List<ValueNotifier> getRefreshListeners() => [];

  Future<List<T>> provide(int page);

  @nonVirtual
  Future<List<T>?> loadPage(int page) => catchError(() => provide(page));

  @override
  Future<void> refresh({bool background = false}) async {
    // makes sure a singular refresh can be queued up
    if (requestLock.isLocked) {
      if (isRefreshing) {
        return;
      }
      isRefreshing = true;
      // waits for the current request to be done
      await requestLock.acquire();
      requestLock.release();
      isRefreshing = false;
    }
    if (background) {
      List<T>? items = await loadPage(firstPageKey);
      if (items != null) {
        value = PagingState(
          nextPageKey: firstPageKey + 1,
          error: null,
          itemList: items,
        );
      }
    } else {
      super.refresh();
    }
    success();
  }

  Future<void> requestPage(int page) async {
    await requestLock.acquire();
    List<T>? items = await loadPage(page);
    if (items != null) {
      if (items.isEmpty) {
        appendLastPage(items);
      } else {
        appendPage(items, ++page);
      }
    }
    success();
    requestLock.release();
  }
}

mixin SearchableDataMixin<T> on DataController<T> {
  ValueNotifier<String> search = ValueNotifier('');

  @override
  List<ValueNotifier> getRefreshListeners() =>
      super.getRefreshListeners()..add(search);
}

mixin HostableDataMixin<T> on DataController<T> {
  @override
  List<ValueNotifier> getRefreshListeners() =>
      super.getRefreshListeners()..add(settings.safe);
}

mixin DeniableDataMixin<T> on DataController<T> {
  @override
  List<ValueNotifier> getRefreshListeners() => super.getRefreshListeners()
    ..addAll([settings.blacklist, settings.blacklisting]);
}

mixin RefreshableDataMixin<T> on DataController<T> {
  final RefreshController refreshController = RefreshController();

  @override
  void failure(Exception error) {
    super.failure(error);
    refreshController.refreshFailed();
  }

  @override
  void success() {
    super.success();
    refreshController.refreshCompleted();
  }
}
