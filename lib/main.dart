import 'dart:math';

import 'package:e305/interface/data/theme.dart';
import 'package:e305/interface/widgets/navigation.dart';
import 'package:e305/settings/data/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

ValueNotifier<ThemeData> theme = ValueNotifier(themeMap[AppTheme.dark]!);

Future<void> updateTheme() async {
  theme.value = themeMap[await settings.theme.value]!;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  settings.theme.addListener(updateTheme);
  await updateTheme();
  // ErrorWidget.builder = (FlutterErrorDetails details) => DefaultErrorWidget();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: theme,
      builder: (context, ThemeData value, child) => ExcludeSemantics(
        child: ScrollConfiguration(
          behavior: DefaultScrollBehaviour(),
          child: MaterialApp(
            title: 'e305',
            theme: value,
            home: NavigationPage(),
            scrollBehavior: DesktopDragScrollBehaviour(),
          ),
        ),
      ),
    );
  }
}

class DefaultErrorWidget extends StatelessWidget {
  const DefaultErrorWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.indigoAccent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          double scale = min(constraints.maxWidth, constraints.maxHeight);

          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      right: scale * 0.05, bottom: scale * 0.05),
                  child: Text(
                    ':(',
                    style: TextStyle(fontSize: scale * 0.2),
                  ),
                ),
                Flexible(
                  child: Text(
                    'Something\nWent Wrong',
                    style: TextStyle(fontSize: scale * 0.085),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
