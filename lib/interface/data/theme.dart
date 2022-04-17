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
    return const BouncingScrollPhysics();
  }
}

ThemeData prepareTheme(ThemeData theme) => theme.copyWith(
      pageTransitionsTheme: const PageTransitionsTheme(
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
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );

Map<AppTheme, ThemeData> themeMap = {
  AppTheme.dark: prepareTheme(
    ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF152f56),
        primary: const Color(0xFFfdba31),
        secondary: const Color(0xFFfdba31),
        surface: const Color(0xFF152f56),
        background: const Color(0xFF020f23),
        brightness: Brightness.dark,
      ),
    ),
  ),
  AppTheme.light: prepareTheme(
    ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1d3963),
        primary: const Color(0xFFfdba31),
        secondary: const Color(0xFFfdba31),
        surface: const Color(0xFF243c61),
        background: const Color(0xFF1d3963),
        brightness: Brightness.dark,
      ),
    ),
  ),
};

class DesktopDragScrollBehaviour extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => PointerDeviceKind.values.toSet();
}
