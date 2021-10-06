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
      colorScheme: ColorScheme(
        primary: Colors.lightBlue,
        primaryVariant: Colors.blue,
        secondary: Colors.lightBlueAccent,
        secondaryVariant: Colors.blueAccent,
        surface: Colors.grey[850]!,
        background: Colors.grey[900]!,
        error: Colors.red,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.black,
        brightness: Brightness.dark,
      ),
    ),
  ),
  AppTheme.light: prepareTheme(
    ThemeData.from(
      colorScheme: ColorScheme(
        primary: Colors.lightBlue,
        primaryVariant: Colors.blue,
        secondary: Colors.lightBlueAccent,
        secondaryVariant: Colors.blueAccent,
        surface: Colors.white,
        background: Colors.grey[50]!,
        error: Colors.red,
        onSurface: Colors.black,
        onBackground: Colors.black,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.black,
        brightness: Brightness.light,
      ),
    ),
  ),
};

class DesktopDragScrollBehaviour extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => PointerDeviceKind.values.toSet();
}
