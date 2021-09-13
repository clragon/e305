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
  bool? safe;
  AppTheme? theme;
  String? username;
  bool? expanded;
  bool? blacklisting;
  String? homeTags;

  Map<String, double>? databaseWeights;

  Future<String> host = client.host;
  Future<bool> hasLogin = client.hasLogin;

  Map<ValueNotifier<Future>, void Function()> linked = {};

  void linkSetting<T>(ValueNotifier<Future<T>> setting,
      Future<void> Function(T value) assignment) async {
    Future<void> setValue() async {
      var value = await setting.value;
      await assignment(value);
      if (mounted) {
        setState(() {});
      }
    }

    linked.addEntries([MapEntry(setting, setValue)]);
    setting.addListener(setValue);
    await setValue();
  }

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

  @override
  void initState() {
    super.initState();

    Map<ValueNotifier<Future>, Future<void> Function(dynamic value)> links = {
      settings.credentials: (value) async {
        username = value?.username;
        hasLogin = client.hasLogin;
      },
      settings.theme: (value) async => theme = value,
      settings.safe: (value) async {
        safe = value;
        host = client.host;
      },
      settings.expanded: (value) async => expanded = value,
      settings.blacklisting: (value) async => blacklisting = value,
      settings.homeTags: (value) async => homeTags = value,
      settings.databaseWeights: (value) async => databaseWeights = value,
    };

    links.forEach(linkSetting);

    recommendations.database.addListener(updateStatus);
    updateStatus();
  }

  @override
  void dispose() {
    linked.forEach((key, value) {
      key.removeListener(value);
    });
    super.dispose();
  }

  Future<void> onSignOut(BuildContext context) async {
    String? name = username;
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
            SafeCrossFade(
              showChild: safe != null,
              builder: (context) => SwitchListTile(
                title: Text('Explicit content'),
                subtitle: FutureBuilder(
                  future: host,
                  builder: (context, AsyncSnapshot<String?> snapshot) {
                    return CrossFade(
                      showChild:
                          snapshot.connectionState == ConnectionState.done,
                      child: SafeCrossFade(
                        showChild: snapshot.hasData,
                        builder: (BuildContext context) => Text(snapshot.data!),
                      ),
                      secondChild: Center(
                          child: SizedCircularProgressIndicator(size: 32)),
                    );
                  },
                ),
                secondary: Icon(safe!
                    ? FontAwesomeIcons.shieldAlt
                    : FontAwesomeIcons.exclamationTriangle),
                value: !safe!,
                onChanged: (value) async {
                  settings.safe.value = Future.value(!safe!);
                },
              ),
              secondChild:
                  Center(child: SizedCircularProgressIndicator(size: 32)),
            ),
            Divider(),
            settingsHeader('Display'),
            ListTile(
              title: Text('Theme'),
              subtitle: theme != null ? Text(describeEnum(theme!)) : null,
              leading: Icon(FontAwesomeIcons.solidLightbulb),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => ThemeDialog(),
                );
              },
            ),
            SafeCrossFade(
              showChild: expanded != null,
              builder: (context) => SwitchListTile(
                title: Text('Expand details'),
                subtitle: CrossFade(
                  showChild: expanded!,
                  child: Text('expanded post details'),
                  secondChild: Text('collapsed post details'),
                ),
                secondary: Icon(expanded!
                    ? FontAwesomeIcons.expand
                    : FontAwesomeIcons.compress),
                value: expanded!,
                onChanged: (value) async {
                  settings.expanded.value = Future.value(value);
                },
              ),
              secondChild:
                  Center(child: SizedCircularProgressIndicator(size: 32)),
            ),
            Divider(),
            settingsHeader('User'),
            FutureBuilder(
              future: hasLogin,
              builder: (context, AsyncSnapshot<bool?> snapshot) => CrossFade(
                showChild: snapshot.connectionState == ConnectionState.done,
                child: SafeCrossFade(
                  showChild: snapshot.data != null && snapshot.data!,
                  builder: (context) => ListTile(
                    title: Text('Logout'),
                    subtitle: Text(username ?? ''),
                    leading: Icon(FontAwesomeIcons.signOutAlt),
                    onTap: () => onSignOut(context),
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
                secondChild:
                    Center(child: SizedCircularProgressIndicator(size: 32)),
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
                InkWell(
                  onTap: () => settings.blacklisting.value =
                      Future.value(!blacklisting!),
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
                          child: SafeCrossFade(
                            showChild: blacklisting != null,
                            builder: (context) => Switch(
                              value: blacklisting!,
                              onChanged: (value) async {
                                settings.blacklisting.value =
                                    Future.value(value);
                              },
                            ),
                            secondChild: Center(
                              child: Padding(
                                padding: EdgeInsets.all(4),
                                child: SizedCircularProgressIndicator(size: 32),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            FutureBuilder(
              future: hasLogin,
              builder: (context, AsyncSnapshot<bool?> snapshot) => CrossFade(
                showChild: snapshot.connectionState == ConnectionState.done,
                child: SafeCrossFade(
                  showChild: snapshot.data != null && snapshot.data!,
                  builder: (context) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(),
                      settingsHeader('Recommendations'),
                      SafeCrossFade(
                        showChild: homeTags != null,
                        builder: (context) => ListTile(
                          leading: Icon(
                            FontAwesomeIcons.hashtag,
                            size: 20,
                          ),
                          title: Text('Home tags'),
                          subtitle: Text(homeTags!),
                          onTap: () async {
                            showDialog(
                              context: context,
                              builder: (context) => TagChangeDialog(
                                title: 'Home tags',
                                onSubmit: (value) => settings.homeTags.value =
                                    Future.value(value),
                                controller:
                                    TextEditingController(text: homeTags),
                                hint: 'tags',
                              ),
                            );
                          },
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          FontAwesomeIcons.balanceScaleLeft,
                          size: 20,
                        ),
                        title: Text('Weights'),
                        subtitle: Text('adjust tag category weights'),
                        onTap: () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
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
                                      'Uhh... this is awkward. This isn\'t implemented yet!',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          FontAwesomeIcons.syncAlt,
                          size: 20,
                        ),
                        title: Text('Reset database'),
                        subtitle: () {
                          switch (status) {
                            case RecommendationStatus.loading:
                              return Row(
                                children: [
                                  Text('database is being created'),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4),
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
                        }(),
                        onTap: status != RecommendationStatus.loading
                            ? () async {
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
                                        onPressed:
                                            Navigator.of(context).maybePop,
                                        child: Text('CANCEL'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await recommendations.recreate();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text('Reset database!'),
                                              duration:
                                                  Duration(milliseconds: 500),
                                            ),
                                          );
                                        },
                                        child: Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
                secondChild:
                    Center(child: SizedCircularProgressIndicator(size: 32)),
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
  const ThemeDialog({Key? key}) : super(key: key);

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
          settings.theme.value = Future.value(theme);
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
