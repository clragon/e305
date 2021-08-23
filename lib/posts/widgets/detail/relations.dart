import 'package:e305/client/data/client.dart';
import 'package:e305/client/models/pool.dart';
import 'package:e305/client/models/post.dart';
import 'package:e305/interface/widgets/loading.dart';
import 'package:e305/pools/widgets/reader.dart';
import 'package:e305/posts/widgets/detail.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'expand.dart';

class RelationDisplay extends StatelessWidget {
  final Post post;
  final bool? expanded;

  const RelationDisplay({required this.post, this.expanded});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      if (post.pools.isNotEmpty)
        ...post.pools.map(
          (e) => InkWell(
            onTap: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (context) => LoadingScreen<Pool>(
                  provide: () => client.pool(e),
                  builder: (context, value) => PoolReader(pool: value),
                ),
              ),
            ),
            child: ListTile(
              leading: Icon(FontAwesomeIcons.layerGroup),
              title: Text(e.toString()),
              trailing: Icon(FontAwesomeIcons.caretRight),
            ),
          ),
        ),
      if (post.relationships.parentId != null)
        InkWell(
          onTap: () => Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) => LoadingScreen<Post>(
                provide: () => client.post(post.relationships.parentId!),
                builder: (context, value) => PostDetail(post: value),
              ),
            ),
          ),
          child: ListTile(
            leading: Icon(FontAwesomeIcons.levelUpAlt),
            title: Text(post.relationships.parentId.toString()),
            trailing: Icon(FontAwesomeIcons.caretRight),
          ),
        ),
      if (post.relationships.children.isNotEmpty)
        ...post.relationships.children.map(
          (e) => InkWell(
            onTap: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (context) => LoadingScreen<Post>(
                  provide: () => client.post(e),
                  builder: (context, value) => PostDetail(post: value),
                ),
              ),
            ),
            child: ListTile(
              leading: Icon(FontAwesomeIcons.levelDownAlt),
              title: Text(e.toString()),
              trailing: Icon(FontAwesomeIcons.caretRight),
            ),
          ),
        ),
    ];

    children = children.fold([], (previousValue, element) {
      if (previousValue.isNotEmpty && previousValue.last is! Divider) {
        previousValue.add(Divider(indent: 4, endIndent: 4));
      }
      previousValue.add(element);
      return previousValue;
    });

    if (children.isNotEmpty) {
      return Column(
        children: [
          ExpandableParent(
            expanded: expanded,
            builder: (context, controller) => ExpandablePanel(
              key: ObjectKey(controller),
              controller: controller,
              collapsed: SizedBox.shrink(),
              header: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Relations',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              expanded: Column(
                children: children,
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
