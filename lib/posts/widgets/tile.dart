import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e305/posts/data/post.dart';
import 'package:e305/interface/widgets/loading.dart';
import 'package:e305/posts/data/controller.dart';
import 'package:e305/posts/widgets/hero.dart';
import 'package:e305/posts/widgets/overlay.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'image.dart';

class PostTile extends StatelessWidget {
  final Post post;
  final VoidCallback? onPressed;
  final PostController? controller;

  const PostTile({
    required this.post,
    this.onPressed,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
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
                      tag: HeroProvider.of(context)?.call(post.id) ??
                          UniqueKey(),
                      child: CachedNetworkImage(
                        imageUrl: post.sample.url!,
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
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
  final VoidCallback onTap;
  final PostController controller;

  const PostPageTile({
    required this.controller,
    required this.post,
    required this.onTap,
  });

  final double distance = 0.25;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool fitting = ((post.sample.width / post.sample.height) -
                    (constraints.biggest.width / constraints.biggest.height))
                .abs() <
            distance;

        Widget image() {
          return Hero(
            tag: HeroProvider.of(context)?.call(post.id) ?? UniqueKey(),
            transitionOnUserGestures: true,
            child: CachedNetworkImage(
              imageUrl: post.sample.url!,
              fit: BoxFit.cover,
              progressIndicatorBuilder: (context, url, progress) =>
                  const Center(child: PulseLoadingIndicator(size: 80)),
              errorWidget: (context, url, error) => const Center(
                child: Icon(
                  FontAwesomeIcons.exclamationTriangle,
                ),
              ),
            ),
          );
        }

        Widget background({required Widget child}) {
          return Stack(
            children: [
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: post.sample.url!,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(color: Colors.black54),
                ),
              ),
              Center(
                child: child,
              )
            ],
          );
        }

        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, bottom: 32, top: 12),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: fitting
                            ? image()
                            : background(
                                child: image(),
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
      },
    );
  }
}
