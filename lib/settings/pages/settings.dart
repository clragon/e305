import 'dart:async' show Future;

import 'package:e305/client/data/client.dart';
import 'package:e305/interface/data/theme.dart';
import 'package:e305/interface/widgets/animation.dart';
import 'package:e305/interface/widgets/loading.dart';
import 'package:e305/profile/widgets/icon.dart';
import 'package:e305/profile/widgets/profile.dart';
import 'package:e305/recommendations/data/updater.dart';
import 'package:e305/recommendations/widgets/recommendations.dart';
import 'package:e305/settings/data/settings.dart';
import 'package:e305/settings/pages/blacklist.dart';
import 'package:e305/settings/pages/login.dart';
import 'package:e305/settings/pages/recommendations.dart';
import 'package:e305/settings/pages/theme.dart';
import 'package:e305/settings/pages/version.dart';
import 'package:e305/tags/data/post.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'divider_tile.dart';

class SettingsPage extends StatefulWidget {
  @override
  State createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Future<bool> hasLogin;

  Map<ValueNotifier<Future>, void Function()> linked = {};

  RecommendationStatus status = RecommendationStatus.loading;

  Future<void> updateStatus() async {
    setState(() {
      status = RecommendationStatus.loading;
    });
    List<SlimPost>? favs = await recommendations.getFavorites();
    setState(() {
      if (favs == null) {
        status = RecommendationStatus.anonymous;
      } else if (favs.length < recommendations.required) {
        status = RecommendationStatus.insufficient;
      } else {
        status = RecommendationStatus.functional;
      }
    });
  }

