import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e305/client/models/post.dart';
import 'package:e305/interface/widgets/loading.dart';
import 'package:e305/posts/data/controller.dart';
import 'package:e305/posts/widgets/overlay.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'image.dart';

class PostTile extends StatelessWidget {
  final Post post;
  final String hero;
  final VoidCallback? onPressed;
  final PostController? controller;

  PostTile({
    required this.post,
    this.onPressed,
    String? hero,
    this.controller,
  }) : this.hero = hero ?? UniqueKey().toString();

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
                      tag: hero,
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
            if (controller != null)
              Positioned(
                bottom: 0,
                right: 0,
                child: PostScoreOverly(
                  post: post,
                  controller: controller!,
                ),
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
  final VoidCallback onTap;
  final PostController controller;

  const PostPageTile(
      {required this.post,
      required this.onTap,
      this.hero,
      required this.controller});

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
                      transitionOnUserGestures: true,
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
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: PostScoreOverly(
                      post: post,
                      controller: controller,
                    ),
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
