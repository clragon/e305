import 'package:cached_network_image/cached_network_image.dart';
import 'package:e305/posts/data/post.dart';
import 'package:e305/interface/widgets/loading.dart';
import 'package:e305/posts/widgets/fullscreen.dart';
import 'package:e305/posts/widgets/image.dart';
import 'package:flutter/material.dart';

class ImageDisplay extends StatelessWidget {
  final Post post;
  final String? hero;

  const ImageDisplay({required this.post, this.hero});

  @override
  Widget build(BuildContext context) {
    String hero = this.hero ?? UniqueKey().toString();
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
              onTap: () => Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => FullScreenPost(
                    post: post,
                    hero: hero,
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
