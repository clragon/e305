import 'package:e305/posts/data/post.dart';
import 'package:e305/posts/widgets/search.dart';
import 'package:e305/tags/widgets/body.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import 'expand.dart';

class TagDisplay extends StatelessWidget {
  final Post post;
  final SearchCallback onSearch;

  const TagDisplay({
    required this.post,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return ExpandableDefaultParent(
      builder: (context, controller) => ExpandablePanel(
        key: ObjectKey(controller),
        controller: controller,
        collapsed: const SizedBox.shrink(),
        header: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Tags',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        expanded: TagBody(
          post: post,
          onSearch: onSearch,
        ),
      ),
    );
  }
}
