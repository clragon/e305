import 'package:e305/client/models/post.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import 'expand.dart';

class DescriptionDisplay extends StatelessWidget {
  final Post post;

  const DescriptionDisplay({required this.post});

  @override
  Widget build(BuildContext context) {
    if (post.description.isNotEmpty) {
      return Column(
        children: [
          ExpandableDefaultParent(
            builder: (context, controller) => ExpandablePanel(
              key: ObjectKey(controller),
              controller: controller,
              collapsed: const SizedBox.shrink(),
              header: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Description',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              expanded: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
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
          const Divider(),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
