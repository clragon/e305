import 'package:e305/interface/data/theme.dart';
import 'package:e305/interface/widgets/error.dart';
import 'package:e305/interface/widgets/navigation.dart';
import 'package:e305/settings/data/settings.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await settings.initialized;
  ErrorWidget.builder = DefaultErrorWidget.new;
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppTheme>(
      valueListenable: settings.theme,
      builder: (context, value, child) => ExcludeSemantics(
        child: ScrollConfiguration(
          behavior: const DefaultScrollBehaviour(),
          child: MaterialApp(
            title: 'e305',
            theme: themeMap[value],
            home: const NavigationPage(),
            scrollBehavior: DesktopDragScrollBehaviour(),
          ),
        ),
      ),
    );
  }
}
