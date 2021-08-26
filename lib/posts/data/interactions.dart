import 'dart:io';

import 'package:e305/client/data/client.dart';
import 'package:e305/client/models/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

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

Future<bool> download({
  BuildContext? context,
  required Post post,
}) async {
  try {
    if (!Platform.isAndroid || !Platform.isIOS) {
      throw PlatformException(code: 'unsupported platform');
    }

    if (!await Permission.storage.request().isGranted) {
      return false;
    }
    File download = await DefaultCacheManager().getSingleFile(post.file.url!);
    await ImageGallerySaver.saveFile(download.path);
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('downloaded post #${post.id}'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    return true;
  } on PlatformException {
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('platform not supported'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  } catch (_) {
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('failed to download #${post.id}'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  return false;
}
