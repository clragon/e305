import 'package:e305/interface/widgets/animation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

abstract class AppBarBuilderWidget implements PreferredSizeWidget {
  abstract final PreferredSizeWidget child;

  @override
  Size get preferredSize => child.preferredSize;
}

class AppBarBuilder extends StatelessWidget with AppBarBuilderWidget {
  @override
  final PreferredSizeWidget child;
  final Widget Function(BuildContext context, PreferredSizeWidget child)
      builder;

  const AppBarBuilder({Key? key, required this.child, required this.builder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}

class ScrollToTop extends StatelessWidget {
  final ScrollController? controller;
  final bool primary;
  final Widget Function(BuildContext context, Widget child)? builder;
  final Widget? child;
  final double? height;

  const ScrollToTop({
    this.builder,
    this.child,
    this.controller,
    this.height,
    this.primary = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget tapWrapper(Widget? child) {
      ScrollController? controller = this.controller ??
          (primary ? PrimaryScrollController.of(context) : null);
      return GestureDetector(
        child: Container(
          height: height,
          color: Colors.transparent,
          child: child != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: child),
                        ],
                      ),
                    )
                  ],
                )
              : null,
        ),
        onDoubleTap: controller != null
            ? () => controller.animateTo(
                  0,
                  duration: defaultAnimationDuration,
                  curve: Curves.easeOut,
                )
            : null,
      );
    }

    Widget Function(BuildContext context, Widget child) builder =
        this.builder ?? (context, child) => child;

    return builder(
      context,
      tapWrapper(child),
    );
  }
}

class TransparentAppBar extends StatelessWidget with AppBarBuilderWidget {
  final bool transparent;

  @override
  final PreferredSizeWidget child;

  const TransparentAppBar({
    this.transparent = true,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black38,
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp,
        ),
      ),
      child: AnimatedTheme(
        data: Theme.of(context).copyWith(
          iconTheme: Theme.of(context).iconTheme.copyWith(color: Colors.white),
          appBarTheme: Theme.of(context).appBarTheme.copyWith(
                elevation: transparent ? 0 : null,
                backgroundColor: transparent ? Colors.transparent : null,
              ),
        ),
        child: child,
      ),
    );
  }
}

class SearchableAppBar extends StatefulWidget with PreferredSizeWidget {
  final Widget title;
  final String label;
  final bool canSearch;
  final bool transparent;
  final String Function() getSearch;
  final void Function(String value) setSearch;

  const SearchableAppBar({
    required this.getSearch,
    required this.title,
    required this.label,
    required this.setSearch,
    this.transparent = false,
    this.canSearch = true,
  });

  @override
  _SearchableAppBarState createState() => _SearchableAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchableAppBarState extends State<SearchableAppBar> {
  bool searching = false;
  TextEditingController controller = TextEditingController();

  void request() {
    controller.text = widget.getSearch();
    if (controller.text.isNotEmpty) {
      controller.text = controller.text + ' ';
    }
    controller.selection = TextSelection(
      baseOffset: controller.text.length,
      extentOffset: controller.text.length,
    );
    setState(() {
      searching = true;
    });
    setState(() {
      searching = true;
    });
  }

  void submit() {
    setState(() {
      searching = false;
    });
    widget.setSearch(controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return ScrollToTop(
      builder: (context, child) => TransparentAppBar(
        transparent: widget.transparent && !searching,
        child: AppBar(
          flexibleSpace: child,
          title: SafeCrossFade(
            showChild: searching,
            builder: (context) => TextField(
              autofocus: true,
              controller: controller,
              maxLines: 1,
              decoration: InputDecoration(
                labelText: widget.label,
                border: InputBorder.none,
              ),
              onSubmitted: (_) => submit(),
            ),
            secondChild: IgnorePointer(
              child: Row(
                children: [Expanded(child: widget.title)],
              ),
            ),
          ),
          actions: [
            if (widget.canSearch)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Center(
                  child: CrossFade(
                    showChild: searching,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                searching = false;
                              });
                            },
                            icon: const Icon(
                              FontAwesomeIcons.times,
                              size: 20,
                            ),
                          ),
                        ),
                        Flexible(
                          child: IconButton(
                            onPressed: submit,
                            icon: const Icon(
                              FontAwesomeIcons.check,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    secondChild: IconButton(
                      onPressed: request,
                      icon: const Icon(
                        FontAwesomeIcons.search,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
