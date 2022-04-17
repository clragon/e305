import 'package:e305/interface/data/theme.dart';
import 'package:e305/settings/data/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
      title: const Text('Theme'),
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: themeMap.keys.map(themeTile).toList(),
        )
      ],
    );
  }
}
