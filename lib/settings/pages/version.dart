import 'package:e305/interface/widgets/animation.dart';
import 'package:e305/settings/data/info.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
                  builder: (context) => Column(
                    children: [
                      Text('v${snapshot.data!.version}'),
                      if (branch.isNotEmpty && commit.isNotEmpty)
                        Text('from $branch on $commit'),
                    ],
                  ),
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
