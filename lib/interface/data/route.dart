import 'package:e305/posts/widgets/favorites.dart';
import 'package:e305/posts/widgets/home.dart';
import 'package:e305/posts/widgets/search.dart';
import 'package:e305/settings/pages/settings.dart';
import 'package:flutter/material.dart';

Map<String, WidgetBuilder> routes = {
  '/': (context) => HomePage(),
  '/search': (context) => SearchPage(),
  '/favorites': (context) => FavoritesPage(),
  '/pools': (context) => Center(child: Text('pools')),
  '/settings': (context) => SettingsPage(),
};

extension routeList on Map<String, WidgetBuilder> {
  List<WidgetBuilder> get list => routes.values.toList();
}
