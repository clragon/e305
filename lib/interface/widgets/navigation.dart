import 'dart:async';

import 'package:e305/pools/widgets/pools.dart';
import 'package:e305/posts/data/controller.dart';
import 'package:e305/posts/widgets/favorites.dart';
import 'package:e305/posts/widgets/home.dart';
import 'package:e305/posts/widgets/search.dart';
import 'package:e305/settings/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage();

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  PersistentTabController controller = PersistentTabController();
  Timer? exitResetTimer;
  bool willExit = false;
  RecommendationController postController = RecommendationController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<bool> onTryPop([BuildContext? context]) async {
    if (context != null && ModalRoute.of(context)!.isCurrent && !willExit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
      willExit = true;
      exitResetTimer = Timer(Duration(seconds: 2), () => willExit = false);
      return false;
    }
    return true;
  }

  void onSearch(String search) {
    postController.search.value = search;
    controller.jumpToTab(1);
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: controller,
      onWillPop: onTryPop,
      resizeToAvoidBottomInset: true,
      navBarStyle: NavBarStyle.style12,
      screens: [
        HomePage(onSearch: onSearch),
        SearchPage(controller: postController),
        FavoritesPage(onSearch: onSearch),
        PoolPage(),
        SettingsPage(),
      ],
      backgroundColor: Theme.of(context).canvasColor,
      items: [
        PersistentBottomNavBarItem(
          icon: Icon(FontAwesomeIcons.home),
          title: "Recommended",
          activeColorPrimary: Colors.orange,
          inactiveColorPrimary: Theme.of(context).colorScheme.onBackground,
        ),
        PersistentBottomNavBarItem(
          icon: Icon(FontAwesomeIcons.search),
          title: "Search",
          activeColorPrimary: Colors.green,
          inactiveColorPrimary: Theme.of(context).colorScheme.onBackground,
        ),
        PersistentBottomNavBarItem(
          icon: Icon(FontAwesomeIcons.solidHeart),
          title: "Favorites",
          activeColorPrimary: Colors.pink,
          inactiveColorPrimary: Theme.of(context).colorScheme.onBackground,
        ),
        PersistentBottomNavBarItem(
          icon: Icon(FontAwesomeIcons.layerGroup),
          title: "Pools",
          activeColorPrimary: Colors.blue,
          inactiveColorPrimary: Theme.of(context).colorScheme.onBackground,
        ),
        PersistentBottomNavBarItem(
          icon: Icon(FontAwesomeIcons.cog),
          title: "Settings",
          activeColorPrimary: Colors.blueGrey,
          inactiveColorPrimary: Theme.of(context).colorScheme.onBackground,
        ),
      ],
      screenTransitionAnimation: ScreenTransitionAnimation(
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
    );
  }
}
