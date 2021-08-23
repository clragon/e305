import 'package:e305/client/data/client.dart';
import 'package:e305/client/models/post.dart';
import 'package:flutter/material.dart';

enum VoteStatus {
  upvoted,
  unknown,
  downvoted,
}

Future<bool> vote({
  BuildContext? context,
  required Post post,
  required bool upvote,
  required VoteStatus current,
  required Function(VoteStatus value) onChange,
}) async {
  bool replace = current == VoteStatus.unknown;
  onChange(upvote
      ? current == VoteStatus.upvoted
          ? VoteStatus.unknown
          : VoteStatus.upvoted
      : current == VoteStatus.downvoted
          ? VoteStatus.unknown
          : VoteStatus.downvoted);
  bool success = await client.votePost(post.id, upvote, replace);
  if (!success) {
    onChange(VoteStatus.unknown);
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('failed to vote on post #${post.id}'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  return success;
}

Future<bool> toggleFavorite({
  BuildContext? context,
  required Post post,
  required bool current,
  required Function(bool value) onChange,
}) async {
  bool favorite = !current;
  onChange(favorite);
  bool success = favorite
      ? await client.addFavorite(post.id)
      : await client.removeFavorite(post.id);
  if (!success) {
    onChange(!favorite);
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(favorite
              ? 'failed to favorite post #${post.id}'
              : 'failed to remove favorite post #${post.id}'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  return success;
}
