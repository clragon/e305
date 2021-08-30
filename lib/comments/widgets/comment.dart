import 'package:e305/client/models/comment.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timeago/timeago.dart';

class CommentTile extends StatelessWidget {
  final Comment comment;

  const CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    Widget picture(Comment comment) {
      return Padding(
        padding: EdgeInsets.only(right: 8, top: 4),
        child: Icon(FontAwesomeIcons.user),
      );
    }

    Widget title(Comment comment) {
      return Row(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 4, bottom: 4),
            child: Text(
              comment.creatorName,
              style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .color!
                    .withOpacity(0.35),
              ),
            ),
          ),
          Flexible(
            child: Text(
              () {
                String time = ' • ${format(comment.createdAt)}';
                if (comment.createdAt.isAtSameMomentAs(comment.updatedAt)) {
                  time += ' (edited)';
                }
                return time;
              }(),
              style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .color!
                    .withOpacity(0.35),
                fontSize: 12,
              ),
            ),
          ),
        ],
      );
    }

    Widget body(Comment comment) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(comment.body),
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          GestureDetector(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                picture(comment),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title(comment),
                      body(comment),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () async {},
          ),
          Divider(),
        ],
      ),
    );
  }
}
