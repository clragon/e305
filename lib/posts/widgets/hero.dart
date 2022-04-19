import 'package:flutter/cupertino.dart';

typedef HeroBuilder = String Function(int id);

class HeroProvider extends InheritedWidget {
  final HeroBuilder? builder;

  const HeroProvider({required this.builder, required Widget child})
      : super(child: child);

  static HeroBuilder? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HeroProvider>()?.builder;
  }

  @override
  bool updateShouldNotify(covariant HeroProvider oldWidget) =>
      oldWidget.builder != builder;
}
