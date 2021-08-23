import 'package:e305/client/models/post.dart';
import 'package:e305/posts/data/rating.dart';
import 'package:expandable/expandable.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import 'expand.dart';

class FileDisplay extends StatelessWidget {
  final Post post;
  final bool? expanded;

  const FileDisplay({required this.post, this.expanded});

  @override
  Widget build(BuildContext context) {
    Widget infoDisplay(IconData icon, String label, String value) {
      return DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 16),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(label),
                  ),
                ],
              ),
              Text(value),
            ],
          ),
        ),
      );
    }

    return ExpandableParent(
      expanded: expanded,
      builder: (context, controller) => ExpandablePanel(
        key: ObjectKey(controller),
        controller: controller,
        collapsed: SizedBox.shrink(),
        header: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'File',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        expanded: Column(
          children: [
            infoDisplay(FontAwesomeIcons.fingerprint, 'id', post.id.toString()),
            infoDisplay(
                FontAwesomeIcons.shieldAlt, 'rating', ratingMap[post.rating]!),
            infoDisplay(FontAwesomeIcons.cropAlt, 'dimensions',
                '${post.file.width}x${post.file.height}'),
            infoDisplay(
                FontAwesomeIcons.save, 'size', filesize(post.file.size)),
            infoDisplay(FontAwesomeIcons.upload, 'creation',
                DateFormat.yMd().format(post.createdAt.toLocal())),
          ],
        ),
      ),
    );
  }
}
