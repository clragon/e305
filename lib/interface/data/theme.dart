import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AppTheme {
  dark,
  light,
}

class DefaultScrollBehaviour extends ScrollBehavior {
  const DefaultScrollBehaviour();
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return BouncingScrollPhysics();
  }
}

ThemeData prepareTheme(ThemeData theme) => theme.copyWith(
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        },
      ),
      applyElevationOverlayColor: false,
      dialogBackgroundColor: theme.canvasColor,
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.selected)
              ? theme.colorScheme.secondary
              : null,
        ),
        trackColor: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.selected)
              ? theme.colorScheme.primary.withOpacity(0.5)
              : null,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.selected)
              ? theme.colorScheme.primary
              : null,
        ),
      ),
      appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: theme.canvasColor,
          systemNavigationBarIconBrightness:
              theme.brightness == Brightness.light
                  ? Brightness.dark
                  : Brightness.light,
        ),
        color: theme.canvasColor,
        foregroundColor: theme.iconTheme.color,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );

Map<AppTheme, ThemeData> themeMap = {
  AppTheme.dark: prepareTheme(
    ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(0xFF152f56),
        primary: Color(0xFFfdba31),
        secondary: Color(0xFFfdba31),
        surface: Color(0xFF152f56),
        background: Color(0xFF020f23),
        brightness: Brightness.dark,
      ),
    ),
  ),
  AppTheme.light: prepareTheme(
    ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(0xFF1d3963),
        primary: Color(0xFFfdba31),
        secondary: Color(0xFFfdba31),
        surface: Color(0xFF243c61),
        background: Color(0xFF1d3963),
        brightness: Brightness.dark,
      ),
    ),
  ),
};

class DesktopDragScrollBehaviour extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => PointerDeviceKind.values.toSet();
}
