import 'package:e305/interface/widgets/animation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

mixin AppBarSizeMixin on Widget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ScrollToTop extends StatelessWidget with AppBarSizeMixin {
  final double? height;
  final ScrollController? controller;
  final Widget child;

  const ScrollToTop({this.controller, required this.child, this.height});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: child,
      onDoubleTap: controller != null
          ? () => controller!.animateTo(
                0,
                duration: defaultAnimationDuration,
                curve: Curves.easeOut,
              )
          : null,
    );
  }

  @override
  Size get preferredSize =>
      height != null ? Size.fromHeight(height!) : super.preferredSize;
}

class ScrollToTopAppBar extends StatelessWidget with AppBarSizeMixin {
  final Widget Function(
    BuildContext context,
    Widget Function(BuildContext context, [Widget? child]) gesture,
  ) builder;
  final ScrollController? controller;
  final double? height;

  const ScrollToTopAppBar(
      {required this.builder, this.controller, this.height});

  Widget tapWrapper(Size size, Widget? child) {
    return ScrollToTop(
      controller: controller,
      child: Container(
        color: Colors.transparent,
        height: size.height,
        width: size.width,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => builder(
        context,
        (context, [child]) => tapWrapper(constraints.biggest, child),
      ),
    );
  }

  @override
  Size get preferredSize =>
      height != null ? Size.fromHeight(height!) : super.preferredSize;
}

class TransparentAppBar extends StatelessWidget with AppBarSizeMixin {
  final Widget? title;
  final List<Widget>? actions;
  final bool transparent;
  final double? opacity;

  const TransparentAppBar({
    this.actions,
    this.opacity,
    this.title,
    this.transparent = true,
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
      child: Theme(
        data: Theme.of(context).copyWith(
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        child: Opacity(
          opacity: opacity ?? 1,
          child: TweenAnimationBuilder<Color?>(
            tween: ColorTween(
              begin: null,
              end: transparent
                  ? Colors.transparent
                  : Theme.of(context).appBarTheme.backgroundColor,
            ),
            duration: defaultAnimationDuration,
            builder: (context, Color? value, child) => AppBar(
              backgroundColor: value,
              title: title,
              actions: actions,
            ),
          ),
        ),
      ),
    );
  }
}

class SearchableAppBar extends StatefulWidget with AppBarSizeMixin {
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
    return TransparentAppBar(
      transparent: widget.transparent && !searching,
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
        secondChild: Row(
          children: [Expanded(child: widget.title)],
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
    );
  }
}
