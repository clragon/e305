import 'package:e305/client/models/post.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import 'expand.dart';

class DescriptionDisplay extends StatelessWidget {
  final Post post;
  final bool? expanded;

  const DescriptionDisplay({required this.post, this.expanded});

  @override
  Widget build(BuildContext context) {
    if (post.description.isNotEmpty) {
      return Column(
        children: [
          ExpandableParent(
            expanded: expanded,
            builder: (context, controller) => ExpandablePanel(
              key: ObjectKey(controller),
              controller: controller,
              collapsed: SizedBox.shrink(),
              header: Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Description',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              expanded: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(post.description),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(),
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
