import 'package:e305/posts/widgets/favorites.dart';
import 'package:e305/posts/widgets/home.dart';
import 'package:e305/posts/widgets/search.dart';
import 'package:e305/settings/pages/settings.dart';
import 'package:flutter/material.dart';

Map<String, WidgetBuilder> routes = {
  '/': (context) => const HomePage(),
  '/search': (context) => const SearchPage(),
  '/favorites': (context) => const FavoritesPage(),
  '/pools': (context) => const Center(child: Text('pools')),
  '/settings': (context) => const SettingsPage(),
};

extension RouteList on Map<String, WidgetBuilder> {
  List<WidgetBuilder> get list => routes.values.toList();
}
