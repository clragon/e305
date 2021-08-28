import 'package:e305/client/models/post.dart';
import 'package:e305/posts/data/controller.dart';
import 'package:e305/posts/widgets/search.dart';
import 'package:e305/tags/widgets/body.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import 'expand.dart';

class TagDisplay extends StatelessWidget {
  final Post post;
  final bool? expanded;
  final SearchCallback onSearch;
  final PostController? postController;

  const TagDisplay(
      {required this.post,
      this.expanded,
      required this.onSearch,
      this.postController});

  @override
  Widget build(BuildContext context) {
    return ExpandableParent(
      expanded: expanded,
      builder: (context, controller) => ExpandablePanel(
        key: ObjectKey(controller),
        controller: controller,
        collapsed: SizedBox.shrink(),
        header: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Tags',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        expanded: TagBody(
          post: post,
          onSearch: onSearch,
          controller: postController,
        ),
      ),
    );
  }
}
