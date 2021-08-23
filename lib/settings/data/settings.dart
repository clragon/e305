import 'dart:async' show Future;

import 'package:e305/client/data/client.dart';
import 'package:e305/interface/data/theme.dart';
import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

final Persistence settings = Persistence();

class Persistence {
  late ValueNotifier<Future<Credentials?>> credentials;
  late ValueNotifier<Future<AppTheme>> theme;
  late ValueNotifier<Future<bool>> safe;
  late ValueNotifier<Future<bool>> expanded;

  Persistence() {
    credentials = createSetting<Credentials?>('credentials', initial: null,
        getSetting: (prefs, key) async {
      String? value = prefs.getString(key);
      if (value != null) {
        return Credentials.fromJson(value);
      } else {
        return null;
      }
    }, setSetting: (prefs, key, value) {
      if (value == null) {
        prefs.remove(key);
      } else {
        prefs.setString(key, value.toJson());
      }
    });
    theme = createStringSetting<AppTheme>('theme',
        initial: themeMap.keys.first, values: AppTheme.values);
    safe = createSetting<bool>('followsSplit', initial: true);
    expanded = createSetting<bool>('expandDetails', initial: false);
  }

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Type _typeify<T>() => T;

  ValueNotifier<Future<T>> createSetting<T>(
    String key, {
    required T initial,
    Future<T?> Function(SharedPreferences prefs, String key)? getSetting,
    Function(SharedPreferences prefs, String key, T value)? setSetting,
  }) {
    ValueNotifier<Future<T>> setting = ValueNotifier<Future<T>>(() async {
      SharedPreferences prefs = await _prefs;
      T? value;
      if (getSetting == null) {
        switch (T) {
          case String:
            value = prefs.getString(key) as T?;
            break;
          case bool:
            value = prefs.getBool(key) as T?;
            break;
          case int:
            value = prefs.getInt(key) as T?;
            break;
          default:
            if (T == _typeify<List<String>>()) {
              value = prefs.getStringList(key) as T?;
            }
        }
      } else {
        value = await getSetting(prefs, key);
      }
      return value ?? initial;
    }());

    setting.addListener(() async {
      SharedPreferences prefs = await _prefs;
      T value = await setting.value;
      if (setSetting == null) {
        switch (T) {
          case String:
            prefs.setString(key, value as String);
            break;
          case bool:
            prefs.setBool(key, value as bool);
            break;
          case int:
            prefs.setInt(key, value as int);
            break;
          default:
            if (T == _typeify<List<String>>()) {
              prefs.setStringList(key, value as List<String>);
            }
        }
      } else {
        setSetting(prefs, key, value);
      }
    });

    return setting;
  }

  ValueNotifier<Future<T>> createStringSetting<T>(
    String key, {
    required T initial,
    required List<T> values,
  }) =>
      createSetting(
        key,
        initial: initial,
        getSetting: (prefs, key) async {
          String? value = prefs.getString(key);
          try {
            return values.singleWhere(
              (element) => element.toString() == value,
            );
          } on StateError {
            return null;
          }
        },
        setSetting: (prefs, key, value) {
          prefs.setString(key, value.toString());
        },
      );
}
