import 'package:e305/client/data/client.dart';
import 'package:e305/interface/widgets/loading.dart';
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
  String? username;
  bool error = false;

  Future<void> updateUsername() async {
    Credentials? credentials = await settings.credentials.value;
    if (credentials != null) {
      setState(() {
        username = credentials.username;
      });
    } else {
      setState(() {
        username = null;
        error = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    settings.credentials.addListener(updateUsername);
    updateUsername();
  }

  @override
  void dispose() {
    settings.credentials.removeListener(updateUsername);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => username != null
      ? SearchPage(
          title: 'Favorites',
          controller: controller,
          onSearch: widget.onSearch,
          static: true,
        )
      : error
          ? LoginPage(onSuccess: Navigator.of(context).maybePop)
          : Scaffold(
              body: Center(
                child: OrbitLoadingIndicator(size: 100),
              ),
            );
}
