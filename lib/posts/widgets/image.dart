import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e305/client/models/post.dart';
import 'package:e305/interface/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FullPostImage extends StatelessWidget {
  final Post post;
  final ProgressIndicatorBuilder? progressIndicatorBuilder;

  const FullPostImage({required this.post, this.progressIndicatorBuilder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double scale = min(
          constraints.maxWidth.toDouble(), constraints.maxHeight.toDouble());

      return DefaultTextStyle(
        style: TextStyle(
          fontSize: scale * 0.05,
        ),
        child: PostImageOverlay(
          post: post,
          builder: (context) => CachedNetworkImage(
            fit: BoxFit.contain,
            fadeInDuration: Duration(milliseconds: 0),
            fadeOutDuration: Duration(milliseconds: 0),
            imageUrl: post.file.url!,
            errorWidget: (context, url, error) => Center(
              child: Icon(FontAwesomeIcons.exclamationTriangle, size: 20),
            ),
            progressIndicatorBuilder: (context, url, progress) => Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CachedNetworkImage(
                    fit: BoxFit.contain,
                    imageUrl: post.sample.url!,
                    progressIndicatorBuilder: progressIndicatorBuilder ??
                        (context, url, progress) => Center(
                              child: PulseLoadingIndicator(
                                size: scale * 0.2,
                              ),
                            ),
                  ),
                ),
                if (progress.progress != null)
                  Positioned(
                    child: LinearProgressIndicator(
                      value: progress.progress,
                      minHeight: scale * 0.01,
                      backgroundColor: Colors.transparent,
                    ),
                    top: 0,
                    right: 0,
                    left: 0,
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class PostImageOverlay extends StatelessWidget {
  final Post post;
  final WidgetBuilder builder;

  const PostImageOverlay({required this.post, required this.builder});

  @override
  Widget build(BuildContext context) {
    if (post.flags.deleted) {
      return Center(
        child: Text('post was deleted'),
      );
    }
    if (post.file.url == null) {
      return Center(
        child: Text('post unavailable in safe mode'),
      );
    }
    if (['webm', 'mp4', 'swf'].contains(post.file.ext)) {
      return Center(
        child: Text('video is not supported'),
      );
    }
    return builder(context);
  }
}

Widget imageFlightShuttleBuilder(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  final Hero hero = flightDirection == HeroFlightDirection.push
      ? fromHeroContext.widget as Hero
      : toHeroContext.widget as Hero;
  return hero.child;
}
