import 'package:e305/interface/widgets/animation.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

class ExpandableParent extends StatefulWidget {
  final bool? expanded;
  final Widget Function(BuildContext context, ExpandableController controller)
      builder;

  const ExpandableParent({this.expanded, required this.builder});

  @override
  _ExpandableParentState createState() => _ExpandableParentState();
}

class _ExpandableParentState extends State<ExpandableParent> {
  ExpandableController? controller;

  @override
  void didUpdateWidget(covariant ExpandableParent oldWidget) {
    if (widget.expanded != null) {
      controller = ExpandableController(initialExpanded: widget.expanded);
    } else {
      controller = null;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SafeCrossFade(
      showChild: controller != null,
      builder: (context) => ExpandableNotifier(
        controller: controller,
        child: ScrollOnExpand(
          child: widget.builder(context, controller!),
        ),
      ),
    );
  }
}
