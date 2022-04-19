import 'package:flutter/material.dart';

typedef SearchCallback = void Function(String search);

class SearchProvider extends InheritedWidget {
  final SearchCallback? callback;

  const SearchProvider({required this.callback, required Widget child})
      : super(child: child);

  static SearchCallback? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SearchProvider>()
        ?.callback;
  }

  @override
  bool updateShouldNotify(covariant SearchProvider oldWidget) =>
      oldWidget.callback != callback;
}
