import 'package:cached_network_image/cached_network_image.dart';
import 'package:e305/posts/data/post.dart';
import 'package:e305/interface/widgets/loading.dart';
import 'package:e305/posts/widgets/fullscreen.dart';
import 'package:e305/posts/widgets/hero.dart';
import 'package:e305/posts/widgets/image.dart';
import 'package:flutter/material.dart';

class ImageDisplay extends StatelessWidget {
  final Post post;

  const ImageDisplay({required this.post});

  @override
  Widget build(BuildContext context) {
    String hero =
        HeroProvider.of(context)?.call(post.id) ?? UniqueKey().toString();
    Size screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: (screenSize.height / 2),
            maxHeight: screenSize.width > screenSize.height
                ? screenSize.height * 0.8
                : double.infinity,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: PostImageOverlay(
                  post: post,
                  builder: (context) => Center(
                    child: Hero(
                      tag: hero,
                      transitionOnUserGestures: true,
                      child: CachedNetworkImage(
                        imageUrl: post.sample.url!,
                        fit: BoxFit.cover,
                        progressIndicatorBuilder: (context, url, progress) =>
                            const Center(
                          child: PulseLoadingIndicator(
                            size: 60,
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const Center(child: Icon(Icons.error_outline)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () {
                HeroBuilder? heroBuilder = HeroProvider.of(context);
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (context) => HeroProvider(
                      builder: heroBuilder,
                      child: FullScreenPost(post: post),
                    ),
                  ),
                );
              },
            ),
          ),
        )
      ],
    );
  }
}
