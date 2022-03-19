import 'dart:math';

import 'package:e305/interface/data/theme.dart';
import 'package:e305/interface/widgets/navigation.dart';
import 'package:e305/settings/data/settings.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await settings.initialized;
  ErrorWidget.builder = (details) => DefaultErrorWidget(details);
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppTheme>(
      valueListenable: settings.theme,
      builder: (context, value, child) => ExcludeSemantics(
        child: ScrollConfiguration(
          behavior: DefaultScrollBehaviour(),
          child: MaterialApp(
            title: 'e305',
            theme: themeMap[value],
            home: NavigationPage(),
            scrollBehavior: DesktopDragScrollBehaviour(),
          ),
        ),
      ),
    );
  }
}

class DefaultErrorWidget extends StatelessWidget {
  final FlutterErrorDetails details;

  const DefaultErrorWidget(this.details);

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
