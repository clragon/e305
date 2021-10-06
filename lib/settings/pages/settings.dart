import 'dart:async' show Future;

import 'package:e305/client/data/client.dart';
import 'package:e305/interface/data/theme.dart';
import 'package:e305/interface/widgets/animation.dart';
import 'package:e305/interface/widgets/loading.dart';
import 'package:e305/profile/widgets/icon.dart';
import 'package:e305/recommendations/data/updater.dart';
import 'package:e305/recommendations/widgets/recommendations.dart';
import 'package:e305/settings/data/info.dart';
import 'package:e305/settings/data/settings.dart';
import 'package:e305/settings/pages/blacklist.dart';
import 'package:e305/settings/pages/login.dart';
import 'package:e305/tags/data/post.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
            settingsHeader('Host'),
            ValueListenableBuilder<bool>(
              valueListenable: settings.safe,
              builder: (context, safe, child) => SwitchListTile(
                title: Text('Explicit content'),
                subtitle: Text(client.host),
                secondary: Icon(safe
                    ? FontAwesomeIcons.shieldAlt
                    : FontAwesomeIcons.exclamationTriangle),
                value: !safe,
                onChanged: (value) => settings.safe.value = value,
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
            Divider(),
            settingsHeader('User'),
            FutureBuilder<bool?>(
              future: hasLogin,
              builder: (context, snapshot) => CrossFade(
                showChild: snapshot.connectionState == ConnectionState.done,
                child: SafeCrossFade(
                  showChild: snapshot.hasData && snapshot.data!,
                  builder: (context) => ListTile(
                    title: Text('Logout'),
                    subtitle: settings.credentials.value?.username != null
                        ? Text(settings.credentials.value!.username)
                        : null,
                    leading: Icon(FontAwesomeIcons.signOutAlt),
                    onTap: () => onLogOut(context),
                    trailing: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: IgnorePointer(
                        child: ProfileButton(),
                      ),
                    ),
                  ),
                  secondChild: ListTile(
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
                secondChild: Center(
                  child: SizedCircularProgressIndicator(size: 32),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text('Blacklist'),
                    subtitle: Text('tags you dont want to see'),
                    leading: Icon(FontAwesomeIcons.ban),
                    onTap: () =>
                        Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (context) => BlacklistSettings(),
                      ),
                    ),
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: settings.blacklisting,
                  builder: (context, blacklisting, child) => InkWell(
                    onTap: () => settings.blacklisting.value = !blacklisting,
                    child: SizedBox(
                      height: 64,
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Container(
                              color: Theme.of(context).dividerColor,
                              width: 2,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 20),
                            child: Switch(
                              value: blacklisting,
                              onChanged: (value) =>
                                  settings.blacklisting.value = value,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
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
                              controller: TextEditingController(text: homeTags),
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
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: SizedCircularProgressIndicator(size: 32),
                      ),
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

class ThemeDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget themeTile(AppTheme theme) {
      return ListTile(
        title: Text(describeEnum(theme)),
        trailing: Container(
          height: 26,
          width: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: themeMap[theme]?.cardColor,
            border: Border.all(
              color: Theme.of(context).iconTheme.color!,
            ),
          ),
        ),
        onTap: () {
          settings.theme.value = theme;
          Navigator.of(context).maybePop();
        },
      );
    }

    return SimpleDialog(
      title: Text('Theme'),
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: themeMap.keys.map(themeTile).toList(),
        )
      ],
    );
  }
}

class VersionDialog extends StatefulWidget {
  const VersionDialog();

  @override
  _VersionDialogState createState() => _VersionDialogState();
}

class _VersionDialogState extends State<VersionDialog> {
  final Future<PackageInfo> packageInfo = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 120,
                maxWidth: 120,
              ),
              child: Image(
                image: AssetImage(
                  'assets/icon.png',
                ),
              ),
            ),
          ),
          Text(
            appName,
            style: Theme.of(context).textTheme.headline5,
          ),
          FutureBuilder(
            future: PackageInfo.fromPlatform(),
            builder: (context, AsyncSnapshot<PackageInfo> snapshot) {
              return Padding(
                padding: EdgeInsets.all(8),
                child: SafeCrossFade(
                  showChild: snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData,
                  builder: (context) => Text('v${snapshot.data!.version}'),
                ),
              );
            },
          ),
          Text(
            about,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .color!
                  .withOpacity(0.35),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'by $developer',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .color!
                    .withOpacity(0.35),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RecommendationDatabaseText extends StatelessWidget {
  final RecommendationStatus status;

  const RecommendationDatabaseText({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case RecommendationStatus.loading:
        return Row(
          children: [
            Text('database is being created'),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: PulseLoadingIndicator(size: 14),
            ),
          ],
        );
      case RecommendationStatus.anonymous:
        return Text('you are not logged in');
      case RecommendationStatus.insufficient:
        return Text(
            'you dont have enough favorites.\nclick here after you favorited some posts!');
      case RecommendationStatus.functional:
        return Text('recreate favorite tag database');
    }
  }
}

class TagChangeDialog extends StatefulWidget {
  final void Function(String value) onSubmit;
  final TextEditingController controller;
  final String title;
  final String hint;

  const TagChangeDialog({
    required this.title,
    required this.hint,
    required this.onSubmit,
    required this.controller,
  });

  @override
  _TagChangeDialogState createState() => _TagChangeDialogState();
}

class _TagChangeDialogState extends State<TagChangeDialog> {
  void submit() {
    widget.onSubmit(widget.controller.text.trim());
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        autofocus: true,
        controller: widget.controller,
        onSubmitted: (_) => submit(),
        decoration: InputDecoration(
          hintText: widget.hint,
        ),
      ),
      actions: [
        TextButton(
          child: Text('CANCEL'),
          onPressed: Navigator.of(context).maybePop,
        ),
        TextButton(
          child: Text('OK'),
          onPressed: submit,
        ),
      ],
    );
  }
}
