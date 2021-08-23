import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e305/client/models/post.dart';
import 'package:e305/interface/widgets/loading.dart';
import 'package:e305/posts/widgets/overlay.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'image.dart';

class PostTile extends StatelessWidget {
  final Post post;
  final String? hero;
  final VoidCallback? onPressed;

  PostTile({
    required this.post,
    this.onPressed,
    this.hero,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4),
      child: Container(
        color: Theme.of(context).cardColor,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: PostImageOverlay(
                    post: post,
                    builder: (context) => Hero(
                      tag: hero ?? UniqueKey(),
                      child: CachedNetworkImage(
                        imageUrl: post.sample.url!,
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: PostTileOverlay(post: post),
            ),
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PostPageTile extends StatelessWidget {
  final Post post;
  final String? hero;
  final Size? size;
  final VoidCallback onTap;

  const PostPageTile(
      {required this.post, this.size, required this.onTap, this.hero});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 32, top: 12),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Hero(
                      tag: hero ?? UniqueKey(),
                      child: CachedNetworkImage(
                        imageUrl: post.sample.url!,
                        fit: BoxFit.cover,
                        progressIndicatorBuilder: (context, url, progress) =>
                            Center(child: PulseLoadingIndicator(size: 80)),
                        errorWidget: (context, url, error) => Center(
                          child: Icon(
                            FontAwesomeIcons.exclamationTriangle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: PostTileOverlay(post: post),
                  ),
                  Positioned.fill(
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: onTap,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
