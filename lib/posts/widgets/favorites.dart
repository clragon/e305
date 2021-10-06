import 'package:e305/client/data/client.dart';
import 'package:e305/posts/data/controller.dart';
import 'package:e305/posts/widgets/search.dart';
import 'package:e305/settings/data/settings.dart';
import 'package:e305/settings/pages/login.dart';
import 'package:flutter/material.dart';

class FavoritesPage extends StatefulWidget {
  final SearchCallback? onSearch;

  const FavoritesPage({this.onSearch});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  FavoriteController controller = FavoriteController();

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Credentials?>(
        valueListenable: settings.credentials,
        builder: (context, credentials, child) {
          if (credentials == null) {
            return LoginPage(onSuccess: Navigator.of(context).maybePop);
          }
          return SearchPage(
            title: 'Favorites',
            controller: controller,
            onSearch: widget.onSearch,
            static: true,
          );
        },
      );
}
