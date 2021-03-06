import 'dart:async';

import 'package:e305/settings/data/settings.dart';
import 'package:flutter/material.dart';
import 'package:mutex/mutex.dart';

typedef StepCallback = bool Function([int? progress]);

abstract class DataUpdater<T> extends ChangeNotifier {
  final ValueNotifier<int> progress = ValueNotifier(0);
  final Mutex updateLock = Mutex();

  Duration? get stale => null;

  Future? get finish => completer?.future;
  Completer? completer;

  bool error = false;
  bool restarting = false;
  bool canceling = false;

  DataUpdater() {
    getRefreshListeners().forEach((element) => element.addListener(refresh));
  }

  @override
  void dispose() {
    getRefreshListeners().forEach((element) => element.removeListener(refresh));
    super.dispose();
  }

  @mustCallSuper
  Future<void> refresh() async {
    if (completer?.isCompleted ?? true) {
      update();
    } else {
      restarting = true;
    }
    return finish;
  }

  @mustCallSuper
  Future<void> cancel() async {
    if (!(completer?.isCompleted ?? true)) {
      canceling = true;
    }
    return finish;
  }

  @mustCallSuper
  void fail() {
    error = true;
    complete();
  }

  @mustCallSuper
  void complete() {
    updateLock.release();
    completer!.complete();
    notifyListeners();
  }

  @mustCallSuper
  List<ValueNotifier> getRefreshListeners() => [];

  Future<T> read();

  Future<void> write(T? data);

  Future<T?> run(T data, StepCallback step, bool force);

  @mustCallSuper
  bool step({int? progress, bool force = false}) {
    if (restarting) {
      updateLock.release();
      update(force: force);
      return false;
    }
    if (canceling) {
      updateLock.release();
      return false;
    }
    this.progress.value = progress ?? this.progress.value + 1;
    notifyListeners();
    return true;
  }

  Future<void> update({bool force = false}) async {
    if (completer?.isCompleted ?? true) {
      completer = Completer();
    }
    if (updateLock.isLocked) {
      return finish;
    }
    await updateLock.acquire();
    progress.value = 0;
    restarting = false;
    canceling = false;
    error = false;

    notifyListeners();

    bool step([int? progress]) => this.step(progress: progress, force: force);

    Future<void> _update() async {
      T data = await read();
      T? result = await run(data, step, force);
      if (!restarting && !error) {
        await write(result);
        complete();
      }
    }

    _update();

    return finish;
  }
}

mixin HostableUpdater<T> on DataUpdater<T> {
  @override
  List<ValueNotifier> getRefreshListeners() =>
      super.getRefreshListeners()..add(settings.safe);
}
