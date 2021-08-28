import 'dart:async' show Future;

import 'package:e305/client/data/client.dart';
import 'package:e305/interface/data/theme.dart';
import 'package:e305/interface/widgets/animation.dart';
import 'package:e305/interface/widgets/loading.dart';
import 'package:e305/settings/data/info.dart';
import 'package:e305/settings/data/settings.dart';
import 'package:e305/settings/pages/login.dart';
import 'package:e305/tags/data/controller.dart';
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

  Future<String> host = client.host;
  Future<bool> hasLogin = client.hasLogin;

  void linkSetting<T>(ValueNotifier<Future<T>> setting,
      Future<void> Function(T value) assignment) async {
    Future<void> setValue() async {
      var value = await setting.value;
      await assignment(value);
      if (mounted) {
        setState(() {});
      }
    }

    setting.addListener(setValue);
    await setValue();
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
    };

    links.forEach(linkSetting);
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
          color: Theme.of(context).accentColor,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyWidgetBuilder(BuildContext context) {
      return Container(
        padding: EdgeInsets.all(10.0),
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            settingsHeader('General'),
            SafeCrossFade(
              showChild: safe != null,
              builder: (context) => SwitchListTile(
                title: Text('Explicit Content'),
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
            settingsHeader('Personalization'),
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
                title: Text('Expand Details'),
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
                  settings.expanded.value = Future.value(!expanded!);
                },
              ),
              secondChild:
                  Center(child: SizedCircularProgressIndicator(size: 32)),
            ),
            Divider(),
            settingsHeader('Listing'),
            ListTile(
              title: Text('Blacklist'),
              leading: Icon(FontAwesomeIcons.ban),
              onTap: () => {},
            ),
            Divider(),
            settingsHeader('Account'),
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
            ListTile(
              leading: Icon(
                FontAwesomeIcons.database,
                size: 20,
              ),
              title: Text('Reset database'),
              subtitle: Text('recreate favorite tag database'),
              onTap: () async {
                await favoriteDatabase.refreshFavorites();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Reset database!'),
                    duration: Duration(milliseconds: 500),
                  ),
                );
              },
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
