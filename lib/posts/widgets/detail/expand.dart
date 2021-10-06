import 'package:e305/settings/data/settings.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

class ExpandableParent extends StatefulWidget {
  final bool expanded;
  final Widget Function(BuildContext context, ExpandableController controller)
      builder;

  const ExpandableParent({required this.expanded, required this.builder});

  @override
  _ExpandableParentState createState() => _ExpandableParentState();
}

class _ExpandableParentState extends State<ExpandableParent> {
  late ExpandableController controller =
      ExpandableController(initialExpanded: widget.expanded);

  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
      controller: controller,
      child: ScrollOnExpand(
        child: widget.builder(context, controller),
      ),
    );
  }
}

class ExpandableDefaultParent extends StatelessWidget {
  final Widget Function(BuildContext context, ExpandableController controller)
      builder;

  const ExpandableDefaultParent({required this.builder});

  @override
  Widget build(BuildContext context) {
    return ExpandableParent(
        expanded: settings.expanded.value, builder: builder);
  }
}