  Future<void> resetDatabase() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset database'),
        content: Text(
            'Are you sure you want to recreate your favorite database?'
            '\nThis should be executed when you have favorited alot of new things.'
            '\nThis action might take a while.'),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).maybePop,
            child: Text('CANCEL'),
          ),
          TextButton(
            child: Text('OK'),
            onPressed: () async {
              Navigator.of(context).maybePop();
              await recommendations.recreate();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reset database!'),
                  duration: Duration(milliseconds: 500),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> updateHasLogin() async {
    setState(() {
      hasLogin = client.hasLogin;
    });
  }

  @override
  void initState() {
    super.initState();
    recommendations.database.addListener(updateStatus);
    settings.credentials.addListener(updateHasLogin);
    updateStatus();
    updateHasLogin();
  }

  @override
  void dispose() {
    recommendations.database.removeListener(updateStatus);
    settings.credentials.removeListener(updateHasLogin);
    super.dispose();
  }

  Future<void> onLogOut(BuildContext context) async {
    String? name = settings.credentials.value?.username;
    await client.logout();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: 1),
      content: Text('Forgot login details ${name != null ? 'for $name' : ''}'),
    ));
  }

  Widget settingsHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 68, bottom: 8, top: 8, right: 16),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyWidgetBuilder(BuildContext context) {
      return Padding(
        padding: EdgeInsets.all(10.0),
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            settingsHeader('Account'),
            ValueListenableBuilder<bool>(
              valueListenable: settings.safe,
              builder: (context, safe, child) => SwitchListTile(
                title: Text('Explicit content'),
                subtitle: Text(client.host),
                secondary: Icon(safe
                    ? FontAwesomeIcons.shieldAlt
                    : FontAwesomeIcons.exclamationTriangle),
                value: !safe,
                onChanged: (value) => settings.safe.value = !value,
              ),
            ),
            FutureBuilder<bool?>(
              future: hasLogin,
              builder: (context, snapshot) => CrossFade(
                showChild: snapshot.connectionState == ConnectionState.done,
                child: AnimatedSwitcher(
                  duration: defaultAnimationDuration,
                  child: snapshot.hasData && snapshot.data!
                      ? DividerListTile(
                          title: Text(settings.credentials.value!.username),
                          leading: IgnorePointer(
                            child: ProfileButton(),
                          ),
                          subtitle: Text('user'),
                          contentPadding: EdgeInsets.only(left: 8, right: 16),
                          separated: Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: IgnorePointer(
                              child: IconButton(
                                icon: Icon(FontAwesomeIcons.signOutAlt),
                                onPressed: () => onLogOut(context),
                              ),
                            ),
                          ),
                          onTap: () =>
                              Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (context) => ProfileDetail(),
                            ),
                          ),
                          onTapSeparated: () => onLogOut(context),
                        )
                      : ListTile(
                          title: Text('Login'),
                          leading: Icon(FontAwesomeIcons.userPlus),
                          onTap: () =>
                              Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (context) => LoginPage(
                                onSuccess: Navigator.of(context).maybePop,
                              ),
                            ),
                          ),
                        ),
                ),
                secondChild: ListTile(
                  leading: PulseLoadingIndicator(size: 32),
                  title: Text('User'),
                ),
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: settings.blacklisting,
              builder: (context, blacklisting, child) => DividerListTile(
                title: Text('Blacklist'),
                subtitle: Text('tags you dont want to see'),
                leading: Icon(FontAwesomeIcons.ban),
                onTap: () => Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (context) => BlacklistSettings(),
                  ),
                ),
                separated: Switch(
                  value: blacklisting,
                  onChanged: (value) => settings.blacklisting.value = value,
                ),
                onTapSeparated: () =>
                    settings.blacklisting.value = !blacklisting,
              ),
            ),
            Divider(),
            settingsHeader('Display'),
            ValueListenableBuilder<AppTheme>(
              valueListenable: settings.theme,
              builder: (context, theme, child) {
                return ListTile(
                  title: Text('Theme'),
                  subtitle: Text(describeEnum(theme)),
                  leading: Icon(FontAwesomeIcons.solidLightbulb),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => ThemeDialog(),
                    );
                  },
                );
              },
            ),
            ValueListenableBuilder<bool>(
              valueListenable: settings.expanded,
              builder: (context, expanded, child) {
                return SwitchListTile(
                  title: Text('Expand details'),
                  subtitle: CrossFade(
                    showChild: expanded,
                    child: Text('expanded post details'),
                    secondChild: Text('collapsed post details'),
                  ),
                  secondary: Icon(expanded
                      ? FontAwesomeIcons.expand
                      : FontAwesomeIcons.compress),
                  value: expanded,
                  onChanged: (value) => settings.expanded.value = value,
                );
              },
            ),
            FutureBuilder<bool>(
              future: hasLogin,
              builder: (context, snapshot) => CrossFade(
                showChild: snapshot.connectionState == ConnectionState.done,
                child: SafeCrossFade(
                  showChild: snapshot.hasData && snapshot.data!,
                  builder: (context) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(),
                      settingsHeader('Recommendations'),
                      if (status == RecommendationStatus.functional)
                        ValueListenableBuilder<String>(
                          valueListenable: settings.homeTags,
                          builder: (context, homeTags, child) => ListTile(
                            leading: Icon(
                              FontAwesomeIcons.hashtag,
                              size: 20,
                            ),
                            title: Text('Home tags'),
                            subtitle: Text(homeTags),
                            onTap: () => showDialog(
                              context: context,
                              builder: (context) => TagChangeDialog(
                                title: 'Home tags',
                                onSubmit: (value) =>
                                    settings.homeTags.value = value,
                                controller:
                                    TextEditingController(text: homeTags),
                                hint: 'tags',
                              ),
                            ),
                          ),
                        ),
                      ValueListenableBuilder(
                        valueListenable: settings.databaseWeights,
                        builder: (context, databaseWeights, child) => ListTile(
                          leading: Icon(
                            FontAwesomeIcons.balanceScaleLeft,
                            size: 20,
                          ),
                          title: Text('Weights'),
                          subtitle: Text('adjust tag category weights'),
                          onTap: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: Duration(seconds: 2),
                              content: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Icon(
                                      FontAwesomeIcons.tools,
                                      size: 20,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      'Work in progress!',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          FontAwesomeIcons.syncAlt,
                          size: 20,
                        ),
                        title: Text('Reset database'),
                        subtitle: RecommendationDatabaseText(status: status),
                        onTap: status != RecommendationStatus.loading
                            ? resetDatabase
                            : null,
                      ),
                    ],
                  ),
                ),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(),
                    ListTile(
                      leading: PulseLoadingIndicator(size: 32),
                      title: Text('Recommendations'),
                    ),
                  ],
                ),
              ),
            ),
            Divider(),
            settingsHeader('Info'),
            ListTile(
              title: Text('About'),
              leading: Icon(FontAwesomeIcons.infoCircle),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => VersionDialog(),
                );
              },
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Builder(builder: bodyWidgetBuilder),
    );
  }
}
