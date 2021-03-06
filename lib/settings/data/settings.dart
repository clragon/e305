import 'dart:async' show Future;
import 'dart:convert';

import 'package:e305/client/data/client.dart';
import 'package:e305/interface/data/theme.dart';
import 'package:e305/recommendations/data/score.dart';
import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

final Persistence settings = Persistence();

class Persistence {
  late final SharedPreferences prefs;

  late ValueNotifier<Credentials?> credentials;
  late ValueNotifier<AppTheme> theme;
  late ValueNotifier<bool> safe;
  late ValueNotifier<bool> expanded;
  late ValueNotifier<List<String>> blacklist;
  late ValueNotifier<bool> blacklisting;
  late ValueNotifier<Map<String, double>> databaseWeights;
  late ValueNotifier<int> databaseSize;
  late ValueNotifier<String> homeTags;

  late Future<void> initialized = initialize();

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();

    credentials = createSetting<Credentials?>('credentials', initial: null,
        getSetting: (prefs, key) {
      String? value = prefs.getString(key);
      if (value != null) {
        return Credentials.fromJson(json.decode(value));
      } else {
        return null;
      }
    }, setSetting: (prefs, key, value) {
      if (value == null) {
        prefs.remove(key);
      } else {
        prefs.setString(key, json.encode(value));
      }
    });
    theme = createStringSetting<AppTheme>('theme',
        initial: themeMap.keys.first, values: AppTheme.values);
    safe = createSetting<bool>('safe', initial: true);
    expanded = createSetting<bool>('expandDetails', initial: false);
    blacklist = createSetting<List<String>>('blacklist', initial: []);
    blacklisting = createSetting('blacklisting', initial: true);
    databaseWeights = createSetting<Map<String, double>>('databaseWeights',
        initial: defaultWeights, getSetting: (prefs, key) {
      String? raw = prefs.getString(key);
      if (raw != null) {
        return json.decode(raw);
      }
      return null;
    }, setSetting: (prefs, key, value) async {
      await prefs.setString(key, json.encode(value));
    });
    databaseSize = createSetting<int>('databaseSize', initial: 1200);
    homeTags = createSetting<String>('homeTags', initial: 'order:random');
  }

  Type _typeify<T>() => T;

  ValueNotifier<T> createSetting<T>(
    String key, {
    required T initial,
    T? Function(SharedPreferences prefs, String key)? getSetting,
    Function(SharedPreferences prefs, String key, T value)? setSetting,
  }) {
    ValueNotifier<T> setting = ValueNotifier<T>(() {
      T? value;
      if (getSetting == null) {
        // this will not work with T? (String?, bool?, int?...)
        // if type is nullable, custom read and write have to be specificed
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
        value = getSetting(prefs, key);
      }
      return value ?? initial;
    }());

    setting.addListener(() {
      T value = setting.value;
      if (setSetting == null) {
        // this will not work with T? (String?, bool?, int?...)
        // if type is nullable, custom read and write have to be specificed
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

  ValueNotifier<T> createStringSetting<T>(
    String key, {
    required T initial,
    required List<T> values,
  }) =>
      createSetting(
        key,
        initial: initial,
        getSetting: (prefs, key) {
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
